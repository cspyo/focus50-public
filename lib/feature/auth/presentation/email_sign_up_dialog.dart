import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/consts/error_message.dart';
import 'package:focus50/feature/auth/presentation/show_auth_dialog.dart';
import 'package:focus50/feature/auth/view_model/auth_view_model.dart';
import 'package:focus50/utils/amplitude_analytics.dart';
import 'package:focus50/utils/circular_progress_indicator.dart';

class EmailSignUpDialog extends ConsumerStatefulWidget {
  const EmailSignUpDialog({Key? key}) : super(key: key);

  @override
  _EmailSignUpDialogState createState() => _EmailSignUpDialogState();
}

class _EmailSignUpDialogState extends ConsumerState<EmailSignUpDialog> {
  final _formKey = GlobalKey<FormState>();
  String? nicknameValidate = null;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = "";

  String? invitedGroupId = Uri.base.queryParameters["g"];

  // 이메일로 회원가입
  void _signUpWithEmail() async {
    setState(() => _isLoading = true);
    String res = await ref.read(authViewModelProvider).signUpWithEmail(
        nickname: _nicknameController.text,
        email: _emailController.text,
        password: _passwordController.text);

    if (res == EMAIL_ALREADY_IN_USE) {
      setState(() => _errorMessage = "이미 존재하는 이메일입니다");
    } else if (res == SUCCESS) {
      await ref.read(authViewModelProvider).saveUserProfile(
          nickname: _nicknameController.text, signUpMethod: "email");
      AmplitudeAnalytics().logCompleteSignUp("email");
      Navigator.of(context).pop();
      ShowAuthDialog().showSignUpCompleteDialog(context);
    } else {
      setState(() => _errorMessage = "회원가입을 다시 진행해주세요");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _nicknameValidator() async {
    setState(() => _isLoading = true);
    String nickname = _nicknameController.text;
    if (nickname.isEmpty) {
      nicknameValidate = '닉네임은 필수사항입니다';
    } else if (nickname.length > 13) {
      nicknameValidate = '12자리 이내로 작성해주세요';
    } else if (!await ref
        .read(authViewModelProvider)
        .possibleNickname(nickname)) {
      nicknameValidate = '이미 사용중인 닉네임입니다';
    } else {
      nicknameValidate = null;
    }
    setState(() => _isLoading = false);
  }

  String? _emailValidator(String? email) {
    if (email == null) {
      return "이메일은 필수사항입니다";
    }
    if (!EmailValidator.validate(email)) {
      return "이메일 형식으로 입력해주세요";
    }
    return null;
  }

  String? _passwordValidator(String? password) {
    if (password == null) {
      return '비밀번호는 필수사항입니다';
    } else if (password.length < 6) {
      return '6자리 이상으로 입력해주세요';
    } else if (password.length > 20) {
      return '20자리 이내로 입력해주세요';
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // <-- SEE HERE
      title: _buildDialogTitle(),
      content: _buildEmailSignUp(),
    );
  }

  // 다이얼로그 타이틀
  Widget _buildDialogTitle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 36,
              height: 36,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  'Focus',
                  style: TextStyle(
                    fontFamily: 'Okddung',
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '50',
                  style: TextStyle(
                    fontFamily: 'Okddung',
                    fontSize: 25,
                    color: purple300,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  child: Icon(
                    Icons.clear,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          '회원가입',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // 이메일 회원가입 버튼 눌렀을 때
  Widget _buildEmailSignUp() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: ListBody(
            children: [
              Column(
                children: [
                  _errorMessage != ""
                      ? _buildErrorMessage(context)
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TextFormField(
                      controller: _nicknameController,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      cursorColor: Colors.grey.shade600,
                      cursorHeight: 18,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          ),
                        ),
                        hoverColor: purple300,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: purple300)),
                        labelText: '닉네임',
                        floatingLabelStyle: TextStyle(
                          color: purple300,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLines: 1,
                      maxLength: 12,
                      textInputAction: TextInputAction.next,
                      validator: (_) {
                        return nicknameValidate;
                      },
                    ),
                  ),
                  // 이메일 필드
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TextFormField(
                      controller: _emailController,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      cursorColor: Colors.grey.shade600,
                      cursorHeight: 18,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          ),
                        ),
                        hoverColor: purple300,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: purple300)),
                        labelText: '이메일',
                        floatingLabelStyle: TextStyle(
                          color: purple300,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLines: 1,
                      textInputAction: TextInputAction.next,
                      validator: _emailValidator,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 비밀번호
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      cursorColor: Colors.grey.shade600,
                      cursorHeight: 18,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          ),
                        ),
                        hoverColor: purple300,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: purple300)),
                        labelText: '비밀번호',
                        floatingLabelStyle: TextStyle(
                          color: purple300,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLines: 1,
                      maxLength: 20,
                      validator: _passwordValidator,
                      onFieldSubmitted: (_) async {
                        await _nicknameValidator();
                        if (_formKey.currentState!.validate()) {
                          _signUpWithEmail();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
              // 회원가입 버튼
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(180, 40),
                    primary: purple300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    await _nicknameValidator();
                    if (_formKey.currentState!.validate()) {
                      _signUpWithEmail();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? _buildCircularIndicator()
                          : const Text(
                              '회원가입',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              // 회원가입 했어?
              _buildAlreadySignUp(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadySignUp() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "이미 계정이 있나요?",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          SizedBox(width: 20),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              ShowAuthDialog().showLoginDialog(context);
            },
            child: Text(
              "로그인",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            _errorMessage,
            style: TextStyle(
              color: Colors.red,
              fontSize: 15,
            ),
          ),
        ),
        SizedBox(height: 20)
      ],
    );
  }

  Widget _buildCircularIndicator() {
    return CircularIndicator(size: 22, color: Colors.white);
  }
}

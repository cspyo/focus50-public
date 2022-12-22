import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/consts/error_message.dart';
import 'package:focus50/consts/routes.dart';
import 'package:focus50/feature/auth/presentation/show_auth_dialog.dart';
import 'package:focus50/feature/auth/view_model/auth_view_model.dart';
import 'package:focus50/utils/amplitude_analytics.dart';
import 'package:focus50/utils/circular_progress_indicator.dart';
import 'package:get/get.dart';

class EmailLoginDialog extends ConsumerStatefulWidget {
  const EmailLoginDialog({Key? key}) : super(key: key);

  @override
  _EmailLoginDialogState createState() => _EmailLoginDialogState();
}

class _EmailLoginDialogState extends ConsumerState<EmailLoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = "";

  String? invitedGroupId = Uri.base.queryParameters["g"];

  // 이메일로 로그인
  void _loginWithEmail(String email, String password) async {
    setState(() => _isLoading = true);
    String res = await ref
        .read(authViewModelProvider)
        .loginWithEmail(email: email, password: password);
    if (res == SUCCESS) {
      AmplitudeAnalytics().logCompleteLogin("email");
      Navigator.of(context).pop();
      invitedGroupId != null
          ? Get.rootDelegate.offNamed(Routes.CALENDAR,
              arguments: true, parameters: {'g': invitedGroupId!})
          : Get.rootDelegate.offNamed(Routes.CALENDAR);
    } else if (res == USER_NOT_FOUND) {
      setState(() => _errorMessage = "회원으로 등록되어있지 않습니다");
    } else if (res == WRONG_PASSWORD) {
      setState(() => _errorMessage = "비밀번호가 틀렸습니다");
    } else {
      setState(() => _errorMessage = "로그인을 다시 진행해주세요");
    }
    setState(() => _isLoading = false);
  }

  // 이메일 텍스트 필드 확인
  String? _emailValidator(String? email) {
    if (email == null) {
      return "이메일은 필수사항입니다";
    }
    if (!EmailValidator.validate(email)) {
      return "이메일 형식으로 입력해주세요";
    }
    return null;
  }

  // 비밀번호 텍스트 필드 확인
  String? _passwordValidator(String? password) {
    if (password == null) {
      return '비밀번호는 필수사항입니다';
    } else if (password.length < 6) {
      return '6자리 이상으로 입력해주세요';
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
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // <-- SEE HERE
      title: _buildDialogTitle(),
      content: _buildEmailLogin(),
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
          '로그인',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // 이메일 로그인 버튼 눌렀을 때
  Widget _buildEmailLogin() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: ListBody(
            children: [
              // 이메일 필드
              Column(
                children: [
                  _errorMessage != ""
                      ? _buildErrorMessage(context)
                      : Container(),
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
                      maxLength: 20,
                      maxLines: 1,
                      validator: _passwordValidator,
                      onFieldSubmitted: (_) async {
                        if (_formKey.currentState!.validate()) {
                          String email = _emailController.text;
                          String password = _passwordController.text;
                          _loginWithEmail(email, password);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
              // 로그인 버튼
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String email = _emailController.text;
                      String password = _passwordController.text;
                      _loginWithEmail(email, password);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? CircularIndicator(
                              size: 22,
                              color: Colors.white,
                            )
                          : const Text(
                              '로그인',
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
              // 회원가입 안했어?
              _buildNotSignedUp(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotSignedUp() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "계정이 아직 없나요?",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          SizedBox(width: 20),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              ShowAuthDialog().showSignUpDialog(context);
            },
            child: Text(
              "회원가입",
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
}

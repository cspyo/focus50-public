import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/error_message.dart';
import 'package:focus42/feature/auth/auth_view_model.dart';
import 'package:focus42/feature/auth/presentation/email_login_dialog.dart';
import 'package:focus42/feature/auth/presentation/sign_up_dialog.dart';

class LoginDialog extends ConsumerStatefulWidget {
  const LoginDialog({Key? key}) : super(key: key);

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends ConsumerState<LoginDialog> {
  // 구글로 로그인
  void _loginWithGoogle() async {
    String res = await ref.read(authViewModelProvider).loginWithGoogle();
    if (res == SUCCESS) {
      final authViewModel = ref.read(authViewModelProvider);
      if (!await authViewModel.isSignedUp()) {
        await authViewModel.saveUserProfile(nickname: null, file: null);
      }
      Navigator.of(context).pop();
    }
  }

  void _loginWithKakao() async {
    await ref.read(authViewModelProvider).loginWithKakao();
  }

  Future<void> _showEmailLoginDialog() async {
    Navigator.of(context).pop();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return EmailLoginDialog();
      },
    );
  }

  Future<void> _showSignUpDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SignUpDialog();
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // <-- SEE HERE
      title: _buildDialogTitle(),
      content: _buildLogin(context),
    );
  }

  // 다이얼로그 타이틀
  Widget _buildDialogTitle() {
    return Column(
      children: [
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

  // 로그인 버튼들 빌드
  Widget _buildLogin(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 400,
        child: ListBody(
          children: <Widget>[
            _buildGoogleLoginButton(),
            SizedBox(height: 20),
            _buildKakaoLoginButton(),
            SizedBox(height: 20),
            _buildEmailLoginButton(),
            SizedBox(height: 60),
            _buildNotSignedUp(),
          ],
        ),
      ),
    );
  }

  // 카카오 로그인 버튼
  Widget _buildKakaoLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(200, 48),
          primary: Color(0xFFFEE500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          ),
          elevation: 4,
        ),
        onPressed: _loginWithKakao,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              color: Colors.black,
              size: 20,
            ),
            SizedBox(width: 10),
            const Text(
              '  카카오로 로그인  ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(220, 0, 0, 0),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 구글 로그인 버튼
  Widget _buildGoogleLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(200, 48),
          primary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
            // side: BorderSide(
            //   color: Colors.grey.shade400,
            //   width: 0.5,
            // ),
          ),
          elevation: 4,
        ),
        onPressed: _loginWithGoogle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/google_icon.png",
              width: 20,
              height: 20,
            ),
            SizedBox(width: 10),
            const Text(
              '  구글로 로그인  ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 14),
          ],
        ),
      ),
    );
  }

  // 이메일 로그인 버튼
  Widget _buildEmailLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(200, 48),
          primary: Color(0xFFF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          ),
          elevation: 4,
        ),
        onPressed: _showEmailLoginDialog,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email_outlined,
              color: Colors.black,
              size: 20,
            ),
            SizedBox(
              width: 10,
            ),
            const Text(
              '  이메일로 로그인  ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
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
              _showSignUpDialog();
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/error_message.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/auth/auth_view_model.dart';
import 'package:focus42/feature/auth/presentation/email_sign_up_dialog.dart';
import 'package:focus42/feature/auth/presentation/login_dialog.dart';
import 'package:focus42/feature/indicator/circular_progress_indicator.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

class SignUpDialog extends ConsumerStatefulWidget {
  const SignUpDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpDialogState();
}

class _SignUpDialogState extends ConsumerState<SignUpDialog> {
  bool _isLoading = false;
  String _errorMessage = "";

  String? invitedGroupId = Uri.base.queryParameters["g"];

  void _logLoginAnalyticsAboutAgent(String loginMethod) {
    String userAgent = html.window.navigator.userAgent.toString().toLowerCase();
    if (userAgent.contains("iphone") || userAgent.contains("android")) {
      AnalyticsMethod().mobileLogLogin(loginMethod);
    } else {
      AnalyticsMethod().logLogin(loginMethod);
    }
  }

  // 구글로 회원가입
  void _signUpWithGoogle() async {
    String res = await ref.read(authViewModelProvider).loginWithGoogle();
    setState(() => _isLoading = true);
    if (res == SUCCESS) {
      final authViewModel = ref.read(authViewModelProvider);
      if (!await authViewModel.isSignedUp()) {
        await authViewModel.saveUserProfile(
            nickname: null, signUpMethod: "google");
        invitedGroupId != null
            ? Get.rootDelegate.offNamed(Routes.PROFILE,
                arguments: true, parameters: {'g': invitedGroupId!})
            : Get.rootDelegate.offNamed(Routes.PROFILE);
      } else {
        Navigator.of(context).pop();
        invitedGroupId != null
            ? Get.rootDelegate.offNamed(Routes.CALENDAR,
                arguments: true, parameters: {'g': invitedGroupId!})
            : Get.rootDelegate.offNamed(Routes.CALENDAR);
      }
      _logLoginAnalyticsAboutAgent("google");
    } else {
      setState(() => _errorMessage = "회원가입을 다시 진행해주세요");
    }
    setState(() => _isLoading = false);
  }

  // 카카오로 회원가입
  void _signUpWithKakao() async {
    String res = ERROR;
    setState(() => _isLoading = true);
    res = await ref.read(authViewModelProvider).loginWithKakao();
    if (res == SUCCESS) {
      final authViewModel = ref.read(authViewModelProvider);
      if (!await authViewModel.isSignedUp()) {
        await authViewModel.saveUserProfile(
            nickname: null, signUpMethod: "kakao");
        invitedGroupId != null
            ? Get.rootDelegate.offNamed(Routes.PROFILE,
                arguments: true, parameters: {'g': invitedGroupId!})
            : Get.rootDelegate.offNamed(Routes.PROFILE);
      } else {
        Navigator.of(context).pop();
        invitedGroupId != null
            ? Get.rootDelegate.offNamed(Routes.CALENDAR,
                arguments: true, parameters: {'g': invitedGroupId!})
            : Get.rootDelegate.offNamed(Routes.CALENDAR);
      }
      _logLoginAnalyticsAboutAgent("kakao");
    } else if (res == EMAIL_ALREADY_EXISTS) {
      setState(() => _errorMessage = "이미 가입한 이메일입니다");
    } else {
      setState(() => _errorMessage = "회원가입을 다시 진행해주세요");
    }
    setState(() => _isLoading = false);
  }

  // 이메일 회원가입 다이얼로그
  Future<void> _showEmailSignUpDialog() async {
    Navigator.of(context).pop();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return EmailSignUpDialog();
      },
    );
  }

  // 로그인 다이얼로그
  Future<void> _showLoginDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return LoginDialog();
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
      content:
          _isLoading ? _buildCircularIndicator(context) : _buildSignUp(context),
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

  // 회원가입 버튼들 빌드
  Widget _buildSignUp(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 400,
        child: ListBody(
          children: <Widget>[
            _errorMessage != "" ? _buildErrorMessage(context) : Container(),
            _buildGoogleSignUpButton(),
            SizedBox(height: 20),
            _buildKakaoSignUpButton(),
            SizedBox(height: 20),
            _buildEmailSignUpButton(),
            SizedBox(height: 60),
            _buildAlreadySignUp(),
          ],
        ),
      ),
    );
  }

  // 카카오 회원가입 버튼
  Widget _buildKakaoSignUpButton() {
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
        onPressed: _signUpWithKakao,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/kakao_button_icon.png",
              width: 20,
              height: 20,
            ),
            SizedBox(width: 10),
            const Text(
              '  카카오로 회원가입  ',
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

  // 구글 회원가입 버튼
  Widget _buildGoogleSignUpButton() {
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
        onPressed: _signUpWithGoogle,
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
              '  구글로 회원가입  ',
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

  // 이메일 회원가입 버튼
  Widget _buildEmailSignUpButton() {
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
        onPressed: _showEmailSignUpDialog,
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
              '  이메일로 회원가입  ',
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
              _showLoginDialog();
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

  Widget _buildCircularIndicator(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: ListBody(
          children: [
            Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: purple300,
                  strokeWidth: 5.0,
                ),
              ),
            ),
          ],
        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/consts/error_message.dart';
import 'package:focus50/consts/routes.dart';
import 'package:focus50/feature/auth/presentation/show_auth_dialog.dart';
import 'package:focus50/feature/auth/view_model/auth_view_model.dart';
import 'package:focus50/utils/amplitude_analytics.dart';
import 'package:get/get.dart';

class LoginDialog extends ConsumerStatefulWidget {
  const LoginDialog({Key? key}) : super(key: key);

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends ConsumerState<LoginDialog> {
  bool _isLoading = false;
  String _errorMessage = "";

  String? invitedGroupId = Uri.base.queryParameters["g"];

  // 구글로 로그인
  void _loginWithGoogle() async {
    AmplitudeAnalytics().logClickLoginButton("google");
    String res = await ref.read(authViewModelProvider).loginWithGoogle();
    setState(() => _isLoading = true);
    if (res == SUCCESS) {
      final authViewModel = ref.read(authViewModelProvider);
      if (!await authViewModel.isSignedUp()) {
        await authViewModel.saveUserProfile(
            nickname: null, signUpMethod: "google");
        AmplitudeAnalytics().logCompleteSignUp("google");
        Navigator.of(context).pop();
        ShowAuthDialog().showSignUpCompleteDialog(context);
      } else {
        AmplitudeAnalytics().logCompleteLogin("google");
        Navigator.of(context).pop();
        invitedGroupId != null
            ? Get.rootDelegate.offNamed(Routes.CALENDAR,
                arguments: true, parameters: {'g': invitedGroupId!})
            : Get.rootDelegate.offNamed(Routes.CALENDAR);
      }
    } else {
      setState(() => _errorMessage = "로그인을 다시 진행해주세요");
    }
    setState(() => _isLoading = false);
  }

  // 카카오로 로그인
  void _loginWithKakao() async {
    AmplitudeAnalytics().logClickLoginButton("kakao");
    String res = ERROR;
    setState(() => _isLoading = true);
    res = await ref.read(authViewModelProvider).loginWithKakao();
    if (res == SUCCESS) {
      final authViewModel = ref.read(authViewModelProvider);
      if (!await authViewModel.isSignedUp()) {
        await authViewModel.saveUserProfile(
            nickname: null, signUpMethod: "kakao");
        AmplitudeAnalytics().logCompleteSignUp("kakao");
        Navigator.of(context).pop();
        ShowAuthDialog().showSignUpCompleteDialog(context);
      } else {
        AmplitudeAnalytics().logCompleteLogin("email");
        Navigator.of(context).pop();
        invitedGroupId != null
            ? Get.rootDelegate.offNamed(Routes.CALENDAR,
                arguments: true, parameters: {'g': invitedGroupId!})
            : Get.rootDelegate.offNamed(Routes.CALENDAR);
      }
    } else if (res == EMAIL_ALREADY_EXISTS) {
      setState(() => _errorMessage = "이미 가입한 이메일입니다");
    } else {
      setState(() => _errorMessage = "로그인을 다시 진행해주세요");
    }
    setState(() => _isLoading = false);
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
          _isLoading ? _buildCircularIndicator(context) : _buildLogin(context),
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

  // 로그인 버튼들 빌드
  Widget _buildLogin(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 400,
        child: ListBody(
          children: <Widget>[
            _errorMessage != "" ? _buildErrorMessage(context) : Container(),
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
            Image.asset(
              "assets/images/kakao_button_icon.png",
              width: 20,
              height: 20,
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
        onPressed: () {
          AmplitudeAnalytics().logClickLoginButton("email");
          Navigator.of(context).pop();
          ShowAuthDialog().showEmailLoginDialog(context);
        },
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

  Widget _buildCircularIndicator(BuildContext context) {
    //TODO: singlechildscorllview랑 container listbody는 왜 쓴거지??
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

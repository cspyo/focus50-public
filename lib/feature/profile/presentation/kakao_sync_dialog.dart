import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/auth/auth_view_model.dart';
import 'package:focus42/feature/indicator/circular_progress_indicator.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/models/user_private_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

class KakaoSyncDialog extends ConsumerStatefulWidget {
  final UserModel myInfo;
  const KakaoSyncDialog({Key? key, required this.myInfo}) : super(key: key);

  @override
  _KakaoSyncDialogState createState() => _KakaoSyncDialogState();
}

class _KakaoSyncDialogState extends ConsumerState<KakaoSyncDialog> {
  bool _kakaoSyncSuccess = false;
  bool _isUpdating = false;

  void _tapKakaoSyncButton() async {
    _kakaoSyncSuccess =
        await ref.read(authViewModelProvider).kakaoLoginProcess();
    await _updateUserAboutKakao();
    Navigator.of(context).pop();
  }

  Future<void> _updateUserAboutKakao() async {
    if (_kakaoSyncSuccess) {
      final database = ref.read(databaseProvider);
      setState(() => _isUpdating = true);

      final kakaoUser = await kakao.UserApi.instance.me();
      String? kakaoNickname = kakaoUser.kakaoAccount?.profile?.nickname;
      String? phoneNumber =
          _substringPhoneNumber(kakaoUser.kakaoAccount?.phoneNumber);
      String? kakaoAccount = kakaoUser.kakaoAccount?.email;
      bool? talkMessageAgreed =
          await ref.read(authViewModelProvider).getTalkMessageAgreed();
      List<String?> noticeMethods =
          widget.myInfo.userPublicModel!.noticeMethods!;
      if (talkMessageAgreed != null) if (talkMessageAgreed)
        noticeMethods.add("kakao");

      UserPublicModel userPublic = UserPublicModel(
        updatedDate: DateTime.now(),
        kakaoSynced: _kakaoSyncSuccess,
        kakaoNickname: kakaoNickname,
        talkMessageAgreed: talkMessageAgreed,
        kakaoNoticeAllowed: talkMessageAgreed,
        noticeMethods: noticeMethods,
      );

      UserPrivateModel userPrivate = UserPrivateModel(
        kakaoAccount: kakaoAccount,
        phoneNumber: phoneNumber,
      );

      UserModel updateUser = UserModel(userPublic, userPrivate);

      await database.updateUser(updateUser);

      setState(() => _isUpdating = false);
    }
  }

  String? _substringPhoneNumber(String? phoneNumber) {
    if (phoneNumber != null) {
      String first = phoneNumber.substring(0, 3);
      String second = phoneNumber.substring(4, 6);
      String third = phoneNumber.substring(7, 11);
      String fourth = phoneNumber.substring(12);
      return first + second + third + fourth;
    }
    return null;
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
      content: _isUpdating
          ? _buildCircularIndicator(context)
          : _buildKakaoSync(context),
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
        // SizedBox(
        //   height: 5,
        // ),
        // Text(
        //   '카카오 연동하기',
        //   style: TextStyle(
        //     fontSize: 25,
        //     fontWeight: FontWeight.w600,
        //     color: Colors.black,
        //   ),
        // ),
      ],
    );
  }

  // 카카오 연동
  Widget _buildKakaoSync(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 400,
        child: ListBody(
          children: <Widget>[
            _buildExplainText(),
            SizedBox(height: 20),
            _buildKakaoSyncButton(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExplainText() {
    return Center(
      child: Text(
        "<카카오톡 수신 동의를 꼭 체크해주세요!>",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  // 카카오 회원가입 버튼
  Widget _buildKakaoSyncButton() {
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
        onPressed: _tapKakaoSyncButton,
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
              '  카카오 연동하기  ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(220, 0, 0, 0),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIndicator(BuildContext context) {
    //TODO: 왜 SinglechildScrollview?
    return SingleChildScrollView(
      child: Container(
        child: ListBody(
          children: [CircularIndicator(size: 50, color: MyColors.purple300)],
        ),
      ),
    );
  }
}

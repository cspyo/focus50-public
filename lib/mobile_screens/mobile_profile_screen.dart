import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/auth/auth_view_model.dart';
import 'package:focus42/feature/indicator/circular_progress_indicator.dart';
import 'package:focus42/feature/profile/presentation/kakao_sync_dialog.dart';
import 'package:focus42/mobile_widgets/mobile_drawer.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/models/user_private_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/storage_method.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/utils.dart';
import 'package:focus42/widgets/line.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

final isUpdatingProvider = StateProvider.autoDispose<bool>(((ref) => false));

class MobileProfileScreen extends ConsumerStatefulWidget {
  MobileProfileScreen({Key? key}) : super(key: key);
  @override
  _MobileProfileScreenState createState() => _MobileProfileScreenState();
}

class _MobileProfileScreenState extends ConsumerState<MobileProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;

  Uint8List? _image;
  late UserModel myInfo;

  bool _isUpdating = false;
  bool _talkNoticeEnable = false;
  bool _kakaoSyncSuccess = false;

  String? nicknameValidate = null;

  final ValueNotifier<bool> _emailNoticeController = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _kakaoNoticeController = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _showSyncKakaoDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return KakaoSyncDialog(
          myInfo: myInfo,
        );
      },
    );
  }

  bool _somethingChanged() {
    bool nicknameChanged =
        myInfo.userPublicModel!.nickname! != _nicknameController.text;
    bool photoChanged = _image != null;
    bool emailNoticeChanged = myInfo.userPublicModel!.emailNoticeAllowed! !=
        _emailNoticeController.value;
    bool kakaoNoticeChanged = myInfo.userPublicModel!.kakaoNoticeAllowed! !=
        _kakaoNoticeController.value;

    return nicknameChanged ||
        photoChanged ||
        emailNoticeChanged ||
        kakaoNoticeChanged;
  }

  void _updateProfile() async {
    final database = ref.read(databaseProvider);

    if (!_somethingChanged()) {
      showSnackBar("변경사항이 없습니다", context);
      return;
    }

    String? nickname = _nicknameController.text;
    bool emailNoticeAllowed = _emailNoticeController.value;
    bool kakaoNoticeAllowed = _kakaoNoticeController.value;
    bool talkMessageAgreed = kakaoNoticeAllowed;
    List<String> noticeMethods = [];
    if (_emailNoticeController.value) noticeMethods.add("email");
    if (_kakaoNoticeController.value) noticeMethods.add("kakao");

    ref.read(isUpdatingProvider.notifier).state = true;

    String newPhotoUrl;
    if (_image == null) {
      newPhotoUrl = myInfo.userPublicModel!.photoUrl!;
    } else {
      final String dateString =
          DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      newPhotoUrl = await StorageMethods().uploadImageToStorage(
          'profilePics/${myInfo.userPrivateModel!.uid}/${dateString}', _image!);
    }

    UserPublicModel userPublic = UserPublicModel(
      nickname: nickname,
      photoUrl: newPhotoUrl,
      updatedDate: DateTime.now(),
      talkMessageAgreed: talkMessageAgreed,
      emailNoticeAllowed: emailNoticeAllowed,
      kakaoNoticeAllowed: kakaoNoticeAllowed,
      noticeMethods: noticeMethods,
    );

    UserPrivateModel userPrivate = UserPrivateModel();

    UserModel updateUser = UserModel(userPublic, userPrivate);

    await database.updateUser(updateUser);

    showSnackBar("업데이트 완료", context);

    ref.read(isUpdatingProvider.notifier).state = false;
  }

  Future<void> _nicknameValidator() async {
    String initialValue = myInfo.userPublicModel!.nickname!;
    String nickname = _nicknameController.text;
    if (nickname.isEmpty) {
      nicknameValidate = '닉네임은 필수사항입니다';
    } else if (nickname.length > 12) {
      nicknameValidate = '12자리 이내로 작성해주세요';
    } else if (nickname == initialValue) {
      nicknameValidate = null;
    } else if (!await ref
        .read(authViewModelProvider)
        .possibleNickname(nickname)) {
      nicknameValidate = '이미 사용중인 닉네임입니다';
    } else {
      nicknameValidate = null;
    }
  }

  void _selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void _initStates(UserModel user) {
    myInfo = user;
    _nicknameController =
        TextEditingController(text: user.userPublicModel!.nickname);
    _emailController =
        TextEditingController(text: user.userPrivateModel!.email);

    // kakaoSynced 로 카카오 연동하기 박스 생성
    if (user.userPublicModel!.kakaoSynced == null)
      _talkNoticeEnable = false;
    else
      _talkNoticeEnable = user.userPublicModel!.kakaoSynced!;

    if (user.userPublicModel!.kakaoNoticeAllowed == null)
      _kakaoNoticeController.value = false;
    else
      _kakaoNoticeController.value = user.userPublicModel!.kakaoNoticeAllowed!;

    if (user.userPublicModel!.emailNoticeAllowed == null)
      _emailNoticeController.value = true;
    else
      _emailNoticeController.value = user.userPublicModel!.emailNoticeAllowed!;
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<UserModel> user = ref.watch(userStreamProvider);

    /// 스트림으로 바꾸기
    return user.when(
        data: (user) {
          _initStates(user);
          return _buildContent(user);
        },
        error: (_, __) => Text('Error'),
        loading: () => CircularIndicator(size: 22, color: Colors.white));
  }

  Widget _buildContent(UserModel user) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Focus',
              style: TextStyle(
                fontFamily: 'Okddung',
                fontSize: 30,
                color: Colors.black,
              ),
            ),
            Text(
              '50',
              style: TextStyle(
                fontFamily: 'Okddung',
                fontSize: 30,
                color: purple300,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: purple300),
      ),
      drawer: MobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Line(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              alignment: Alignment.center,
              width: double.infinity,
              child: SafeArea(
                child: Container(
                  width: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      _buildTitle(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildProfileImage(user),
                      SizedBox(
                        height: 20,
                      ),
                      _buildTextFields(user),
                      SizedBox(
                        height: 40,
                      ),
                      _buildSendMessageOption(),
                      SizedBox(
                        height: 40,
                      ),
                      _buildUpdateButton(user),
                      SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "내 정보 수정",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w600, color: purple300),
        ),
      ],
    );
  }

  Widget _buildProfileImage(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _image != null
            ? CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black38,
                backgroundImage: MemoryImage(_image!),
              )
            : CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black38,
                backgroundImage: NetworkImage(
                  user.userPublicModel!.photoUrl!,
                ),
              ),
        SizedBox(width: 40),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "프로필 사진",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              SizedBox(
                width: 80,
                height: 25,
                child: ElevatedButton(
                  onPressed: _selectImage,
                  style: ElevatedButton.styleFrom(
                    primary: purple300,
                  ),
                  child: const Text(
                    '업로드',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFields(UserModel user) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 닉네임 텍스트 필드
          Text(
            "닉네임",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: _nicknameController,
            cursorColor: Colors.grey.shade600,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(12, 26, 10, 0),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: purple300, style: BorderStyle.solid, width: 2.0)),
            ),
            maxLines: 1,
            maxLength: 12,
            validator: (_) {
              return nicknameValidate;
            },
            onFieldSubmitted: (_) async {
              await _nicknameValidator();
              if (_formKey.currentState!.validate()) {
                _updateProfile();
              }
            },
          ),
          const SizedBox(
            height: 5,
          ),
          // 이메일 텍스트 필드
          Text(
            "이메일",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(12, 26, 10, 0),
              fillColor: Color.fromARGB(255, 228, 225, 225),
              filled: true,
              border: OutlineInputBorder(),
            ),
            enabled: false,
            readOnly: true,
            maxLines: 1,
            validator: (_) {
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSendMessageOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "예약 알림 설정",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "*세션 시작 5분 전에 알림을 드립니다",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        // !_talkNoticeEnable ? SizedBox(height: 16) : Container(),
        // !_talkNoticeEnable ? _buildKakaoSyncNotification() : Container(),
        // SizedBox(height: 16),
        // _buildSwitchButton(
        //     "카카오톡으로 알림 받기", _kakaoNoticeController, _talkNoticeEnable),
        SizedBox(height: 20),
        _buildSwitchButton("이메일로 알림 받기", _emailNoticeController, true),
      ],
    );
  }

  Widget _buildKakaoSyncNotification() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 203, 0, 0.15),
      ),
      padding: EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_rounded,
            color: Colors.yellow,
            size: 20.0,
          ),
          SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "카카오 연동을 하시면 카카오톡으로 알림을 받을 수 있습니다.",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  InkWell(
                    onTap: _showSyncKakaoDialog,
                    child: Row(
                      children: [
                        Icon(
                          Icons.message_rounded,
                          size: 14.0,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          "카카오 연동하기",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    "카카오톡 수신 선택 항목에 동의해주세요.",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSwitchButton(
      String text, ValueNotifier<bool> controller, bool enabled) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (enabled) {
            controller.value = !controller.value;
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 0.6,
            color: enabled ? Colors.black : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: enabled ? Colors.black : Colors.grey,
              ),
            ),
            AdvancedSwitch(
              inactiveColor: Colors.grey,
              activeColor: purple300,
              inactiveChild: Text('off'),
              activeChild: Text('on'),
              width: 60,
              height: 30,
              controller: controller,
              enabled: enabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton(UserModel user) {
    bool _isUpdating = ref.watch(isUpdatingProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          height: 30,
          child: ElevatedButton(
            onPressed: () async {
              await _nicknameValidator();
              if (_formKey.currentState!.validate()) {
                _updateProfile();
              }
            },
            style: ElevatedButton.styleFrom(
              primary: purple300,
            ),
            child: _isUpdating
                ? CircularIndicator(size: 10, color: Colors.white)
                : const Text(
                    '변경사항 저장',
                    style: TextStyle(),
                  ),
          ),
        ),
      ],
    );
  }
}

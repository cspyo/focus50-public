import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/widgets/header_logo.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../consts/colors.dart';
import '../consts/routes.dart';
import '../resources/auth_method.dart';
import '../utils/utils.dart';
import '../widgets/line.dart';

class AddProfileScreen extends StatefulWidget {
  AddProfileScreen({Key? key}) : super(key: key);

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;

  String? nicknameValidate = null;
  String? invitedGroupId = Uri.base.queryParameters["g"];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _jobController.dispose();

    super.dispose();
  }

  void saveUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().saveUserProfile(
      username: _nameController.text,
      nickname: _nicknameController.text,
      job: _jobController.text,
      file: _image,
    );

    invitedGroupId != null
        ? Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR(),
            arguments: true, parameters: {'g': invitedGroupId!})
        : Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR());
    AnalyticsMethod().logCreateProfile();
    setState(() {
      _isLoading = false;
    });
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  nicknameValidator() async {
    setState(() {
      _isLoading = true;
    });
    var nickname = _nicknameController.text;
    if (nickname.isEmpty) {
      nicknameValidate = '닉네임은 필수사항입니다';
    } else if (await AuthMethods().isOverlapNickname(nickname)) {
      nicknameValidate = '이미 사용중인 닉네임입니다';
    } else {
      nicknameValidate = null;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 데스크탑 헤더
          Container(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 25, right: 25),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    HeaderLogo(),
                    Row(children: <Widget>[
                      Text(
                        "이미 계정이 있나요?",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: purple300,
                        ),
                        onPressed: () {
                          invitedGroupId != null
                              ? Get.rootDelegate.offNamed(Routes.LOGIN,
                                  arguments: true,
                                  parameters: {'g': invitedGroupId!})
                              : Get.rootDelegate.offNamed(Routes.LOGIN);
                        },
                        child: const Text(
                          '    로그인    ',
                          style: TextStyle(),
                        ),
                      )
                    ])
                  ])),
          const Line(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    '프로필 작성',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: purple300,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundColor: Colors.black38,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : CircleAvatar(
                              radius: 64,
                              backgroundColor: Colors.black38,
                              backgroundImage: NetworkImage(
                                  'https://firebasestorage.googleapis.com/v0/b/focus-50.appspot.com/o/profilePics%2Fuser.png?alt=media&token=69e13fc9-b2ea-460c-98e0-92fe6613461e'),
                            ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(
                            Icons.add_a_photo,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 이름 텍스트 필드
                        SizedBox(
                          width: 450,
                          child: TextFormField(
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '이름은 필수사항입니다';
                              }
                              return null;
                            },
                            onSaved: (val) {},
                            onFieldSubmitted: (text) async {
                              await nicknameValidator();
                              if (_formKey.currentState!.validate()) {
                                saveUserProfile();
                              }
                            },
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: '이름',
                              hintStyle: TextStyle(
                                color: border200,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ), // icon is 48px widget.
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 0.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // 닉네임 텍스트 필드
                        SizedBox(
                          width: 450,
                          child: TextFormField(
                            controller: _nicknameController,
                            validator: (value) {
                              return nicknameValidate;
                            },
                            onSaved: (val) {},
                            onFieldSubmitted: (text) async {
                              await nicknameValidator();
                              if (_formKey.currentState!.validate()) {
                                saveUserProfile();
                              }
                            },
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: '닉네임',
                              hintStyle: TextStyle(
                                color: border200,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ), // icon is 48px widget.
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 0.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // job 텍스트 필드
                        SizedBox(
                          width: 450,
                          child: TextFormField(
                            controller: _jobController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '직업은 필수사항입니다';
                              }
                              return null;
                            },
                            onSaved: (val) {},
                            onFieldSubmitted: (text) async {
                              await nicknameValidator();
                              if (_formKey.currentState!.validate()) {
                                saveUserProfile();
                              }
                            },
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: '직업',
                              hintStyle: TextStyle(
                                color: border200,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                  Icons.work,
                                  color: Colors.grey,
                                ), // icon is 48px widget.
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 0.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // 시작하기 버튼
                        SizedBox(
                          width: 450,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              await nicknameValidator();
                              if (_formKey.currentState!.validate()) {
                                saveUserProfile();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: purple300,
                              fixedSize: Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '시작하기',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

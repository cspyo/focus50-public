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

    Get.rootDelegate.toNamed(Routes.CALENDAR);
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
                          Get.rootDelegate.offNamed(Routes.LOGIN);
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
                                  'https://firebasestorage.googleapis.com/v0/b/focus50-8b405.appspot.com/o/profilePics%2Fuser.png?alt=media&token=f3d3b60c-55f8-4576-bfab-e219d9c225b3'),
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
                            onFieldSubmitted: (text) {
                              if (_formKey.currentState!.validate()) {
                                saveUserProfile();
                              }
                            },
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: '이름',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
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
                              if (value == null || value.isEmpty) {
                                return '닉네임은 필수사항입니다';
                              }
                              return null;
                            },
                            onSaved: (val) {},
                            onFieldSubmitted: (text) {
                              if (_formKey.currentState!.validate()) {
                                saveUserProfile();
                              }
                            },
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: '닉네임',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
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
                            onFieldSubmitted: (text) {
                              if (_formKey.currentState!.validate()) {
                                saveUserProfile();
                              }
                            },
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: '직업',
                              prefixIcon: const Icon(Icons.article),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // 로그인 버튼
                        SizedBox(
                          width: 450,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                saveUserProfile();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: purple300,
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

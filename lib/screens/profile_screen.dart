import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/models/user_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../consts/colors.dart';
import '../consts/routes.dart';
import '../resources/auth_method.dart';
import '../resources/storage_method.dart';
import '../utils/utils.dart';
import '../widgets/line.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();

  Uint8List? _image;

  bool isUpdating = false;
  bool isLoading = true;

  CollectionReference _userColRef = AuthMethods().getUserColRef();

  var userData = {};

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _jobController.dispose();

    super.dispose();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      userData = userSnap.data()!;

      _nameController.text = userData['username'];
      _nicknameController.text = userData['nickname'];
      _jobController.text = userData['job'];

      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    setState(() {
      isLoading = false;
    });
  }

  void updateProfile(String uid, String email, String username, String nickname,
      String job) async {
    setState(() {
      isUpdating = true;
    });

    String photoUrl;
    if (_image == null) {
      photoUrl = userData['photoUrl'];
    } else {
      photoUrl =
          await StorageMethods().uploadImageToStorage('profilePics', _image!);
    }

    UserModel user = new UserModel(
        username: username,
        uid: uid,
        photoUrl: photoUrl,
        email: email,
        nickname: nickname,
        job: job);

    await _userColRef.doc(_auth.currentUser!.uid).update(user.toFirestore());

    showSnackBar("업데이트 완료", context);

    setState(() {
      isUpdating = false;
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
        children: <Widget>[
          // 데스크탑 헤더
          Container(
            padding:
                const EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: const <Widget>[
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
                Row(
                  children: <Widget>[
                    TextButton(
                        onPressed: () {
                          Get.rootDelegate.toNamed(Routes.ABOUT);
                        },
                        child: const Text('소개',
                            style:
                                TextStyle(fontSize: 17, color: Colors.black))),
                    SizedBox(width: 10),
                    TextButton(
                        onPressed: () {
                          Get.rootDelegate.toNamed(Routes.CALENDAR);
                        },
                        child: const Text('캘린더',
                            style:
                                TextStyle(fontSize: 17, color: Colors.black))),
                    SizedBox(width: 10),
                    (_auth.currentUser != null)
                        ? TextButton(
                            onPressed: () {
                              Get.rootDelegate.toNamed(Routes.PROFILE);
                            },
                            child: const Text('마이페이지',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black)))
                        : Container(),
                    SizedBox(width: 10),
                    (_auth.currentUser != null)
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: purple300,
                            ),
                            onPressed: () {
                              setState(() {
                                _auth.signOut();
                              });

                              Get.rootDelegate.toNamed(Routes.LOGIN);
                            },
                            child: const Text(
                              '  로그아웃  ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              primary: purple300,
                            ),
                            onPressed: () {
                              Get.rootDelegate.toNamed(Routes.SIGNUP);
                            },
                            child: const Text(
                              '회원가입',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                    (_auth.currentUser != null)
                        ? Container()
                        : SizedBox(width: 20),
                    (_auth.currentUser != null)
                        ? Container()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: purple300,
                            ),
                            onPressed: () {
                              Get.rootDelegate.toNamed(Routes.LOGIN);
                            },
                            child: const Text(
                              '  로그인  ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ), //header
          const Line(),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 80,
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
                                      userData['photoUrl'],
                                    ),
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
                          height: 24,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // 이름 텍스트 필드
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    child: Text(
                                      "이름",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: purple300,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 400,
                                    child: TextFormField(
                                      controller: _nameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '이름을 입력해주세요';
                                        }
                                        return null;
                                      },
                                      onSaved: (val) {},
                                      onFieldSubmitted: (text) async {
                                        final username = _nameController.text;
                                        final nickname =
                                            _nicknameController.text;
                                        final job = _jobController.text;

                                        updateProfile(
                                          userData['uid'],
                                          userData['email'],
                                          username,
                                          nickname,
                                          job,
                                        );
                                      },
                                      maxLines: 1,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.person),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              // 닉네임 텍스트 필드
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    child: Text(
                                      "닉네임",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: purple300,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 400,
                                    child: TextFormField(
                                      controller: _nicknameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '닉네임을 입력해주세요';
                                        }
                                        return null;
                                      },
                                      onSaved: (val) {},
                                      onFieldSubmitted: (text) async {
                                        final username = _nameController.text;
                                        final nickname =
                                            _nicknameController.text;
                                        final job = _jobController.text;

                                        updateProfile(
                                          userData['uid'],
                                          userData['email'],
                                          username,
                                          nickname,
                                          job,
                                        );
                                      },
                                      maxLines: 1,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                            Icons.co_present_rounded),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              // job 텍스트 필드
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    child: Text(
                                      "직업",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: purple300,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 400,
                                    child: TextFormField(
                                      controller: _jobController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '직업을 입력해주세요';
                                        }
                                        return null;
                                      },
                                      onSaved: (val) {},
                                      onFieldSubmitted: (text) async {
                                        final username = _nameController.text;
                                        final nickname =
                                            _nicknameController.text;
                                        final job = _jobController.text;

                                        updateProfile(
                                          userData['uid'],
                                          userData['email'],
                                          username,
                                          nickname,
                                          job,
                                        );
                                      },
                                      maxLines: 1,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.article),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: 250,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              final username = _nameController.text;
                              final nickname = _nicknameController.text;
                              final job = _jobController.text;

                              updateProfile(
                                userData['uid'],
                                userData['email'],
                                username,
                                nickname,
                                job,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: purple300,
                            ),
                            child: isUpdating
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '업데이트',
                                    style: TextStyle(),
                                  ),
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

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/widgets/desktop_header.dart';
import 'package:image_picker/image_picker.dart';

import '../consts/colors.dart';
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

  CollectionReference _userPublicColRef = AuthMethods().getUserPublicColRef();

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

  void updateProfile(String nickname, String job) async {
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

    UserPublicModel user = new UserPublicModel(
      nickname: nickname,
      photoUrl: photoUrl,
      job: job,
      updatedDate: DateTime.now(),
    );

    await _userPublicColRef
        .doc(_auth.currentUser!.uid)
        .update(user.toFirestore());

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
          DesktopHeader(),
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

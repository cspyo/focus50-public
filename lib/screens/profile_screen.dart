import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/models/user_private_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/widgets/desktop_header.dart';
import 'package:image_picker/image_picker.dart';

import '../consts/colors.dart';
import '../resources/storage_method.dart';
import '../utils/utils.dart';
import '../widgets/line.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();

  Uint8List? _image;
  late UserModel myAuth;

  bool isUpdating = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _updateProfile(String photoUrl, String nickname) async {
    final database = ref.read(databaseProvider);
    setState(() {
      isUpdating = true;
    });

    String newPhotoUrl;
    if (_image == null) {
      newPhotoUrl = photoUrl;
    } else {
      newPhotoUrl =
          await StorageMethods().uploadImageToStorage('profilePics', _image!);
    }

    UserPublicModel userPublic = UserPublicModel(
      nickname: nickname,
      photoUrl: newPhotoUrl,
      updatedDate: DateTime.now(),
    );

    UserPrivateModel userPrivate = UserPrivateModel();

    UserModel updateUser = UserModel(userPublic, userPrivate);

    await database.setUser(updateUser);

    showSnackBar("업데이트 완료", context);

    setState(() {
      isUpdating = false;
    });
  }

  void _selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<UserModel> user = ref.watch(userProvider);

    return user.when(
        data: (user) {
          return _buildContent(user);
        },
        error: (_, __) => Text('Error'),
        loading: () => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ));
  }

  Widget _buildContent(UserModel user) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: <Widget>[
                DesktopHeader(),
                const Line(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  alignment: Alignment.center,
                  width: double.infinity,
                  child: SafeArea(
                    child: Container(
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          _buildProfileImage(user),
                          SizedBox(
                            height: 24,
                          ),
                          _buildTextFields(),
                          SizedBox(
                            height: 40,
                          ),
                          _buildUpdateButton(user),
                          SizedBox(
                            height: 40,
                          ),
                          // _buildKakaoButton(user),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _image != null
            ? CircleAvatar(
                radius: 38,
                backgroundColor: Colors.black38,
                backgroundImage: MemoryImage(_image!),
              )
            : CircleAvatar(
                radius: 38,
                backgroundColor: Colors.black38,
                backgroundImage: NetworkImage(
                  user.userPublicModel!.photoUrl!,
                ),
              ),
        SizedBox(width: 20),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "프로필 사진",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 6),
              SizedBox(
                width: 65,
                height: 20,
                child: ElevatedButton(
                  onPressed: _selectImage,
                  style: ElevatedButton.styleFrom(
                    primary: purple300,
                  ),
                  child: const Text(
                    '업로드',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    double textFieldsWidth = 300;
    double textFieldsHeight = 40;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 닉네임 텍스트 필드
          SizedBox(
            width: textFieldsWidth,
            height: textFieldsHeight,
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '닉네임을 입력해주세요',
                hintStyle: TextStyle(fontSize: 13),
                labelText: '닉네임*',
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onSaved: (String? value) {},
              validator: (_) {
                return null;
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildKakaoButton(UserModel user) {
    return SizedBox(
      width: 250,
      height: 40,
      child: ElevatedButton(
        onPressed: () async {},
        style: ElevatedButton.styleFrom(
          primary: purple300,
        ),
        child: const Text(
          '연동하기',
          style: TextStyle(),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(UserModel user) {
    return SizedBox(
      width: 250,
      height: 40,
      child: ElevatedButton(
        onPressed: () async {
          final nickname = _nicknameController.text;
          final photoUrl = user.userPublicModel!.photoUrl!;

          _updateProfile(
            photoUrl,
            nickname,
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
                '변경사항 수정',
                style: TextStyle(),
              ),
      ),
    );
  }
}

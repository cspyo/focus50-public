import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// 나중에 프로필 사진 받아올 때 쓰기
pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();

  XFile? file = await imagePicker.pickImage(source: source);

  if (file != null) {
    return await file.readAsBytes();
  }
}

// 스낵바 보여주기
showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

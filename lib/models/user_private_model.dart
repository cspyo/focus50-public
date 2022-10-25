import 'package:cloud_firestore/cloud_firestore.dart';

class UserPrivateModel {
  final String? uid;
  final String? email;
  String? kakaoAccount;
  final String? phoneNumber;

  UserPrivateModel({
    this.uid,
    this.email,
    this.kakaoAccount,
    this.phoneNumber,
  });

  factory UserPrivateModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return UserPrivateModel(
      uid: data?["uid"],
      email: data?["email"],
      kakaoAccount: data?["kakaoAccount"],
      phoneNumber: data?["phoneNumber"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (uid != null) "uid": uid,
      if (email != null) "email": email,
      if (kakaoAccount != null) "kakaoAccount": kakaoAccount,
      if (phoneNumber != null) "phoneNumber": phoneNumber,
    };
  }
}

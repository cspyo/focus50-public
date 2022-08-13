import 'package:cloud_firestore/cloud_firestore.dart';

class UserPrivateModel {
  final String? uid;
  final String? username;
  final String? email;
  final String? phoneNumber;

  UserPrivateModel({
    this.uid,
    this.username,
    this.email,
    this.phoneNumber,
  });

  factory UserPrivateModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return UserPrivateModel(
      uid: data?["uid"],
      username: data?["username"],
      email: data?["email"],
      phoneNumber: data?["phoneNumber"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      "username": username,
      "email": email,
      "phoneNumber": phoneNumber,
    };
  }
}

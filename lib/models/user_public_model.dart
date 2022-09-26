import 'package:cloud_firestore/cloud_firestore.dart';

class UserPublicModel {
  final String? nickname;
  final String? photoUrl;
  final String? job;
  DateTime? createdDate;
  DateTime? updatedDate;
  DateTime? lastLogin;

  UserPublicModel({
    this.nickname,
    this.photoUrl,
    this.job,
    this.createdDate,
    this.updatedDate,
    this.lastLogin,
  });

  factory UserPublicModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    var createdDate = null;
    var updatedDate = null;
    var lastLogin = null;
    if (data?["createdDate"] != null) {
      createdDate = data?["createdDate"].toDate();
    }
    if (data?["updatedDate"] != null) {
      updatedDate = data?["updatedDate"].toDate();
    }
    if (data?["lastLogin"] != null) {
      lastLogin = data?["lastLogin"].toDate();
    }

    return UserPublicModel(
      nickname: data?["nickname"],
      photoUrl: data?["photoUrl"],
      job: data?["job"],
      createdDate: createdDate,
      updatedDate: updatedDate,
      lastLogin: lastLogin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (photoUrl != null) "photoUrl": photoUrl,
      if (nickname != null) "nickname": nickname,
      if (job != null) "job": job,
      if (createdDate != null) "createdDate": createdDate,
      if (updatedDate != null) "updatedDate": updatedDate,
      if (lastLogin != null) "lastLogin": lastLogin,
    };
  }
}

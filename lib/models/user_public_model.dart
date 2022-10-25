import 'package:cloud_firestore/cloud_firestore.dart';

class UserPublicModel {
  final String? nickname;
  final String? photoUrl;
  final String? job;
  DateTime? createdDate;
  DateTime? updatedDate;
  DateTime? lastLogin;
  final List<String>? groups;

  UserPublicModel({
    this.nickname,
    this.photoUrl,
    this.job,
    this.createdDate,
    this.updatedDate,
    this.lastLogin,
    this.groups,
  });

  UserPublicModel addGroup(String groupId) {
    List<String>? newGroups = [...?groups];
    newGroups.add(groupId);

    UserPublicModel groupAddedUser = UserPublicModel(
      nickname: this.nickname,
      photoUrl: this.photoUrl,
      job: this.job,
      createdDate: this.createdDate,
      updatedDate: DateTime.now(),
      lastLogin: this.lastLogin,
      groups: newGroups,
    );
    return groupAddedUser;
  }

  UserPublicModel leaveGroup(String groupId) {
    List<String>? newGroups = [...?groups];
    newGroups.removeWhere((element) => element == groupId);

    UserPublicModel groupRemovedUser = UserPublicModel(
      nickname: this.nickname,
      photoUrl: this.photoUrl,
      job: this.job,
      createdDate: this.createdDate,
      updatedDate: DateTime.now(),
      lastLogin: this.lastLogin,
      groups: newGroups,
    );
    return groupRemovedUser;
  }

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
      groups: data?["groups"] is Iterable ? List.from(data?["groups"]) : null,
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
      if (groups != null) "groups": groups,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class UserPublicModel {
  final String? nickname;
  String? kakaoNickname;
  String? googleNickname;
  final String? photoUrl;
  String? job;
  DateTime? createdDate;
  DateTime? updatedDate;
  DateTime? lastLogin;
  bool? kakaoSynced; // 카카오 연동 여부
  bool? talkMessageAgreed; // 카카오톡 메세지 수신 동의 여부 (카카오 로그인할때)
  bool? emailNoticeAllowed; // 이메일로 예약 알림 동의 여부
  bool? kakaoNoticeAllowed; // 카카오톡으로 예약 알림 동의 여부 (우리 서비스에서 알림 설정)
  List<String?>? noticeMethods = [];
  final List<String>? groups;

  UserPublicModel({
    this.nickname,
    this.kakaoNickname,
    this.googleNickname,
    this.photoUrl,
    this.job,
    this.createdDate,
    this.updatedDate,
    this.lastLogin,
    this.kakaoSynced,
    this.talkMessageAgreed,
    this.emailNoticeAllowed,
    this.kakaoNoticeAllowed,
    this.noticeMethods,
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
    var noticeMethods = null;
    if (data?["createdDate"] != null) {
      createdDate = data?["createdDate"].toDate();
    }
    if (data?["updatedDate"] != null) {
      updatedDate = data?["updatedDate"].toDate();
    }
    if (data?["lastLogin"] != null) {
      lastLogin = data?["lastLogin"].toDate();
    }
    // if (data?['noticeMethods'] != null) {
    //   noticeMethods =
    // }

    return UserPublicModel(
      nickname: data?["nickname"],
      googleNickname: data?["googleNickname"],
      kakaoNickname: data?["kakaoNickname"],
      photoUrl: data?["photoUrl"],
      job: data?["job"],
      createdDate: createdDate,
      updatedDate: updatedDate,
      lastLogin: lastLogin,
      kakaoSynced: data?["kakaoSynced"],
      talkMessageAgreed: data?["talkMessageAgreed"],
      emailNoticeAllowed: data?["emailNoticeAllowed"],
      kakaoNoticeAllowed: data?["kakaoNoticeAllowed"],
      noticeMethods: data?['noticeMethods'] is Iterable
          ? List.from(data?['noticeMethods'])
          : null,
      groups: data?["groups"] is Iterable ? List.from(data?["groups"]) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (nickname != null) "nickname": nickname,
      if (googleNickname != null) "googleNickname": googleNickname,
      if (kakaoNickname != null) "kakaoNickname": kakaoNickname,
      if (photoUrl != null) "photoUrl": photoUrl,
      if (job != null) "job": job,
      if (createdDate != null) "createdDate": createdDate,
      if (updatedDate != null) "updatedDate": updatedDate,
      if (lastLogin != null) "lastLogin": lastLogin,
      if (kakaoSynced != null) "kakaoSynced": kakaoSynced,
      if (talkMessageAgreed != null) "talkMessageAgreed": talkMessageAgreed,
      if (emailNoticeAllowed != null) "emailNoticeAllowed": emailNoticeAllowed,
      if (kakaoNoticeAllowed != null) "kakaoNoticeAllowed": kakaoNoticeAllowed,
      if (noticeMethods != null) "noticeMethods": noticeMethods,
      if (groups != null) "groups": groups,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final String? updatedBy;
  final String? name;
  final int? headcount;
  final String? imageUrl;
  final String? introduction;
  final List<dynamic>? memberUids; //왜 자꾸 dynamic으로 뜨지? string은 왜 안되는 걸까??
  final String? password;
  // 통상적으로 password 보관하는 방법 다시 찾아보기(그냥 String으로 해도 되는 거 맞아??)

//default Constructor
  GroupModel({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.updatedBy,
    this.name,
    this.headcount,
    this.imageUrl,
    this.introduction,
    this.memberUids,
    this.password,
  });

  factory GroupModel.newGroup({
    String? uid,
    String? name,
    String? imageUrl,
    String? password,
    String? introduction,
  }) {
    return GroupModel(
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
      createdBy: uid,
      updatedBy: uid,
      name: name,
      headcount: 1,
      imageUrl: imageUrl,
      introduction: introduction,
      memberUids: [uid!],
      password: password,
    );
  }

  factory GroupModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return GroupModel(
      id: snapshot.id,
      createdDate: data?['createdDate'].toDate(),
      updatedDate: data?['updatedDate'].toDate(),
      createdBy: data?['createdBy'],
      updatedBy: data?['updatedBy'],
      name: data?['name'],
      headcount: data?['headcount'],
      imageUrl: data?['imageUrl'],
      introduction: data?['introduction'],
      memberUids: data?['memberUids'] is Iterable
          ? List.from(data?['memberUids'])
          : null,
      password: data?['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "createdDate": createdDate,
      "updatedDate": updatedDate,
      "createdBy": createdBy,
      "updatedBy": updatedBy,
      "name": name,
      "headcount": headcount,
      "imageUrl": imageUrl,
      "introduction": introduction,
      "memberUids": memberUids,
      "password": password,
    };
  }

  GroupModel addMember(String uid) {
    int newHeadcount = headcount! + 1;
    List<String>? newMemberUids = [...?memberUids];
    newMemberUids.add(uid);

    GroupModel memberAddedGroup = GroupModel(
      id: this.id,
      createdDate: this.createdDate,
      updatedDate: DateTime.now(),
      createdBy: this.createdBy,
      updatedBy: uid,
      name: this.name,
      headcount: newHeadcount,
      imageUrl: this.imageUrl,
      introduction: this.introduction,
      memberUids: newMemberUids,
      password: this.password,
    );
    return memberAddedGroup;
  }

  GroupModel removeMember(String uid) {
    late int newHeadcount;
    List<String>? newMemberUids = [...?memberUids];
    if (newMemberUids.contains(uid)) {
      newMemberUids.removeWhere((element) => element == uid);
      newHeadcount = headcount! - 1;
    } else {
      newHeadcount = headcount!;
    }

    GroupModel memberRemovedGroup = GroupModel(
      id: this.id,
      createdDate: this.createdDate,
      updatedDate: DateTime.now(),
      createdBy: this.createdBy,
      updatedBy: uid,
      name: this.name,
      headcount: newHeadcount,
      imageUrl: this.imageUrl,
      introduction: this.introduction,
      memberUids: newMemberUids,
      password: this.password,
    );
    return memberRemovedGroup;
  }

  GroupModel modifyInfo({
    required String newName,
    required String newImageUrl,
    required String newPassword,
    required String newIntroduction,
    required String newUpdatedBy,
  }) {
    GroupModel modifiedGroup = GroupModel(
      id: this.id,
      createdDate: this.createdDate,
      updatedDate: DateTime.now(),
      createdBy: this.createdBy,
      updatedBy: newUpdatedBy,
      name: newName,
      headcount: this.headcount,
      imageUrl: newImageUrl,
      introduction: newIntroduction,
      memberUids: this.memberUids,
      password: newPassword,
    );
    return modifiedGroup;
  }

  GroupModel changeImageAndPutId({
    required String docId,
    required String newImageUrl,
    required String newUpdatedBy,
  }) {
    GroupModel modifiedGroup = GroupModel(
      id: docId,
      createdDate: this.createdDate,
      updatedDate: DateTime.now(),
      createdBy: this.createdBy,
      updatedBy: newUpdatedBy,
      name: this.name,
      headcount: this.headcount,
      imageUrl: newImageUrl,
      introduction: this.introduction,
      memberUids: this.memberUids,
      password: this.password,
    );
    return modifiedGroup;
  }
}

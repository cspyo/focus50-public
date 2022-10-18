import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String? id;
  final String? category;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final String? updatedBy;
  final String? name;
  final int? headcount;
  final String? imageUrl;
  final String? introduction;
  final int? maxHeadcount;
  final List<dynamic>? memberUids; //왜 자꾸 dynamic으로 뜨지? string은 왜 안되는 걸까??
  final String? password;
  // 통상적으로 password 보관하는 방법 다시 찾아보기(그냥 String으로 해도 되는 거 맞아??)

//default Constructor
  GroupModel({
    this.id,
    this.category,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.updatedBy,
    this.name,
    this.headcount,
    this.imageUrl,
    this.introduction,
    this.maxHeadcount,
    this.memberUids,
    this.password,
  });

  factory GroupModel.newGroup({
    String? uid,
    String? name,
    String? category,
    String? imageUrl,
    int? maxHeadcount,
    String? password,
    String? introduction,
  }) {
    return GroupModel(
      category: category,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
      createdBy: uid,
      updatedBy: uid,
      name: name,
      headcount: 1,
      imageUrl: imageUrl,
      introduction: introduction,
      maxHeadcount: maxHeadcount,
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
      category: data?['category'],
      createdDate: data?['createdDate'].toDate(),
      updatedDate: data?['updatedDate'].toDate(),
      createdBy: data?['createdBy'],
      updatedBy: data?['updatedBy'],
      name: data?['name'],
      headcount: data?['headcount'],
      imageUrl: data?['imageUrl'],
      introduction: data?['introduction'],
      maxHeadcount: data?['maxHeadcount'],
      memberUids: data?['memberUids'] is Iterable
          ? List.from(data?['memberUids'])
          : null,
      password: data?['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "category": category,
      "createdDate": createdDate,
      "updatedDate": updatedDate,
      "createdBy": createdBy,
      "updatedBy": updatedBy,
      "name": name,
      "headcount": headcount,
      "imageUrl": imageUrl,
      "introduction": introduction,
      "maxHeadcount": maxHeadcount,
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
      category: this.category,
      createdDate: this.createdDate,
      updatedDate: DateTime.now(),
      createdBy: this.createdBy,
      updatedBy: uid,
      name: this.name,
      headcount: newHeadcount,
      imageUrl: this.imageUrl,
      introduction: this.introduction,
      maxHeadcount: this.maxHeadcount,
      memberUids: newMemberUids,
      password: this.password,
    );
    return memberAddedGroup;
  }

  GroupModel removeMember(String uid) {
    int newHeadcount = headcount! - 1;
    List<String>? newMemberUids = [...?memberUids];
    newMemberUids.removeWhere((element) => element == uid);

    GroupModel memberRemovedGroup = GroupModel(
      id: this.id,
      category: this.category,
      createdDate: this.createdDate,
      updatedDate: DateTime.now(),
      createdBy: this.createdBy,
      updatedBy: uid,
      name: this.name,
      headcount: newHeadcount,
      imageUrl: this.imageUrl,
      introduction: this.introduction,
      maxHeadcount: this.maxHeadcount,
      memberUids: newMemberUids,
      password: this.password,
    );
    return memberRemovedGroup;
  }
}

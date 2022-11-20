import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  String? id;
  final DateTime? createdDate;
  final String? createdBy;
  final String? reportReason;
  final String? reservationId;
  final List<String>? reportMemebers;
  ReportModel(
      {this.id,
      this.createdDate,
      this.createdBy,
      this.reportReason,
      this.reservationId,
      this.reportMemebers});

  factory ReportModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return ReportModel(
      id: snapshot.id,
      createdDate: data?['createdDate'].toDate(),
      createdBy: data?['createdBy'],
      reportReason: data?['reportReason'],
      reservationId: data?['reservationId'],
      reportMemebers: data?['reportMembers'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "createdDate": createdDate,
      "createdBy": createdBy,
      "reportReason": reportReason,
      "reservationInfo": reservationId,
      "reportMembers": reportMemebers,
    };
  }

  // ReportModel addMember(String uid) {
  //   // int newHeadcount = headcount! + 1;
  //   // List<String>? newMemberUids = [...?memberUids];
  //   // newMemberUids.add(uid);

  //    memberAddedGroup = GroupModel(
  //     id: this.id,
  //     createdDate: this.createdDate,
  //     updatedDate: DateTime.now(),
  //     createdBy: this.createdBy,
  //     updatedBy: uid,
  //     name: this.name,
  //     headcount: newHeadcount,
  //     imageUrl: this.imageUrl,
  //     introduction: this.introduction,
  //     memberUids: newMemberUids,
  //     password: this.password,
  //   );
  //   return memberAddedGroup;
  // }

  // GroupModel removeMember(String uid) {
  //   late int newHeadcount;
  //   List<String>? newMemberUids = [...?memberUids];
  //   if (newMemberUids.contains(uid)) {
  //     newMemberUids.removeWhere((element) => element == uid);
  //     newHeadcount = headcount! - 1;
  //   } else {
  //     newHeadcount = headcount!;
  //   }

  //   GroupModel memberRemovedGroup = GroupModel(
  //     id: this.id,
  //     createdDate: this.createdDate,
  //     updatedDate: DateTime.now(),
  //     createdBy: this.createdBy,
  //     updatedBy: uid,
  //     name: this.name,
  //     headcount: newHeadcount,
  //     imageUrl: this.imageUrl,
  //     introduction: this.introduction,
  //     memberUids: newMemberUids,
  //     password: this.password,
  //   );
  //   return memberRemovedGroup;
  // }

  // GroupModel modifyInfo({
  //   required String newName,
  //   required String newImageUrl,
  //   required String newPassword,
  //   required String newIntroduction,
  //   required String newUpdatedBy,
  // }) {
  //   GroupModel modifiedGroup = GroupModel(
  //     id: this.id,
  //     createdDate: this.createdDate,
  //     updatedDate: DateTime.now(),
  //     createdBy: this.createdBy,
  //     updatedBy: newUpdatedBy,
  //     name: newName,
  //     headcount: this.headcount,
  //     imageUrl: newImageUrl,
  //     introduction: newIntroduction,
  //     memberUids: this.memberUids,
  //     password: newPassword,
  //   );
  //   return modifiedGroup;
  // }

  // GroupModel changeImageAndPutId({
  //   required String docId,
  //   required String newImageUrl,
  //   required String newUpdatedBy,
  // }) {
  //   GroupModel modifiedGroup = GroupModel(
  //     id: docId,
  //     createdDate: this.createdDate,
  //     updatedDate: DateTime.now(),
  //     createdBy: this.createdBy,
  //     updatedBy: newUpdatedBy,
  //     name: this.name,
  //     headcount: this.headcount,
  //     imageUrl: newImageUrl,
  //     introduction: this.introduction,
  //     memberUids: this.memberUids,
  //     password: this.password,
  //   );
  //   return modifiedGroup;
  // }
}

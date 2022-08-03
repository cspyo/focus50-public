import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  String? pk;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? user1Uid;
  final String? user1Name;
  final DateTime? user1EnterDTTM;
  final String? user2Uid;
  final String? user2Name;
  final DateTime? user2EnterDTTM;
  final bool? isFull;
  final String? room;

//default Constructor
  ReservationModel({
    this.pk,
    this.startTime,
    this.endTime,
    this.user1Uid,
    this.user1Name,
    this.user1EnterDTTM,
    this.user2Uid,
    this.user2Name,
    this.user2EnterDTTM,
    this.isFull,
    this.room,
  });

  bool isEmptyUser1() {
    return this.user1Uid == null;
  }

  bool isInUser1(String userId) {
    return this.user1Uid == userId;
  }

  bool isInUser2(String userId) {
    return this.user2Uid == userId;
  }

  factory ReservationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    // Timestamp? startTimeStamp = data?['startTime'];
    // Timestamp? endTimeStamp = data?['endTime'];
    return ReservationModel(
      // startTime: DateTime.fromMillisecondsSinceEpoch(
      //     startTimeStamp!.millisecondsSinceEpoch),
      // endTime: DateTime.fromMillisecondsSinceEpoch(
      //     endTimeStamp!.millisecondsSinceEpoch),
      startTime: data?['startTime']?.toDate(),
      endTime: data?['endTime']?.toDate(),
      user1Uid: data?['user1Uid'],
      user1Name: data?['user1Name'],
      user1EnterDTTM: data?['user1EnterDTTM']?.toDate(),
      user2Uid: data?['user2Uid'],
      user2Name: data?['user2Name'],
      user2EnterDTTM: data?['user2EnterDTTM']?.toDate(),
      isFull: data?['isFull'],
      room: data?['room'],
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      "startTime": startTime,
      "endTime": endTime,
      "user1Uid": user1Uid,
      "user1Name": user1Name,
      "user1EnterDTTM": user1EnterDTTM,
      "user2Uid": user2Uid,
      "user2Name": user2Name,
      "user2EnterDTTM": user2EnterDTTM,
      "isFull": isFull,
      "room": room,
    };
  }
}

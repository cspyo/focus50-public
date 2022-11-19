import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus42/models/reservation_user_info.dart';

class ReservationModel {
  String? id;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool? isFull;
  final int? headcount;
  final int? maxHeadcount;
  final List<String>? userIds;
  final Map<String, ReservationUserInfo>? userInfos;
  final String? groupId;

//default Constructor
  ReservationModel({
    this.id,
    this.startTime,
    this.endTime,
    this.isFull,
    this.headcount,
    this.maxHeadcount,
    this.userIds,
    this.userInfos,
    this.groupId,
  });

  ReservationModel addUser(String uid, ReservationUserInfo userInfo) {
    int newHeadcount = headcount! + 1;
    bool newIsFull = false;
    if (newHeadcount >= maxHeadcount!) {
      newIsFull = true;
    }
    List<String>? newUserIds = [...?userIds];
    newUserIds.add(uid);

    Map<String, ReservationUserInfo>? newUserInfos = {...?userInfos};
    newUserInfos.addAll({uid: userInfo});

    ReservationModel userAddedReservation = ReservationModel(
      id: this.id,
      startTime: this.startTime,
      endTime: this.endTime,
      isFull: newIsFull,
      headcount: newHeadcount,
      maxHeadcount: this.maxHeadcount,
      userIds: newUserIds,
      userInfos: newUserInfos,
      groupId: this.groupId,
    );
    return userAddedReservation;
  }

  ReservationModel deleteUser(String uid) {
    int newHeadcount = headcount! - 1;
    bool newIsFull = false;

    List<String>? newUserIds = [...userIds!];
    newUserIds.remove(uid);

    Map<String, ReservationUserInfo> newUserInfos = {...userInfos!};
    newUserInfos.remove(uid);

    ReservationModel userDeletedReservation = ReservationModel(
      id: this.id,
      startTime: this.startTime,
      endTime: this.endTime,
      isFull: newIsFull,
      headcount: newHeadcount,
      maxHeadcount: this.maxHeadcount,
      userIds: newUserIds,
      userInfos: newUserInfos,
      groupId: this.groupId,
    );
    return userDeletedReservation;
  }

  ReservationModel updateUserInfo(String uid, ReservationUserInfo userInfo) {
    Map<String, ReservationUserInfo> newUserInfos = {...userInfos!};
    newUserInfos.remove(uid);
    newUserInfos.addAll({uid: userInfo});

    ReservationModel userUpdatedReservation = ReservationModel(
      id: this.id,
      startTime: this.startTime,
      endTime: this.endTime,
      isFull: this.isFull,
      headcount: this.headcount,
      maxHeadcount: this.maxHeadcount,
      userIds: this.userIds,
      userInfos: newUserInfos,
      groupId: this.groupId,
    );
    return userUpdatedReservation;
  }

  factory ReservationModel.newReservation({
    required DateTime startTime,
    required DateTime endTime,
    String? groupId,
  }) {
    return ReservationModel(
      startTime: startTime,
      endTime: endTime,
      isFull: false,
      headcount: 0,
      maxHeadcount: 4,
      userIds: [],
      userInfos: {},
      groupId: groupId,
    );
  }

  factory ReservationModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    String documentId = snapshot.id;
    final data = snapshot.data() as Map<String, dynamic>;

    Map<String, dynamic> userInfos = data["userInfos"] as Map<String, dynamic>;
    Map<String, ReservationUserInfo> userInfoMap =
        <String, ReservationUserInfo>{};

    final userInfoKeyList = userInfos.keys.toList();
    for (int i = 0; i < userInfoKeyList.length; i++) {
      final value = userInfos[userInfoKeyList[i]];
      String? uid = value['uid'] as String?;
      String? nickname = value['nickname'] as String?;
      if (uid == null || nickname == null) continue;

      DateTime? enterDTTM = value['enterDTTM'] != null
          ? value['enterDTTM'].toDate() as DateTime
          : null;
      DateTime? leaveDTTM = value['leaveDTTM'] != null
          ? value['leaveDTTM'].toDate() as DateTime
          : null;
      DateTime? reserveDTTM = value['reserveDTTM'] != null
          ? value['reserveDTTM'].toDate() as DateTime
          : null;
      String? reservationVersion = value['reservationVersion'] as String?;
      String? reservationAgent = value['reservationAgent'] as String?;
      String? sessionVersion = value['sessionVersion'] as String?;
      String? sessionAgent = value['sessionAgent'] as String?;

      ReservationUserInfo reservationUserInfo = new ReservationUserInfo(
        uid: uid,
        nickname: nickname,
        enterDTTM: enterDTTM,
        leaveDTTM: leaveDTTM,
        reserveDTTM: reserveDTTM,
        reservationVersion: reservationVersion,
        reservationAgent: reservationAgent,
        sessionVersion: sessionVersion,
        sessionAgent: sessionAgent,
      );
      userInfoMap.addAll({uid: reservationUserInfo});
    }

    return ReservationModel(
      id: documentId,
      startTime: data['startTime']?.toDate() as DateTime,
      endTime: data['endTime']?.toDate() as DateTime,
      isFull: data['isFull'],
      headcount: data['headcount'],
      maxHeadcount: 4,
      userIds: data['userIds'] is Iterable ? List.from(data['userIds']) : null,
      userInfos: userInfoMap,
      groupId: data['groupId'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic>? userInfoMap = {};

    userInfos?.forEach((key, value) {
      userInfoMap.addAll({key: value.toMap()});
    });

    return <String, dynamic>{
      if (id != null) "id": id,
      if (startTime != null) "startTime": startTime,
      if (endTime != null) "endTime": endTime,
      if (isFull != null) "isFull": isFull,
      if (headcount != null) "headcount": headcount,
      if (maxHeadcount != null) "maxHeadcount": maxHeadcount,
      if (userIds != null) "userIds": userIds,
      if (userInfoMap != null) "userInfos": userInfoMap,
      if (groupId != null) "groupId": groupId,
    };
  }
}

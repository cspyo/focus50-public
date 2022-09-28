import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus42/models/reservation_user_info.dart';

class ReservationModel {
  String? id;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool? isFull;
  final String? roomId;
  final int? headcount;
  final int? maxHeadcount;
  final List<String>? userIds;
  final Map<String, ReservationUserInfo>? userInfos;

//default Constructor
  ReservationModel({
    this.id,
    this.startTime,
    this.endTime,
    this.isFull,
    this.roomId,
    this.headcount,
    this.maxHeadcount,
    this.userIds,
    this.userInfos,
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
      roomId: this.roomId,
      headcount: newHeadcount,
      maxHeadcount: this.maxHeadcount,
      userIds: newUserIds,
      userInfos: newUserInfos,
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
      roomId: this.roomId,
      headcount: newHeadcount,
      maxHeadcount: this.maxHeadcount,
      userIds: newUserIds,
      userInfos: newUserInfos,
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
      roomId: this.roomId,
      headcount: this.headcount,
      maxHeadcount: this.maxHeadcount,
      userIds: this.userIds,
      userInfos: newUserInfos,
    );
    return userUpdatedReservation;
  }

  ReservationModel doEnter(String uid) {
    assert(this.userInfos!.containsKey(uid));
    Map<String, ReservationUserInfo>? updatedUserInfo = this.userInfos;
    updatedUserInfo!.update(
      uid,
      (value) => ReservationUserInfo(
        enterDTTM: DateTime.now(),
        leaveDTTM: value.leaveDTTM,
        nickname: value.nickname,
        uid: value.uid,
      ),
    );
    ReservationModel enteredReservation = ReservationModel(
      id: this.id,
      startTime: this.startTime,
      endTime: this.endTime,
      isFull: this.isFull,
      roomId: this.roomId,
      headcount: this.headcount,
      maxHeadcount: this.maxHeadcount,
      userIds: this.userIds,
      userInfos: updatedUserInfo,
    );
    return enteredReservation;
  }

  ReservationModel doLeave(String uid) {
    assert(this.userInfos!.containsKey(uid));
    print("doLeave");
    Map<String, ReservationUserInfo>? updatedUserInfo = this.userInfos;
    updatedUserInfo!.update(
      uid,
      (value) => ReservationUserInfo(
        enterDTTM: value.enterDTTM,
        leaveDTTM: DateTime.now(),
        nickname: value.nickname,
        uid: value.uid,
      ),
    );
    ReservationModel leavedReservation = ReservationModel(
      id: this.id,
      startTime: this.startTime,
      endTime: this.endTime,
      isFull: this.isFull,
      roomId: this.roomId,
      headcount: this.headcount,
      maxHeadcount: this.maxHeadcount,
      userIds: this.userIds,
      userInfos: updatedUserInfo,
    );
    return leavedReservation;
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
    userInfos.forEach((key, value) {
      String uid = value['uid'] as String;
      String? nickname = value['nickname'] as String;
      DateTime? enterDTTM = value['enterDTTM'] != null
          ? value['enterDTTM'].toDate() as DateTime
          : null;
      DateTime? leaveDTTM = value['leaveDTTM'] != null
          ? value['leaveDTTM'].toDate() as DateTime
          : null;

      ReservationUserInfo reservationUserInfo = new ReservationUserInfo(
        uid: uid,
        nickname: nickname,
        enterDTTM: enterDTTM,
        leaveDTTM: leaveDTTM,
      );
      userInfoMap.addAll({uid: reservationUserInfo});
    });

    return ReservationModel(
      id: documentId,
      startTime: data['startTime']?.toDate() as DateTime,
      endTime: data['endTime']?.toDate() as DateTime,
      isFull: data['isFull'],
      roomId: data['roomId'],
      headcount: data['headcount'],
      maxHeadcount: 2,
      userIds: data['userIds'] is Iterable ? List.from(data['userIds']) : null,
      userInfos: userInfoMap,
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
      if (roomId != null) "roomId": roomId,
      if (headcount != null) "headcount": headcount,
      if (maxHeadcount != null) "maxHeadcount": maxHeadcount,
      if (userIds != null) "userIds": userIds,
      if (userInfoMap != null) "userInfos": userInfoMap,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus42/models/reservation_model.dart';

class PeerFeedbackModel {
  String? id;
  final String? fromUid;
  final String? fromNickname;
  final String? fromPhotoUrl;
  final String? toUid;
  final String? contentCode;
  final String? contentText;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final bool? isShowed;
  final ReservationModel? reservationDetail;

//default Constructor
  PeerFeedbackModel({
    this.id,
    this.fromUid,
    this.fromNickname,
    this.fromPhotoUrl,
    this.toUid,
    this.contentCode,
    this.contentText,
    this.createdDate,
    this.updatedDate,
    this.isShowed,
    this.reservationDetail,
  });

  factory PeerFeedbackModel.newPeerFeedback({
    required String fromUid,
    required String fromNickname,
    required String fromPhotoUrl,
    required String toUid,
    required String contentCode,
    required String contentText,
    required ReservationModel reservationDetail,
  }) {
    DateTime now = DateTime.now();
    return PeerFeedbackModel(
      fromUid: fromUid,
      fromNickname: fromNickname,
      fromPhotoUrl: fromPhotoUrl,
      toUid: toUid,
      contentCode: contentCode,
      contentText: contentText,
      createdDate: now,
      updatedDate: now,
      isShowed: false,
      reservationDetail: reservationDetail,
    );
  }

  factory PeerFeedbackModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final ReservationModel reservationDetail = new ReservationModel(
      id: data?['reservationDetail']['id'],
      startTime: data?['reservationDetail']['startTime']?.toDate() as DateTime,
      endTime: data?['reservationDetail']['endTime']?.toDate() as DateTime,
      headcount: data?['reservationDetail']['headcount'],
      userIds: data?['reservationDetail']['userIds'] is Iterable
          ? List.from(data?['reservationDetail']['userIds'])
          : null,
      groupId: data?['reservationDetail']['groupId'],
    );

    return PeerFeedbackModel(
      id: snapshot.id,
      fromUid: data?['fromUid'],
      fromNickname: data?['fromNickname'],
      fromPhotoUrl: data?['fromPhotoUrl'],
      toUid: data?['toUid'],
      contentCode: data?['contentCode'],
      contentText: data?['contentText'],
      createdDate: data?['createdDate']?.toDate() as DateTime,
      updatedDate: data?['updatedDate']?.toDate() as DateTime,
      isShowed: data?['isShowed'],
      reservationDetail: reservationDetail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (fromUid != null) 'fromUid': fromUid,
      if (fromNickname != null) 'fromNickname': fromNickname,
      if (fromPhotoUrl != null) 'fromPhotoUrl': fromPhotoUrl,
      if (toUid != null) 'toUid': toUid,
      if (contentCode != null) 'contentCode': contentCode,
      if (contentText != null) 'contentText': contentText,
      if (createdDate != null) 'createdDate': createdDate,
      if (updatedDate != null) 'updatedDate': updatedDate,
      if (isShowed != null) 'isShowed': isShowed,
      if (reservationDetail != null)
        'reservationDetail': reservationDetail!.toMap(),
    };
  }

  PeerFeedbackModel doShow() {
    PeerFeedbackModel showedPeerFeedback = PeerFeedbackModel(
      id: this.id,
      isShowed: true,
      updatedDate: DateTime.now(),
    );
    return showedPeerFeedback;
  }
}

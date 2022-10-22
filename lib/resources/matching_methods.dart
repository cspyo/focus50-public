import 'package:flutter/foundation.dart';
import 'package:focus42/main.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/models/reservation_user_info.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:logger/logger.dart';

class MatchingMethods {
  late String userId;
  late String? userName;
  var userData = {};
  String? nickname;
  var logger = Logger();
  final FirestoreDatabase database;
  late UserPublicModel? user;

  MatchingMethods({required this.database}) {
    this.userId = database.uid;
  }

  Future<void> matchRoom({
    required DateTime startTime,
    required DateTime endTime,
    String? groupId,
  }) async {
    user = await database.getUserPublic();
    userName = user!.nickname;

    database.runTransaction((transaction) async {
      ReservationModel? notFullReservation =
          await database.findReservationForMatch(
              startTime: startTime, groupId: groupId, transaction: transaction);
      if (notFullReservation == null) {
        ReservationModel newReservation = ReservationModel.newReservation(
          startTime: startTime,
          endTime: endTime,
          groupId: groupId,
        );
        database.setReservation(newReservation.addUser(
            userId,
            ReservationUserInfo(
                uid: userId,
                nickname: userName,
                reservationAgent: AGENT,
                reservationVersion: VERSION)));
      } else {
        database.updateReservationInTransaction(
          notFullReservation.addUser(
              userId,
              ReservationUserInfo(
                  uid: userId,
                  nickname: userName,
                  reservationAgent: AGENT,
                  reservationVersion: VERSION)),
          transaction,
        );
      }
    });
  }

  Future<void> cancelRoom(String docId) async {
    database.runTransaction((transaction) async {
      ReservationModel reservation =
          await database.getReservationInTransaction(docId, transaction);
      ReservationModel cancelReservation = reservation.deleteUser(userId);
      if (cancelReservation.headcount == 0) {
        database.deleteReservationInTransaction(cancelReservation, transaction);
      } else {
        database.updateReservationInTransaction(cancelReservation, transaction);
      }
    });
  }

  Future<void> leaveRoom(String docId) async {
    database.runTransaction((transaction) async {
      late ReservationModel reservation;
      try {
        reservation =
            await database.getReservationInTransaction(docId, transaction);
      } catch (e) {
        debugPrint("${e}");
        return;
      }
      if (reservation.userInfos != null &&
          reservation.userInfos!.containsKey(database.uid)) {
        database.updateReservationUserInfoInTransaction(
            docId, database.uid, "leaveDTTM", DateTime.now(), transaction);
      }
    });
  }
}

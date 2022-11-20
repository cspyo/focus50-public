import 'package:flutter/foundation.dart';
import 'package:focus50/feature/auth/data/user_public_model.dart';
import 'package:focus50/feature/calendar/data/reservation_model.dart';
import 'package:focus50/feature/calendar/data/reservation_user_info.dart';
import 'package:focus50/main.dart';
import 'package:focus50/services/firestore_database.dart';
import 'package:logger/logger.dart';

class MatchingMethods {
  static MatchingMethods? _instance;

  MatchingMethods._({required this.database}) {
    debugPrint("[DEBUG] matching method created");
    this.userId = database.uid;
  }

  factory MatchingMethods({required database}) {
    if (_instance == null ||
        _instance!.database.hashCode != database.hashCode) {
      return _instance = MatchingMethods._(database: database);
    } else {
      return _instance!;
    }
  }

  late String userId;
  late String? userName;
  var userData = {};
  String? nickname;
  var logger = Logger();
  final FirestoreDatabase database;
  late UserPublicModel? user;

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
              reservationVersion: VERSION,
              reserveDTTM: DateTime.now(),
            )));
      } else {
        database.updateReservationInTransaction(
          notFullReservation.addUser(
              userId,
              ReservationUserInfo(
                uid: userId,
                nickname: userName,
                reservationAgent: AGENT,
                reservationVersion: VERSION,
                reserveDTTM: DateTime.now(),
              )),
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
    final ReservationModel reservation = await database.getReservation(docId);
    if (reservation.userInfos != null &&
        reservation.userInfos!.containsKey(database.uid)) {
      database.updateReservationUserInfo(
          docId, database.uid, "leaveDTTM", DateTime.now());
    }
  }
}

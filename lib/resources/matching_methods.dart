import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/models/reservation_user_info.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/utils/signaling.dart';
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
  }) async {
    /* matchRoom
     * 1. 시간으로 필터링을 해서 튜플을 찾는다
     * 2-1. 있다
     * 3. 들어간다. 디비에 빈 유저 필드에 <- 자기 아이디 , isFull <- 1 업데이트 한다.
     * 2-2. 없다
     * 3-2. 만든다.
    */
    // 트랜잭션 어떻게 하면 좋을지 아예 모르겠음...
    user = await database.getUserPublic();
    userName = user!.nickname;

    database.runTransaction((transaction) async {
      ReservationModel? notFullReservation =
          await database.findReservationForMatch(
              startTime: startTime, transaction: transaction);
      if (notFullReservation == null) {
        ReservationModel newReservation = ReservationModel(
            startTime: startTime,
            endTime: endTime,
            headcount: 0,
            isFull: false,
            maxHeadcount: 4,
            roomId: null,
            userIds: [],
            userInfos: {});
        database.setReservation(newReservation.addUser(
            userId, ReservationUserInfo(uid: userId, nickname: userName)));
      } else {
        database.updateReservationInTransaction(
          notFullReservation.addUser(
              userId, ReservationUserInfo(uid: userId, nickname: userName)),
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

  Future<void> enterRoom(
    String docId,
    Signaling signaling,
    RTCVideoRenderer localRenderer,
    RTCVideoRenderer remoteRenderer,
  ) async {
    await signaling.openUserMedia(localRenderer, remoteRenderer);
    signaling.peerClose();
    user = await database.getUserPublic();
    userName = user!.nickname;

    ReservationModel reservation = await database.getReservation(docId);

    String? roomId = reservation.roomId;
    if (roomId == null) {
      roomId = await signaling.createRoom(remoteRenderer);
    } else {
      signaling.joinRoom(roomId, remoteRenderer);
    }
    ReservationUserInfo updateUserInfo = ReservationUserInfo(
        enterDTTM: DateTime.now(),
        leaveDTTM: null,
        nickname: userName,
        uid: userId);
    database.setReservation(reservation.updateUserInfo(userId, updateUserInfo));
  }
}

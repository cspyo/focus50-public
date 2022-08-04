import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/utils/signaling.dart';
import 'package:logger/logger.dart';

class MatchingMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String userId;
  late String? userName;
  late CollectionReference _reservationColRef;
  final FirebaseAuth _user = FirebaseAuth.instance;
  var userData = {};
  String? nickName;
  var logger = Logger();

  MatchingMethods() {
    this.userId = _user.currentUser!.uid;
    this.userName = nickName;
    this._reservationColRef =
        _firestore.collection('reservation').withConverter<ReservationModel>(
              fromFirestore: ReservationModel.fromFirestore,
              toFirestore: (ReservationModel reservationModel, _) =>
                  reservationModel.toFirestore(),
            );
  }

  Future<void> getUserName() async {
    try {
      var userSnap = await _firestore
          .collection('users')
          .doc(_user.currentUser!.uid)
          .get();

      userData = userSnap.data()!;
      nickName = userData['nickname'];
    } catch (e) {
      logger.d("getUserName catch:$e");
    }
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
    await getUserName();
    this.userName = nickName;
    String docId = '';
    return _firestore.runTransaction((transaction) async {
      await _reservationColRef
          .where('startTime', isEqualTo: Timestamp.fromDate(startTime))
          .where('isFull', isEqualTo: false)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.size > 0) {
          DocumentReference reservationRef =
              _reservationColRef.doc(querySnapshot.docs.first.id);
          docId = reservationRef.id;
          DocumentSnapshot reservationSnap =
              await transaction.get(reservationRef);

          if (!reservationSnap.exists) {
            throw Exception("reservation does not exist!");
          }

          final ReservationModel reservation = ReservationModel.fromFirestore(
              reservationSnap as DocumentSnapshot<Map<String, dynamic>>, null);
          ReservationModel newReservation;
          if (reservation.isEmptyUser1()) {
            newReservation = ReservationModel(
              startTime: reservation.startTime,
              endTime: reservation.endTime,
              user1Uid: userId,
              user1Name: userName,
              user1EnterDTTM: reservation.user1EnterDTTM,
              user2Uid: reservation.user2Uid,
              user2Name: reservation.user2Name,
              user2EnterDTTM: reservation.user2EnterDTTM,
              isFull: true,
              room: reservation.room,
            );
          } else {
            newReservation = ReservationModel(
              startTime: reservation.startTime,
              endTime: reservation.endTime,
              user1Uid: reservation.user1Uid,
              user1Name: reservation.user1Name,
              user1EnterDTTM: reservation.user1EnterDTTM,
              user2Uid: userId,
              user2Name: userName,
              user2EnterDTTM: reservation.user2EnterDTTM,
              isFull: true,
              room: reservation.room,
            );
          }
          transaction.update(reservationRef, newReservation.toFirestore());
        } else {
          ReservationModel newReservation = ReservationModel(
              startTime: startTime,
              endTime: endTime,
              user1Uid: userId,
              user1Name: userName,
              user1EnterDTTM: null,
              user2Uid: null,
              user2Name: null,
              user2EnterDTTM: null,
              isFull: false,
              room: null);
          DocumentReference doc = await _reservationColRef.add(newReservation);
          docId = doc.id;
        }
      });
    });
  }

  Future<void> cancelRoom(String _docId) async {
    return _firestore.runTransaction((transaction) async {
      DocumentReference reservationRef = _reservationColRef.doc(_docId);
      DocumentSnapshot reservationSnap = await transaction.get(reservationRef);
      final ReservationModel reservation = ReservationModel.fromFirestore(
          reservationSnap as DocumentSnapshot<Map<String, dynamic>>, null);
      if (reservation.isInUser1(userId) && reservation.user2Uid != null) {
        ReservationModel newReservation = ReservationModel(
          startTime: reservation.startTime,
          endTime: reservation.endTime,
          user1Uid: null,
          user1Name: null,
          user1EnterDTTM: null,
          user2Uid: reservation.user2Uid,
          user2Name: reservation.user2Name,
          user2EnterDTTM: reservation.user2EnterDTTM,
          isFull: false,
          room: reservation.room,
        );
        transaction.update(reservationRef, newReservation.toFirestore());
      } else if (reservation.isInUser1(userId) &&
          reservation.user2Uid == null) {
        transaction.delete(reservationRef);
      } else if (reservation.isInUser2(userId) &&
          reservation.user1Uid != null) {
        ReservationModel newReservation = ReservationModel(
          startTime: reservation.startTime,
          endTime: reservation.endTime,
          user1Uid: reservation.user1Uid,
          user1Name: reservation.user1Name,
          user1EnterDTTM: reservation.user1EnterDTTM,
          user2Uid: null,
          user2Name: null,
          user2EnterDTTM: null,
          isFull: false,
          room: reservation.room,
        );
        transaction.update(reservationRef, newReservation.toFirestore());
      } else if (reservation.isInUser2(userId) &&
          reservation.user1Uid == null) {
        transaction.delete(reservationRef);
      } else {
        throw Exception("There is not rooms for cancellation!");
      }
    });
  }

  Future<void> enterRoom(
    String _docId,
    Signaling signaling,
    RTCVideoRenderer localRenderer,
    RTCVideoRenderer remoteRenderer,
  ) async {
    await signaling.openUserMedia(localRenderer, remoteRenderer);
    signaling.peerClose();
    DocumentReference reservationRef = _reservationColRef.doc(_docId);
    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot reservationSnap = await transaction.get(reservationRef);
      final ReservationModel reservation = ReservationModel.fromFirestore(
          reservationSnap as DocumentSnapshot<Map<String, dynamic>>, null);
      String? roomId = reservation.room;
      if (roomId == null) {
        roomId = await signaling.createRoom(remoteRenderer);
      } else {
        signaling.joinRoom(roomId, remoteRenderer);
      }
      ReservationModel? newReservation;
      if (reservation.user1Uid == userId) {
        newReservation = ReservationModel(
          startTime: reservation.startTime,
          endTime: reservation.endTime,
          user1Uid: reservation.user1Uid,
          user1Name: reservation.user1Name,
          user1EnterDTTM: DateTime.now(),
          user2Uid: reservation.user2Uid,
          user2Name: reservation.user2Name,
          user2EnterDTTM: reservation.user2EnterDTTM,
          room: roomId,
          isFull: reservation.isFull,
        );
      } else if (reservation.user2Uid == userId) {
        newReservation = ReservationModel(
          startTime: reservation.startTime,
          endTime: reservation.endTime,
          user1Uid: reservation.user1Uid,
          user1Name: reservation.user1Name,
          user1EnterDTTM: reservation.user1EnterDTTM,
          user2Uid: reservation.user2Uid,
          user2Name: reservation.user2Name,
          user2EnterDTTM: DateTime.now(),
          room: roomId,
          isFull: reservation.isFull,
        );
      }
      transaction.update(reservationRef, newReservation!.toFirestore());
    });
  }
}

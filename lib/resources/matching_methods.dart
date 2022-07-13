import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/utils/signaling.dart';

class MatchingMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _user = FirebaseAuth.instance;
  late String userId;
  late String? userName;
  late CollectionReference _reservationColRef;

  MatchingMethods() {
    this.userId = _user.currentUser!.uid;
    this.userName = _user.currentUser?.displayName;
    this._reservationColRef =
        _firestore.collection('reservation').withConverter<ReservationModel>(
              fromFirestore: ReservationModel.fromFirestore,
              toFirestore: (ReservationModel reservationModel, _) =>
                  reservationModel.toFirestore(),
            );
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
    String docId = '';
    _firestore.runTransaction((transaction) async {
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
                user2Uid: reservation.user2Uid,
                user2Name: reservation.user2Name,
                isFull: true,
                room: null);
          } else {
            newReservation = ReservationModel(
                startTime: reservation.startTime,
                endTime: reservation.endTime,
                user1Uid: reservation.user1Uid,
                user1Name: reservation.user1Name,
                user2Uid: userId,
                user2Name: userName,
                isFull: true,
                room: null);
          }
          transaction.update(reservationRef, newReservation.toFirestore());
        } else {
          ReservationModel newReservation = ReservationModel(
              startTime: startTime,
              endTime: endTime,
              user1Uid: userId,
              user1Name: userName,
              user2Uid: null,
              user2Name: null,
              isFull: false,
              room: null);
          DocumentReference doc = await _reservationColRef.add(newReservation);
          docId = doc.id;
        }
      });
    });
    // return docId;
  }

  Future<void> cancelRoom(String _docId) async {
    DocumentReference reservationRef = _reservationColRef.doc(_docId);
    DocumentSnapshot reservationSnap = await reservationRef.get();
    final ReservationModel reservation = ReservationModel.fromFirestore(
        reservationSnap as DocumentSnapshot<Map<String, dynamic>>, null);
    if (reservation.isInUser1(userId)) {
      ReservationModel newReservation = ReservationModel(
        startTime: reservation.startTime,
        endTime: reservation.endTime,
        user1Uid: null,
        user1Name: null,
        user2Uid: reservation.user2Uid,
        user2Name: reservation.user2Name,
        isFull: false,
        room: reservation.room,
      );
      reservationRef.set(newReservation);
    } else if (reservation.isInUser2(userId)) {
      ReservationModel newReservation = ReservationModel(
        startTime: reservation.startTime,
        endTime: reservation.endTime,
        user1Uid: reservation.user1Uid,
        user1Name: reservation.user1Name,
        user2Uid: null,
        user2Name: null,
        isFull: false,
        room: reservation.room,
      );
      reservationRef.set(newReservation);
    } else {
      throw Exception("There is not rooms for cancellation!");
    }
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
        ReservationModel newReservation = ReservationModel(
          startTime: reservation.startTime,
          endTime: reservation.endTime,
          user1Uid: reservation.user1Uid,
          user1Name: reservation.user1Name,
          user2Uid: reservation.user2Uid,
          user2Name: reservation.user2Name,
          room: roomId,
          isFull: reservation.isFull,
        );
        transaction.update(reservationRef, newReservation.toFirestore());
      } else {
        signaling.joinRoom(roomId, remoteRenderer);
      }
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../utils/signaling.dart';

class MatchingMethods {
  // TODO: userId, docId 받아오기
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = "tempId12345";
  final String _docId = "0z9yZ0niffihShdBXoEP";

  Future<void> matchRoom({required DateTime date}) async {
    /* matchRoom
     * 1. 시간으로 필터링을 해서 튜플을 찾는다
     * 2-1. 있다
     * 3. 들어간다. 디비에 빈 유저 필드에 <- 자기 아이디 , isFull <- 1 업데이트 한다.
     * 2-2. 없다
     * 3-2. 만든다.
    */
    CollectionReference reservations = _firestore.collection('Reservation');
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      await reservations
          .where('date', isEqualTo: Timestamp.fromDate(date))
          .where('isFull', isEqualTo: false)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.size > 0) {
          DocumentReference reservation =
              reservations.doc(querySnapshot.docs.first.id);
          DocumentSnapshot snapshot = await transaction.get(reservation);

          if (!snapshot.exists) {
            throw Exception("Reservation does not exist!");
          }

          if (snapshot.get('user1') == null) {
            transaction.update(
              reservation,
              {
                'user1': _userId,
                'isFull': true,
              },
            );
          } else {
            transaction.update(
              reservation,
              {
                'user2': _userId,
                'isFull': true,
              },
            );
          }
        } else {
          reservations.add({
            'date': Timestamp.fromDate(date),
            'user1': _userId,
            'user2': null,
            'isFull': false,
            'room': null,
          });
        }
      });
    });
  }

  Future<void> cancelRoom() async {
    CollectionReference reservations = _firestore.collection('Reservation');
    DocumentReference reservation = reservations.doc(_docId);
    DocumentSnapshot snapshot = await reservation.get();
    if (snapshot.get('user1') == _userId) {
      reservation
          .set({'user1': null, 'isFull': false}, SetOptions(merge: true));
    } else if (snapshot.get('user2') == _userId) {
      reservation
          .set({'user2': null, 'isFull': false}, SetOptions(merge: true));
    } else {
      throw Exception("There is not rooms for cancellation!");
    }
  }

  Future<void> enterRoom(
    Signaling signaling,
    RTCVideoRenderer localRenderer,
    RTCVideoRenderer remoteRenderer,
  ) async {
    await signaling.openUserMedia(localRenderer, remoteRenderer);
    signaling.peerClose();
    CollectionReference reservations = _firestore.collection('Reservation');
    DocumentReference reservation = reservations.doc(_docId);
    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reservation);
      String? roomId = snapshot.get('room');
      if (roomId == null) {
        roomId = await signaling.createRoom(remoteRenderer);
        transaction.update(reservation, {'room': roomId});
      } else {
        signaling.joinRoom(roomId, remoteRenderer);
      }
    });
  }
}

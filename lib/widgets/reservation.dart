// import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:intl/intl.dart';

import '../consts/colors.dart';
import '../screens/session_screen.dart';

final int maxDateTime = 10000000000000000;

class Reservation extends StatefulWidget {
  Reservation({Key? key}) : super(key: key);
  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  String? partnerName = '';
  String reservationTime = '10시';
  int remainingTime = 0;
  bool isTenMinutesLeft = true;

  DateTime now = new DateTime.now();
  ReservationModel? nextReservation = null;
  DateTime? nextReservationStartTime;
  String? nextReservationId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _user = FirebaseAuth.instance;
  late CollectionReference _reservationColRef;

  void enterReservation() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SessionScreen(
                session: nextReservation!,
              )),
    );
  }

  void getNextSession() async {
    await _reservationColRef
        .where('user1Uid', isEqualTo: _user.currentUser!.uid)
        .orderBy('startTime')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) async {
      ReservationModel? nextReservation_origin;
      querySnapshot.docChanges.forEach((element) {
        if (element.type == DocumentChangeType.added) {
          DocumentSnapshot reservationSnap = element.doc;
          ReservationModel tempReservation =
              reservationSnap.data() as ReservationModel;
          tempReservation.pk = reservationSnap.id;
          if (nextReservation != null) {
            nextReservation = (now.isBefore(tempReservation.startTime!) &&
                    nextReservation!.startTime!
                        .isBefore(tempReservation.startTime!))
                ? nextReservation
                : tempReservation;
          } else {
            nextReservation = (now.isBefore(tempReservation.startTime!))
                ? tempReservation
                : nextReservation;
          }
          if (nextReservation != nextReservation_origin) {
            if (nextReservation != null) {
              setState(() {
                nextReservationStartTime = nextReservation!.startTime!;
                remainingTime =
                    Timestamp.fromDate(nextReservationStartTime!).seconds -
                        Timestamp.fromDate(now).seconds;
                reservationTime =
                    DateFormat('H').format(nextReservationStartTime!);
                if (nextReservation!.isInUser1(_user.currentUser!.uid)) {
                  partnerName = nextReservation!.user2Name;
                } else {
                  partnerName = nextReservation!.user1Name;
                }
              });
            }
          }
        } else {
          if (querySnapshot.size > 0) {
            nextReservation = null;
            querySnapshot.docs.forEach((element) {
              ReservationModel tempReservation =
                  element.data() as ReservationModel;
              tempReservation.pk = element.id;
              if (nextReservation != null) {
                nextReservation = (now.isBefore(tempReservation.startTime!) &&
                        nextReservation!.startTime!
                            .isBefore(tempReservation.startTime!))
                    ? nextReservation
                    : tempReservation;
              } else {
                nextReservation = (now.isBefore(tempReservation.startTime!))
                    ? tempReservation
                    : nextReservation;
              }
            });
          }
          if (nextReservation != null) {
            setState(() {
              nextReservationStartTime = nextReservation!.startTime!;
              remainingTime =
                  Timestamp.fromDate(nextReservationStartTime!).seconds -
                      Timestamp.fromDate(now).seconds;
              reservationTime =
                  DateFormat('H').format(nextReservationStartTime!);
              if (nextReservation!.isInUser1(_user.currentUser!.uid)) {
                partnerName = nextReservation!.user2Name;
              } else {
                partnerName = nextReservation!.user1Name;
              }
            });
          } else {
            setState(() {
              nextReservationStartTime = null;
              partnerName = '';
              remainingTime = 0;
              reservationTime = '';
            });
          }
        }
      });
    });

    await _reservationColRef
        .where('user2Uid', isEqualTo: _user.currentUser!.uid)
        .orderBy('startTime')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) async {
      ReservationModel? nextReservation_origin;
      querySnapshot.docChanges.forEach((element) {
        if (element.type == DocumentChangeType.added) {
          DocumentSnapshot reservationSnap = element.doc;
          ReservationModel tempReservation =
              reservationSnap.data() as ReservationModel;
          tempReservation.pk = reservationSnap.id;
          if (nextReservation != null) {
            nextReservation = (now.isBefore(tempReservation.startTime!) &&
                    nextReservation!.startTime!
                        .isBefore(tempReservation.startTime!))
                ? nextReservation
                : tempReservation;
          } else {
            nextReservation = (now.isBefore(tempReservation.startTime!))
                ? tempReservation
                : nextReservation;
          }
          if (nextReservation != nextReservation_origin) {
            if (nextReservation != null) {
              setState(() {
                nextReservationStartTime = nextReservation!.startTime!;
                remainingTime =
                    Timestamp.fromDate(nextReservationStartTime!).seconds -
                        Timestamp.fromDate(now).seconds;
                reservationTime =
                    DateFormat('H').format(nextReservationStartTime!);
                if (nextReservation!.isInUser1(_user.currentUser!.uid)) {
                  partnerName = nextReservation!.user2Name;
                } else {
                  partnerName = nextReservation!.user1Name;
                }
              });
            }
          }
        } else {
          if (querySnapshot.size > 0) {
            nextReservation = null;
            querySnapshot.docs.forEach((element) {
              ReservationModel tempReservation =
                  element.data() as ReservationModel;
              tempReservation.pk = element.id;
              if (nextReservation != null) {
                nextReservation = (now.isBefore(tempReservation.startTime!) &&
                        nextReservation!.startTime!
                            .isBefore(tempReservation.startTime!))
                    ? nextReservation
                    : tempReservation;
              } else {
                nextReservation = (now.isBefore(tempReservation.startTime!))
                    ? tempReservation
                    : nextReservation;
              }
            });
          }
          if (nextReservation != null) {
            setState(() {
              nextReservationStartTime = nextReservation!.startTime!;
              remainingTime =
                  Timestamp.fromDate(nextReservationStartTime!).seconds -
                      Timestamp.fromDate(now).seconds;
              reservationTime =
                  DateFormat('H').format(nextReservationStartTime!);
              if (nextReservation!.isInUser1(_user.currentUser!.uid)) {
                partnerName = nextReservation!.user2Name;
              } else {
                partnerName = nextReservation!.user1Name;
              }
            });
          } else {
            setState(() {
              nextReservationStartTime = null;
              partnerName = '';
              remainingTime = 0;
              reservationTime = '';
            });
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    this._reservationColRef =
        _firestore.collection('reservation').withConverter<ReservationModel>(
              fromFirestore: ReservationModel.fromFirestore,
              toFirestore: (ReservationModel reservationModel, _) =>
                  reservationModel.toFirestore(),
            );
    getNextSession();
  }

  @override
  Widget build(BuildContext context) {
    return remainingTime != 0
        ? Container(
            margin: EdgeInsets.only(top: 32),
            padding: EdgeInsets.all(15),
            width: 380,
            height: 292, //355
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1.5, color: border100),
                borderRadius: BorderRadius.all(Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: Offset(0, 6),
                  ),
                ]),
            child: Container(
                margin: EdgeInsets.only(top: 5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TimerCountdown(
                          format: CountDownTimerFormat.hoursMinutesSeconds,
                          endTime: DateTime.now().add(
                            Duration(
                              seconds: remainingTime,
                            ),
                          ),
                          enableDescriptions: false,
                          onEnd: () {
                            setState(() {
                              isTenMinutesLeft = true;
                            });
                          },
                          timeTextStyle: TextStyle(
                            height: 1.0,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                          colonsTextStyle: TextStyle(
                            height: 1.0,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                          spacerWidth: 0,
                        ),
                        Text(' 남았습니다',
                            // textAlign: TextAlign.center,
                            style: const TextStyle(
                              height: 1.0,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                    partnerName != ''
                        ? Container(
                            margin: EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('$partnerName',
                                    style: const TextStyle(
                                      height: 1.0,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: purple300,
                                    )),
                                Text(
                                  '님과의 세션이 $reservationTime시에 예약되었어요!',
                                  style: TextStyle(
                                    height: 1.0,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: black100,
                                  ),
                                )
                              ],
                            ))
                        : Container(
                            margin: EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('$reservationTime',
                                    style: const TextStyle(
                                      height: 1.0,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: purple300,
                                    )),
                                Text(
                                  '시에 예약되었어요!',
                                  style: TextStyle(
                                    height: 1.0,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: black100,
                                  ),
                                )
                              ],
                            )),
                    Stack(
                      children: [
                        Image.asset(
                          'assets/images/meet.png',
                          height: 200,
                        ),
                        Positioned(
                            bottom: 0,
                            right: -60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    width: 119,
                                    height: 54,
                                    child: isTenMinutesLeft &&
                                            nextReservation != null
                                        ? ElevatedButton(
                                            onPressed: () {
                                              enterReservation();
                                            },
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16.0),
                                                      side: BorderSide(
                                                          color: Colors
                                                              .transparent))),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(purple300),
                                            ),
                                            child: Text('입장하기',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                )))
                                        : TextButton(
                                            onPressed: () {
                                              // enterReservation();
                                            },
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16.0),
                                                      side: BorderSide(
                                                          color: Colors
                                                              .transparent))),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.black38),
                                            ),
                                            child: Text('입장하기',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                )))),
                              ],
                            ))
                      ],
                      clipBehavior: Clip.none,
                    ),
                  ],
                )))
        : Container(
            margin: EdgeInsets.only(top: 32),
            padding: EdgeInsets.all(15),
            width: 380,
            height: 120,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1.5, color: border100),
                borderRadius: BorderRadius.all(Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: Offset(0, 6),
                  ),
                ]),
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                  Text('예약이 없습니다',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 24, 24, 24))),
                  Text('캘린더에서 원하는 시간대를 골라 클릭해보세요!',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(105, 105, 105, 100))),
                ])));
  }
}

// import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/utils/utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../consts/colors.dart';

final int maxDateTime = 10000000000000000;

class MobileReservation extends StatefulWidget {
  MobileReservation({Key? key}) : super(key: key);
  @override
  _MobileReservationState createState() => _MobileReservationState();
}

final FirebaseAuth _user = FirebaseAuth.instance;

class _MobileReservationState extends State<MobileReservation> {
  String? partnerName = null;
  String reservationTime = '10시';

  bool isTenMinutesLeft = false;

  DateTime now = new DateTime.now();
  ReservationModel? nextReservation = null;
  ReservationModel? nextReservation1 = null;
  ReservationModel? nextReservation2 = null;
  DateTime? nextReservationStartTime;
  String? nextReservationId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userUid = _user.currentUser?.uid;
  late CollectionReference _reservationColRef;
  bool isGetReservationLoading = true;

  Timer? _timer;

  void enterReservation() {
    Get.rootDelegate.toNamed(Routes.SESSION, arguments: nextReservation!);
  }

  void getReservationListener() async {
    if (userUid != null) {
      await _reservationColRef
          .where('user1Uid', isEqualTo: userUid)
          .where('startTime', isGreaterThan: DateTime.now())
          .orderBy('startTime')
          .snapshots()
          .listen((QuerySnapshot querySnapshot) async {
        querySnapshot.docChanges.forEach((element) {
          if (element.type == DocumentChangeType.added) {
            DocumentSnapshot reservationSnap = element.doc;
            ReservationModel tempReservation =
                reservationSnap.data() as ReservationModel;
            tempReservation.pk = reservationSnap.id;
            if (nextReservation1 != null) {
              nextReservation1 = (now.isBefore(tempReservation.startTime!) &&
                      nextReservation1!.startTime!
                          .isBefore(tempReservation.startTime!))
                  ? nextReservation1
                  : tempReservation;
            } else {
              nextReservation1 = (now.isBefore(tempReservation.startTime!))
                  ? tempReservation
                  : nextReservation1;
            }
          } else {
            nextReservation1 = null;
            querySnapshot.docs.forEach((element) {
              ReservationModel tempReservation =
                  element.data() as ReservationModel;
              tempReservation.pk = element.id;
              if (nextReservation1 != null) {
                nextReservation1 = (now.isBefore(tempReservation.startTime!) &&
                        nextReservation1!.startTime!
                            .isBefore(tempReservation.startTime!))
                    ? nextReservation1
                    : tempReservation;
              } else {
                nextReservation1 = (now.isBefore(tempReservation.startTime!))
                    ? tempReservation
                    : nextReservation1;
              }
            });
          }
        });
        setState(() {
          isGetReservationLoading = false;
        });
        getNextSession();
      });

      await _reservationColRef
          .where('user2Uid', isEqualTo: userUid)
          .where('startTime', isGreaterThan: DateTime.now())
          .orderBy('startTime')
          .snapshots()
          .listen((QuerySnapshot querySnapshot) async {
        querySnapshot.docChanges.forEach((element) {
          if (element.type == DocumentChangeType.added) {
            DocumentSnapshot reservationSnap = element.doc;
            ReservationModel tempReservation =
                reservationSnap.data() as ReservationModel;
            tempReservation.pk = reservationSnap.id;
            if (nextReservation2 != null) {
              nextReservation2 = (now.isBefore(tempReservation.startTime!) &&
                      nextReservation2!.startTime!
                          .isBefore(tempReservation.startTime!))
                  ? nextReservation2
                  : tempReservation;
            } else {
              nextReservation2 = (now.isBefore(tempReservation.startTime!))
                  ? tempReservation
                  : nextReservation2;
            }
          } else {
            nextReservation2 = null;
            querySnapshot.docs.forEach((element) {
              ReservationModel tempReservation =
                  element.data() as ReservationModel;
              tempReservation.pk = element.id;
              if (nextReservation2 != null) {
                nextReservation2 = (now.isBefore(tempReservation.startTime!) &&
                        nextReservation2!.startTime!
                            .isBefore(tempReservation.startTime!))
                    ? nextReservation2
                    : tempReservation;
              } else {
                nextReservation2 = (now.isBefore(tempReservation.startTime!))
                    ? tempReservation
                    : nextReservation2;
              }
            });
          }
        });
        setState(() {
          isGetReservationLoading = false;
        });
        getNextSession();
      });
    } else {
      setState(() {
        isGetReservationLoading = false;
      });
      await _reservationColRef.where('userUid', isEqualTo: 'none').snapshots();
    }
  }

  void getNextSession() {
    ReservationModel? nextReservation_origin = nextReservation;
    if (nextReservation1 == null && nextReservation2 == null) {
      nextReservation = null;
    } else if (nextReservation1 == null && nextReservation2 != null) {
      nextReservation = nextReservation2;
    } else if (nextReservation1 != null && nextReservation2 == null) {
      nextReservation = nextReservation1;
    } else {
      nextReservation =
          (nextReservation1!.startTime!.isBefore(nextReservation2!.startTime!))
              ? nextReservation1
              : nextReservation2;
    }
    if (nextReservation != null) {
      if (nextReservation != nextReservation_origin)
        setState(() {
          nextReservationStartTime = nextReservation!.startTime!;
          _timer?.cancel();
          if (nextReservationStartTime!
                  .difference(DateTime.now())
                  .compareTo(Duration(minutes: 10)) <=
              0) {
            enableEnter();
          } else {
            disableEnter();
            _timer = Timer(
                nextReservationStartTime!.difference(DateTime.now()) -
                    Duration(minutes: 10),
                enableEnter);
          }
          reservationTime = DateFormat('H').format(nextReservationStartTime!);
          if (nextReservation!.isInUser1(userUid!)) {
            partnerName = nextReservation!.user2Name;
          } else {
            partnerName = nextReservation!.user1Name;
          }
        });
    } else {
      setState(() {
        nextReservationStartTime = null;
        partnerName = '';
        _timer?.cancel();
        disableEnter();
        reservationTime = '';
      });
    }
  }

  void enableEnter() {
    setState(() {
      isTenMinutesLeft = true;
    });
  }

  void disableEnter() {
    setState(() {
      isTenMinutesLeft = false;
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
    getReservationListener();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return isGetReservationLoading
        ? Container(
            margin: EdgeInsets.only(top: 32),
            padding: EdgeInsets.all(15),
            width: screenWidth - 40,
            height: 120,
            alignment: Alignment.center,
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
            child: Text(
              '로딩중입니다...',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 24, 24, 24)),
            ),
          )
        : nextReservationStartTime != null
            ? Container(
                margin: EdgeInsets.only(top: 20),
                width: screenWidth - 50,
                height: 120,
                padding: EdgeInsets.only(top: 15, bottom: 12),
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
                    // margin: EdgeInsets.only(top: 20),
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TimerCountdown(
                          format: CountDownTimerFormat.hoursMinutesSeconds,
                          endTime: Timestamp.fromDate(nextReservationStartTime!)
                              .toDate(),
                          enableDescriptions: false,
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
                    Container(
                      width: screenWidth - 80,
                      child: Container(
                          width: (screenWidth - 80) / 2,
                          height: 46,
                          // margin: EdgeInsets.only(bottom: 10),
                          child: isTenMinutesLeft && nextReservation != null
                              ? ElevatedButton(
                                  onPressed: () {
                                    showSnackBar(
                                        '현재 세션 입장은 PC에서만 가능합니다 : )', context);
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(32.0),
                                            side: BorderSide(
                                                color: Colors.transparent))),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            purple300),
                                  ),
                                  child: partnerName == null
                                      ? Text('입장하기',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ))
                                      : Text(
                                          '$partnerName와 입장하기',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                )
                              : TextButton(
                                  onPressed: () {
                                    showSnackBar(
                                        '현재 세션 입장은 PC에서만 가능합니다 : )', context);
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            side: BorderSide(
                                                color: Colors.transparent))),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black38),
                                  ),
                                  child: partnerName == null
                                      ? Text('입장하기',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ))
                                      : Text(
                                          '$partnerName와 입장하기',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                )),
                    ),
                  ],
                )))
            : Container(
                margin: EdgeInsets.only(top: 32),
                padding: EdgeInsets.all(15),
                width: screenWidth - 40,
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
                    child: userUid != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                Text('캘린더를 클릭해 예약해보세요!',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Color.fromARGB(255, 24, 24, 24))),
                              ])
                        : SizedBox(
                            height: 120,
                            width: screenWidth - 40,
                            child: TextButton(
                              onPressed: () {
                                Get.rootDelegate.toNamed(Routes.LOGIN);
                              },
                              child: Text('로그인이 필요합니다',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 24, 24, 24))),
                            ))));
  }
}
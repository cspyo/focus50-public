// import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:intl/intl.dart';

import '../consts/colors.dart';

class Reservation extends StatefulWidget {
  // int remainingTime;
  // final DateTime now;
  // String fastReservation;
  // DateTime fastestReservation;
  Reservation({
    Key? key,
    // required this.remainingTime,
    // required this.now,
    // required this.fastReservation,
    // required this.fastestReservation,
  }) : super(key: key);
  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  var opponentUsername = '사용자31';
  var reservationTime = '10시';
  int remainingTime = 0;
  bool isTenMinutesLeft = true;

  DateTime now = new DateTime.now();
  late String fastReservation;
  DateTime fastestReservation =
      new DateTime.fromMicrosecondsSinceEpoch(10000000000000000);

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('reservation').snapshots();
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('reservation')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var docDate = doc['startTime'].toDate();
        //doc에 있는 date가 현재 시간보다 뒤고,fastestReservation보다 앞이고,현재 로그인된 유저가 user1이거나 user2일때 아래 내용 실행
        if (now.isBefore(docDate) &&
            docDate.isBefore(fastestReservation) &&
            (doc['user1Uid'] == user?.uid || doc['user2Uid'] == user?.uid)) {
          fastestReservation = docDate;
          remainingTime = Timestamp.fromDate(fastestReservation).seconds -
              Timestamp.fromDate(now).seconds;
          reservationTime = DateFormat('H').format(fastestReservation);
          if (doc['user1Uid'] == user!.uid) {
            opponentUsername = doc['user2Name'];
          } else {
            opponentUsername = doc['user1Name'];
          }
          print(fastestReservation);
        }
      });
    });
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        snapshot.data!.docs.forEach((doc) {
          var docDate = doc['startTime'].toDate();
          //doc에 있는 date가 현재 시간보다 뒤고,fastestReservation보다 앞이고,현재 로그인된 유저가 user1이거나 user2일때 아래 내용 실행
          if (now.isBefore(docDate) &&
              docDate.isBefore(fastestReservation) &&
              (doc['user1Uid'] == user?.uid || doc['user2Uid'] == user?.uid)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                fastestReservation = docDate;
                remainingTime = Timestamp.fromDate(fastestReservation).seconds -
                    Timestamp.fromDate(now).seconds;
                reservationTime = DateFormat('H').format(fastestReservation);
                if (doc['user1Uid'] == user!.uid) {
                  opponentUsername = doc['user2Name'];
                } else {
                  opponentUsername = doc['user1Name'];
                }
              });
            });
            print(fastestReservation);
          }
        });
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
                                fontFamily: 'poppins',
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                              colonsTextStyle: TextStyle(
                                height: 1.0,
                                fontFamily: 'poppins',
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                              spacerWidth: 0,
                            ),
                            Text(' 남았습니다',
                                // textAlign: TextAlign.center,
                                style: const TextStyle(
                                  height: 1.0,
                                  fontFamily: 'poppins',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                        opponentUsername != ''
                            ? Container(
                                margin: EdgeInsets.only(top: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('$opponentUsername',
                                        style: const TextStyle(
                                          height: 1.0,
                                          fontFamily: 'poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: purple300,
                                        )),
                                    Text(
                                      '님과의 세션이 $reservationTime시에 예약되었어요!',
                                      style: TextStyle(
                                        height: 1.0,
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
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
                                          fontFamily: 'poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: purple300,
                                        )),
                                    Text(
                                      '시에 예약되었어요!',
                                      style: TextStyle(
                                        height: 1.0,
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: black100,
                                      ),
                                    )
                                  ],
                                )),
                        Stack(
                          children: [
                            Image.asset(
                              'meet.png',
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
                                        child: isTenMinutesLeft
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  // getReservation();
                                                },
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
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
                                                      fontFamily: 'Poppins',
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    )))
                                            : TextButton(
                                                onPressed: () {
                                                  // getReservation();
                                                },
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16.0),
                                                          side: BorderSide(
                                                              color: Colors
                                                                  .transparent))),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.black38),
                                                ),
                                                child: Text('입장하기',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 24, 24, 24))),
                      Text('캘린더에서 원하는 시간대를 골라 클릭해보세요!',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(105, 105, 105, 100))),
                    ])));
      },
    );
  }
}

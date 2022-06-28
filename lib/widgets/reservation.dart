import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';

import '../consts/colors.dart';

class Reservation extends StatefulWidget {
  const Reservation({Key? key}) : super(key: key);
  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  late var data = {};

  var reservationTime = '22시';
  var opponentUsername = '사용자31';
  DateTime now = new DateTime.now();
// var remainingTime =
  // String formatDate = DateFormat('yy/MM/dd - HH:mm:ss').format(now);
  void getReservation() {
    final docRef =
        FirebaseFirestore.instance.collection('reservation').doc('jaewontop');
    docRef.get().then(
      (DocumentSnapshot doc) {
        data = doc.data() as Map<String, dynamic>;
      },
      onError: (e) => print("error: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 32),
        padding: EdgeInsets.all(15),
        width: 380,
        height: 355,
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
                    TimerBuilder.periodic(
                      const Duration(seconds: 1),
                      builder: (context) {
                        return Text(
                          formatDate(
                              DateTime.now(), [hh, ':', nn, ':', ss, ' ']),
                          // textAlign: TextAlign.center,
                          // TextAlignVertical.center,
                          style: const TextStyle(
                            height: 1.0,
                            fontFamily: 'poppins',
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
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
                Container(
                    margin: EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$opponentUsername',
                            style: const TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: purple300,
                            )),
                        Text(
                          '님과의 세션이 $reservationTime에 예약되었어요!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: black100,
                          ),
                        )
                      ],
                    )),
                Image.asset(
                  'meet.png',
                  height: 200,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 119,
                      height: 54,
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    side:
                                        BorderSide(color: Colors.transparent))),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(purple300),
                          ),
                          child: Text('입장하기',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ))),
                    ),
                  ],
                )
              ],
            )));
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/widgets/reservation.dart';
import 'package:focus42/widgets/todo.dart';
import 'package:get/get.dart';

import '../consts/colors.dart';
import '../consts/routes.dart';
import '../widgets/calendar.dart';
import '../widgets/line.dart';
import '../widgets/reservation.dart';
import '../widgets/todo.dart';

// ignore: use_key_in_widget_constructors
class CalendarScreen extends StatefulWidget {
  CalendarScreen({Key? key}) : super(key: key);
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _auth = FirebaseAuth.instance;
  int remainingTime = 0;

  DateTime now = new DateTime.now();

  String fastReservation = '10시';

  DateTime fastestReservation =
      new DateTime.fromMicrosecondsSinceEpoch(10000000000000000);

  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(//페이지 전체 구성
          children: <Widget>[
        // 데스크탑 헤더
        Container(
          padding:
              const EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: const <Widget>[
                  Text(
                    'Focus',
                    style: TextStyle(
                      fontFamily: 'Okddung',
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '50',
                    style: TextStyle(
                      fontFamily: 'Okddung',
                      fontSize: 30,
                      color: purple300,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  TextButton(
                      onPressed: () {
                        Get.rootDelegate.toNamed(Routes.ABOUT);
                      },
                      child: const Text('소개',
                          style: TextStyle(fontSize: 17, color: Colors.black))),
                  SizedBox(width: 10),
                  TextButton(
                      onPressed: () {
                        Get.rootDelegate.toNamed(Routes.CALENDAR);
                      },
                      child: const Text('캘린더',
                          style: TextStyle(fontSize: 17, color: Colors.black))),
                  SizedBox(width: 10),
                  (_auth.currentUser != null)
                      ? TextButton(
                          onPressed: () {
                            Get.rootDelegate.toNamed(Routes.PROFILE);
                          },
                          child: const Text('마이페이지',
                              style:
                                  TextStyle(fontSize: 17, color: Colors.black)))
                      : Container(),
                  SizedBox(width: 10),
                  (_auth.currentUser != null)
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: purple300,
                          ),
                          onPressed: () {
                            setState(() {
                              _auth.signOut();
                            });

                            Get.rootDelegate.toNamed(Routes.LOGIN);
                          },
                          child: const Text(
                            '  로그아웃  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            primary: purple300,
                          ),
                          onPressed: () {
                            Get.rootDelegate.toNamed(Routes.SIGNUP);
                          },
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                  (_auth.currentUser != null)
                      ? Container()
                      : SizedBox(width: 20),
                  (_auth.currentUser != null)
                      ? Container()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: purple300,
                          ),
                          onPressed: () {
                            Get.rootDelegate.toNamed(Routes.LOGIN);
                          },
                          child: const Text(
                            '  로그인  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ), //header
        const Line(),
        // ignore: avoid_unnecessary_containers
        Container(
            child: Row(children: <Widget>[
          Container(
            width: 420,
            height: 1100,
            decoration: BoxDecoration(
                border:
                    Border(right: BorderSide(color: border100, width: 1.5))),
            child: Column(children: <Widget>[
              Reservation(
                  // remainingTime: remainingTime,
                  // now: now,
                  // fastReservation: fastReservation,
                  // fastestReservation: fastestReservation,
                  ),
              Todo(),
            ]),
          ),
          // Container(
          //   clipBehavior: Clip.
          //   height: 400,
          //   width: 400,
          //   child: Calendar(),
          // ),
          Container(
            child: Calendar(),
          ),
        ])), //reservation, todo, calendar
      ]),
    ));
  }
}

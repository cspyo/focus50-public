import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/widgets/todo.dart';

import '../consts/colors.dart';
import '../widgets/calendar.dart';
import '../widgets/line.dart';
import '../widgets/reservation.dart';

// ignore: use_key_in_widget_constructors
class CalendarScreen extends StatefulWidget {
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int remainingTime = 0;

  DateTime now = new DateTime.now();

  String fastReservation = '10시';

  DateTime fastestReservation =
      new DateTime.fromMicrosecondsSinceEpoch(10000000000000000);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
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
                  Text('Focus',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 30,
                          color: Colors.black)),
                  Text('50',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                          color: purple300)),
                ],
              ),
              Row(
                children: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      child: const Text('About',
                          style: TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w300,
                              fontSize: 17,
                              color: Colors.black))),
                  SizedBox(width: 10),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/calendar');
                      },
                      child: const Text('Calendar',
                          style: TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w300,
                              fontSize: 17,
                              color: Colors.black))),
                  SizedBox(width: 10),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: const Text('Profile',
                          style: TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w300,
                              fontSize: 17,
                              color: Colors.black))),
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
                            print(_auth.currentUser);
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text('  Logout  '),
                        )
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            primary: purple300,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text('Sign Up')),
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
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text('  Log In  '),
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
          Container(child: Calendar())
        ])), //reservation, todo, calendar
      ]),
    ));
  }
}

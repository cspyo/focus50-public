import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/widgets/desktop_header.dart';
import 'package:focus42/widgets/reservation.dart';
import 'package:focus42/widgets/todo.dart';

import '../consts/colors.dart';
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
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(//페이지 전체 구성
          children: <Widget>[
        DesktopHeader(),
        const Line(),
        // ignore: avoid_unnecessary_containers
        Container(
            height: screenHeight - 70,
            child: Row(children: <Widget>[
              Container(
                width: 420,
                height: screenHeight - 70,
                decoration: BoxDecoration(
                    border: Border(
                        right: BorderSide(color: border100, width: 1.5))),
                child: Column(children: <Widget>[
                  Reservation(),
                  Todo(),
                ]),
              ),
              Container(
                child: Calendar(),
              ),
            ])),
      ]),
    ));
  }
}

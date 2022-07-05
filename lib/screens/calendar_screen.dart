import 'package:flutter/material.dart';

import '../consts/colors.dart';
import '../widgets/calendar.dart';
import '../widgets/desktop_header.dart';
import '../widgets/line.dart';
import '../widgets/reservation.dart';

// ignore: use_key_in_widget_constructors
class CalendarScreen extends StatelessWidget {
  int remainingTime = 0;
  DateTime now = new DateTime.now();
  String fastReservation = '10시';
  DateTime fastestReservation =
      new DateTime.fromMicrosecondsSinceEpoch(10000000000000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(//페이지 전체 구성
          children: <Widget>[
        desktopheader(), //header
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
              // Todo(),
            ]),
          ),
          Container(child: Calendar())
        ])), //reservation, todo, calendar
      ]),
    ));
  }
}

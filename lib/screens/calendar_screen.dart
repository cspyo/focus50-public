import 'package:flutter/material.dart';
import '../widgets/calendar.dart';
import '../widgets/desktop_header.dart';
import '../widgets/line.dart';
import '../widgets/reservation.dart';
import '../widgets/todo.dart';

// ignore: use_key_in_widget_constructors
class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(//페이지 전체 구성
          children: <Widget>[
        desktopheader(), //header
        const Line(),
        // ignore: avoid_unnecessary_containers
        Container(
            child: Row(children: <Widget>[
          Column(children: const <Widget>[
            Reservation(),
            // todo(),
          ]),
          Column(
            children: const <Widget>[
              calendar(),
            ],
          )
        ])), //reservation, todo, calendar
      ]),
    );
  }
}

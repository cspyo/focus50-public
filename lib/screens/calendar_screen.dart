import 'package:flutter/material.dart';

import '../consts/colors.dart';
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
            child: Column(children: const <Widget>[
              Reservation(),
              Todo(),
            ]),
          ),
          Container(child: Calendar())
        ])), //reservation, todo, calendar
      ]),
    ));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Calendar extends StatefulWidget {
  @override
  CalendarAppointment createState() => CalendarAppointment();
}

class CalendarAppointment extends State<Calendar> {
  late CalendarDataSource _dataSource;
  List<Appointment> appointments = <Appointment>[];
  CollectionReference reservation =
      FirebaseFirestore.instance.collection('reservation');
  void initState() {
    // _dataSource = _DataSource(appointments);
    // _getDataSource();
    // _dataSource = _DataSource();
    // _dataSource =
    _dataSource = _DataSource(appointments);
    setState(() {
      reservation.get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          Appointment app = Appointment(
            startTime: doc['startTime'].toDate(),
            endTime: doc['endTime'].toDate(),
            subject: doc['user1Name'],
            color: Colors.teal,
          );
          _dataSource.appointments!.add(app);
          // print(_dataSource.appointments);
          _dataSource.notifyListeners(
              CalendarDataSourceAction.add, <Appointment>[app]);
        });
      });
    });
    super.initState();
  }

  // List<Appointment> appointments = <Appointment>[];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 856,
      height: 1100,
      child: SfCalendar(
        dataSource: _dataSource,
        headerStyle: CalendarHeaderStyle(
            textAlign: TextAlign.center,
            backgroundColor: Colors.white,
            textStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                letterSpacing: 4,
                color: purple300,
                fontWeight: FontWeight.w900)),
        onTap: calendarTapped,
        view: CalendarView.week,
        monthViewSettings: MonthViewSettings(showAgenda: true),
        todayHighlightColor: purple300,
      ),
    );
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName;
    if (user != null && name != null) {
      final uid = user.uid;
      Appointment app = Appointment(
          startTime: calendarTapDetails.date!,
          endTime: calendarTapDetails.date!.add(Duration(hours: 1)),
          subject: name,
          color: purple300);
      _dataSource.appointments!.add(app);
      print(_dataSource.appointments);
      _dataSource
          .notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);

      reservation
          .add({
            'startTime': calendarTapDetails.date!,
            'endTime': calendarTapDetails.date!.add(Duration(hours: 1)),
            'user1Uid': uid,
            'user1Name': name,
            'user2Uid': '',
            'user2Name': '',
          })
          .then((value) => print("예약되었습니다"))
          .catchError((error) => print("Failed to add user: $error"));
    }
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

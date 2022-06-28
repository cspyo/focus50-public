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
  @override
  void initState() {
    // _dataSource = _getDataSource();
    _getDataSource();
    super.initState();
  }

  CollectionReference reservation =
      FirebaseFirestore.instance.collection('reservation');

  List<Appointment> appointments = <Appointment>[];

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

  _DataSource _getDataSource() {
    List<Appointment> appointments = <Appointment>[];
    // _dataSource = await FirebaseFirestore.instance
    // .collection('reservation').get().then<_DataSource>((DocumentSnapshot documentSnapshot) {
    //   documentSnapshot.data();
    // };
    appointments.add(Appointment(
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: 1)),
      subject: 'Meeting',
      color: Colors.teal,
    ));
    return _DataSource(appointments);
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
      // print(_dataSource.appointments);
      _dataSource
          .notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);

      reservation
          .add({
            'startTime': calendarTapDetails.date!,
            'endTime': calendarTapDetails.date!.add(Duration(hours: 1)),
            'user1Uid': uid,
            'user1Name': name,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/resources/matching_methods.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/reservation_model.dart';

class Calendar extends StatefulWidget {
  @override
  CalendarAppointment createState() => CalendarAppointment();
}

class CalendarAppointment extends State<Calendar> {
  late CalendarDataSource _dataSource;
  List<Appointment> appointments = <Appointment>[];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _user = FirebaseAuth.instance;
  late CollectionReference _reservationColRef;

  void initState() {
    this._reservationColRef =
        _firestore.collection('reservation').withConverter<ReservationModel>(
              fromFirestore: ReservationModel.fromFirestore,
              toFirestore: (ReservationModel reservationModel, _) =>
                  reservationModel.toFirestore(),
            );

    _dataSource = _DataSource(appointments);
    setState(() {
      _reservationColRef.get().then((QuerySnapshot querySnapshot) {
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          ReservationModel reservation = doc.data() as ReservationModel;
          Appointment app = Appointment(
            startTime: reservation.startTime!,
            endTime: reservation.endTime!,
            subject: reservation.user1Name!,
            color: Colors.teal,
          );
          _dataSource.appointments!.add(app);
          // print(_dataSource.appointments);
          _dataSource.notifyListeners(
              CalendarDataSourceAction.add, <Appointment>[app]);
        }
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
      _dataSource
          .notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);

      MatchingMethods().matchRoom(
        startTime: calendarTapDetails.date!,
        endTime: calendarTapDetails.date!.add(Duration(hours: 1)),
      );
    }
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

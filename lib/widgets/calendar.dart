import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/resources/matching_methods.dart';
import 'package:focus42/widgets/current_time_indicator.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/reservation_model.dart';

class Calendar extends StatefulWidget {
  @override
  CalendarAppointment createState() => CalendarAppointment();
}

final _user = FirebaseAuth.instance.currentUser;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class CalendarAppointment extends State<Calendar> {
  late CalendarDataSource _dataSource;
  List<Appointment> appointments = <Appointment>[];
  bool isHover = false;
  bool isEdit = false;
  String docId = '';
  CollectionReference _reservationColRef =
      _firestore.collection('reservation').withConverter<ReservationModel>(
            fromFirestore: ReservationModel.fromFirestore,
            toFirestore: (ReservationModel reservationModel, _) =>
                reservationModel.toFirestore(),
          );
  final name = _user?.displayName;

  int getCurrentDayPosition() {
    String currentDay = DateFormat('E').format(DateTime.now());
    switch (currentDay) {
      case 'Mon':
        return 50;
      case 'Tue':
        return 50 + 115;
      case 'Wed':
        return 50 + 115 * 2;
      case 'Thu':
        return 50 + 115 * 3;
      case 'Fri':
        return 50 + 115 * 4;
      case 'Sat':
        return 50 + 115 * 5;
      case 'Sun':
        return 50 + 115 * 6;
      default:
        return 50;
    }
  }

  void onHover(PointerEvent details) {
    setState(() {
      isHover = true;
    });
  }

  void onExit(PointerEvent details) {
    setState(() {
      isHover = false;
    });
  }

  // void initState() {
  //   this._reservationColRef =
  //       _firestore.collection('reservation').withConverter<ReservationModel>(
  //             fromFirestore: ReservationModel.fromFirestore,
  //             toFirestore: (ReservationModel reservationModel, _) =>
  //                 reservationModel.toFirestore(),
  //           );
  //   _dataSource = _DataSource(appointments);
  //   setState(() {
  //     _reservationColRef.get().then((QuerySnapshot querySnapshot) {
  //       _dataSource.appointments!.clear();
  //       for (QueryDocumentSnapshot doc in querySnapshot.docs) {
  //         ReservationModel reservation = doc.data() as ReservationModel;
  //         Appointment app = Appointment(
  //             startTime: reservation.startTime!,
  //             endTime: reservation.endTime!.subtract(Duration(minutes: 32)),
  //             subject: reservation.user1Name!,
  //             color: Colors.teal,
  //             id: doc.id);
  //         _dataSource.appointments!.add(app);
  //         _dataSource.notifyListeners(
  //             CalendarDataSourceAction.add, <Appointment>[app]);
  //       }
  //     });
  //   });
  //   super.initState();
  // }

  @override
  void initState() {
    super.initState();
    _dataSource = _DataSource(appointments);
    _reservationColRef.snapshots().listen((snapshot) {
      var querySnapshot = snapshot;
      _dataSource.appointments!.clear();
      print("in initstate");
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        ReservationModel reservation = doc.data() as ReservationModel;
        Appointment app = Appointment(
            startTime: reservation.startTime!,
            endTime: reservation.endTime!.subtract(Duration(minutes: 32)),
            subject: reservation.user1Name!,
            color: Colors.teal,
            id: doc.id);
        _dataSource.appointments!.add(app);
      }
      // print(_dataSource.appointments![0]);
      _dataSource.notifyListeners(
          CalendarDataSourceAction.reset, _dataSource.appointments!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 856,
        height: 1100,
        child: Stack(
          children: [
            Positioned(
              left: getCurrentDayPosition().toDouble(),
              top: 100,
              child: CurrentTimeIndicator(),
            ),
            SfCalendar(
              dataSource: _dataSource,
              firstDayOfWeek: 1,
              viewHeaderHeight: 100,
              headerHeight: 0,
              timeSlotViewSettings: TimeSlotViewSettings(
                  dayFormat: 'EEE',
                  timeIntervalHeight: 50,
                  timeInterval: Duration(minutes: 30),
                  timeFormat: 'h:mm'),
              viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: Colors.white,
                  dateTextStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 26,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                  dayTextStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w300)),
              onTap: calendarTapped,
              view: CalendarView.week,
              monthViewSettings: MonthViewSettings(showAgenda: true),
              todayHighlightColor: purple300,
              appointmentBuilder:
                  (BuildContext context, CalendarAppointmentDetails details) {
                final Appointment meeting = details.appointments.first;
                return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: meeting.subject.contains(name.toString())
                            ? purple200
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 4,
                              offset: Offset(0, 2),
                              spreadRadius: 2,
                              color: Colors.black.withOpacity(0.25))
                        ]),
                    child: MouseRegion(
                        onEnter: onHover,
                        onExit: onExit,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 53,
                                child: Text(
                                  meeting.subject,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      fontFamily: 'poppins',
                                      color: meeting.subject
                                              .contains(name.toString())
                                          ? Colors.white
                                          : Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ))
                          ],
                        )));
              },
            ),
          ],
        ));
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    final appointment = calendarTapDetails.appointments?[0];
    //이미 예약이 있는 공간에 클릭했을 때
    if (appointment != null && appointment.subject == name) {
      docId = await appointment.id.toString();
      await _reservationColRef
          .doc(docId)
          .delete()
          .then((value) => print("DEBUG : calendar appointment deleted!"));
      return;
    }
    //빈 공간에 클릭 했을 때
    if (_user != null &&
        name != null &&
        countAppointmentOverlap(_dataSource, calendarTapDetails) < 2 &&
        (appointment == null || appointment?.subject != name)) {
      await MatchingMethods().matchRoom(
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

int countAppointmentOverlap(_dataSource, calendarTapDetails) {
  int count = 0;
  for (var i = 0; i < _dataSource.appointments.length; i++) {
    if (calendarTapDetails.date! == _dataSource.appointments[i].startTime) {
      count++;
    }
  }
  return count;
}

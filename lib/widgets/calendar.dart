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

class CalendarAppointment extends State<Calendar> {
  late CalendarDataSource _dataSource;
  List<Appointment> appointments = <Appointment>[];
  bool isHover = false;
  bool isEdit = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final name = _user?.displayName;
  late CollectionReference _reservationColRef;
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
            endTime: reservation.endTime!.subtract(Duration(minutes: 32)),
            subject: reservation.user1Name!,
            color: Colors.teal,
          );
          _dataSource.appointments!.add(app);
          _dataSource.notifyListeners(
              CalendarDataSourceAction.add, <Appointment>[app]);
        }
      });
    });
    super.initState();
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
                        color: meeting.subject
                                .contains(_user!.displayName.toString())
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
                            //  Text(
                            //         'X',
                            //         style: TextStyle(
                            //             color: Colors.black,
                            //             fontSize: 20,
                            //             fontWeight: FontWeight.w900),
                            //         textAlign: TextAlign.center,
                            //       )
                            //     :
                          ],
                        )));
              },
            ),
            // Positioned(
            //     child: MouseRegion(
            //   child: CalendarHover(),
            // ))
          ],
        ));
  }

// calendarTapDetails.appointments![0].subject == name
  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    // var details = await calendarTapDetails.appointments![0].subject;
    if (_user != null &&
        name != null &&
        countAppointmentOverlap(_dataSource, calendarTapDetails) < 2) {
      Appointment app = Appointment(
          startTime: calendarTapDetails.date!,
          endTime: calendarTapDetails.date!.add(Duration(minutes: 28)),
          subject: name!,
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

int countAppointmentOverlap(_dataSource, calendarTapDetails) {
  int count = 0;
  for (var i = 0; i < _dataSource.appointments.length; i++) {
    if (calendarTapDetails.date! == _dataSource.appointments[i].startTime) {
      count++;
    }
  }
  return count;
}

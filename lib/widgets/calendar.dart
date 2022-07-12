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

  var userData = {};
  String? nickName;

  CollectionReference _reservationColRef =
      _firestore.collection('reservation').withConverter<ReservationModel>(
            fromFirestore: ReservationModel.fromFirestore,
            toFirestore: (ReservationModel reservationModel, _) =>
                reservationModel.toFirestore(),
          );

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

  void getUserName() async {
    try {
      var userSnap = await _firestore.collection('users').doc(_user!.uid).get();

      userData = userSnap.data()!;
      nickName = userData['nickname'];
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    //user model 써서 바꿔야합니다!
    getUserName();
    _dataSource = _DataSource(appointments);
    _reservationColRef
        .where('startTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .listen((snapshot) {
      var querySnapshot = snapshot;

      _dataSource.appointments!.clear();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // *첫번째 받아올 때(init) 모든게 docChange 로 인식된다
        // 1번의 경우는 add
        // 어떤 게 변화되었다 a.type = add / a의 변경사항을 dataSource 에 넣으면 된다.
        // -> doc change 에서 가져오면 된다

        // 2번의 경우는 delete modify
        // -> a.type = delete / a 의 변경사항을 반영하려면 리스트에서 찾아야 한다.
        // 찾으려면 결국 list traverse 를 해야한다.
        // dictionary(hash table) dic(docId) -> remove 를 하면 되지 않을까
        // dict -> list
        // dart에도 있을까?

        ReservationModel reservation = doc.data() as ReservationModel;
        Appointment app = Appointment(
            startTime: reservation.startTime!,
            endTime: reservation.endTime!.subtract(Duration(minutes: 2)),
            subject: reservation.user2Name == null
                ? reservation.user1Name!
                : reservation.user2Name == nickName
                    ? reservation.user2Name!
                    : reservation.user1Name!,
            color: Colors.teal,
            id: doc.id);

        _dataSource.appointments!.add(app);
      }
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
                  timeInterval: Duration(hours: 1),
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
                        color: meeting.subject.contains(nickName.toString())
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
                                              .contains(nickName.toString())
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
    // print(
    // "[DEBUG] in calendartap appoitments: ${calendarTapDetails.appointments}");
    final appointment = calendarTapDetails.appointments?[0];
    //빈 공간에 클릭 했을 때
    if (appointment == null) {
      await MatchingMethods().matchRoom(
        startTime: calendarTapDetails.date!,
        endTime: calendarTapDetails.date!.add(Duration(hours: 1)),
      );
    }

    //이미 예약이 있는 공간에 클릭했을 때
    else {
      if (appointment.subject == nickName) {
        //내가 넣은거에 다시 클릭할때
        docId = await appointment.id.toString();
        await _reservationColRef
            .doc(docId)
            .delete()
            .then((value) => print("DEBUG : calendar appointment deleted!"));
      } else {
        //상대방이 넣은거에 다시 클릭할때
        print('상대방이 넣은 거에 다시 클릭');
        await MatchingMethods().matchRoom(
          startTime: calendarTapDetails.date!,
          endTime: calendarTapDetails.date!.add(Duration(hours: 1)),
        );
      }
      return;
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

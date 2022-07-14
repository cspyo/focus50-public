import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/resources/matching_methods.dart';
import 'package:focus42/widgets/current_time_indicator.dart';
import 'package:get/get.dart';
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
  String nickName = "";

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
  Future<void> putCalendarData() async {
    // uid 있을때만 nickname 가져오고 없으면 nickname에는 ''가 들어감
    if (_user?.uid != null) {
      var userSnap = await _firestore.collection('users').doc(_user?.uid).get();
      userData = userSnap.data()!;
      nickName = userData['nickname'];
    }

    _reservationColRef
        .where('startTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .listen((snapshot) {
      var querySnapshot = snapshot;

      _dataSource.appointments!.clear();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        ReservationModel reservation = doc.data() as ReservationModel;
        if ((reservation.user1Name == null ||
            reservation.user2Name == null ||
            reservation.user1Name == nickName ||
            reservation.user2Name == nickName)) {
          Appointment app = Appointment(
              startTime: reservation.startTime!,
              endTime: reservation.endTime!.subtract(Duration(minutes: 2)),
              subject: reservation.user2Name == null
                  ? reservation.user1Name!
                  : (reservation.user1Name == nickName ||
                          reservation.user2Name == nickName)
                      ? nickName
                      : reservation.user2Name!,
              color: Colors.teal,
              id: doc.id);
          _dataSource.appointments!.add(app);
        }
      }
      _dataSource.notifyListeners(
          CalendarDataSourceAction.reset, _dataSource.appointments!);
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _dataSource = _DataSource(appointments);
    putCalendarData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= 1276
        ? Container(
            width: 856,
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
                  appointmentBuilder: (BuildContext context,
                      CalendarAppointmentDetails details) {
                    final Appointment meeting = details.appointments.first;
                    return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: meeting.subject.contains(nickName) &&
                                    _user?.uid != null
                                ? purple200
                                : Colors.white,
                            //user_uid null 체크는 로그인 안했을 때를 위해 추가함
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
                                                      .contains(nickName) &&
                                                  _user?.uid != null
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
            ))
        : Container(
            width: screenWidth - 420,
            child: SfCalendar(
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
                      fontSize: 26,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                  dayTextStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w400)),
              onTap: calendarTapped,
              view: CalendarView.day,
              monthViewSettings: MonthViewSettings(showAgenda: true),
              todayHighlightColor: purple300,
              appointmentBuilder:
                  (BuildContext context, CalendarAppointmentDetails details) {
                final Appointment meeting = details.appointments.first;
                return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: meeting.subject.contains(nickName)
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
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                      color: meeting.subject.contains(nickName)
                                          ? Colors.white
                                          : Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ))
                          ],
                        )));
              },
            ));
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    final appointment = calendarTapDetails.appointments?[0];
    print(_user?.uid);
    if (_user?.uid != null) {
      // 빈 공간에 클릭 했을 때
      if (appointment == null) {
        var datasource = _dataSource.appointments!.where((element) =>
            (element.startTime == calendarTapDetails.date &&
                element.subject == nickName));
        // 여백에 클릭했을 때 datasource appoitnemnts 배열과 현재 클릭한 calendartapdetails 및 useruid 비교
        if (datasource.isNotEmpty) {
          return;
        }
        // 정상적으로 빈공간에 클릭했을 때
        await MatchingMethods().matchRoom(
          startTime: calendarTapDetails.date!,
          endTime: calendarTapDetails.date!.add(Duration(hours: 1)),
        );
      }

      // 이미 예약이 있는 공간에 클릭했을 때
      else {
        if (appointment.subject == nickName) {
          // 내가 넣은거에 다시 클릭할때
          docId = await appointment.id.toString();
          var reservationSnap =
              await _firestore.collection('reservation').doc(docId).get();
          var event = reservationSnap.data()!;
          if (event['user2Name'] != null) {
            // user2에 데이터가 있으면
            await MatchingMethods().cancelRoom(docId);
          } else {
            // user2에 없다면
            _reservationColRef.doc(docId).delete();
          }
        } else {
          // 상대방이 넣은거에 다시 클릭할때
          await MatchingMethods().matchRoom(
            startTime: calendarTapDetails.date!,
            endTime: calendarTapDetails.date!.add(Duration(hours: 1)),
          );
        }
        return;
      }
    } else {
      Get.rootDelegate.toNamed(Routes.LOGIN);
    }
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

// int countAppointmentOverlap(_dataSource, calendarTapDetails) {
//   int count = 0;
//   for (var i = 0; i < _dataSource.appointments.length; i++) {
//     if (calendarTapDetails.date! == _dataSource.appointments[i].startTime) {
//       count++;
//     }
//   }
//   return count;
// }

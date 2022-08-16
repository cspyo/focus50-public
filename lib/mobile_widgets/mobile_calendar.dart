import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/resources/auth_method.dart';
import 'package:focus42/resources/matching_methods.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/reservation_model.dart';

class MobileCalendar extends StatefulWidget {
  @override
  MobileCalendarAppointment createState() => MobileCalendarAppointment();
}

class MobileCalendarAppointment extends State<MobileCalendar> {
  late CalendarDataSource _dataSource;
  List<Appointment> appointments = <Appointment>[];
  bool isHover = false;
  bool isEdit = false;
  String docId = '';
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? loadingAppointmentDateTime = null;

  String nickName = "";

  late CollectionReference _reservationColRef;

  int getCurrentDayPosition(screenwidth) {
    int defaultPositionValue = 49;
    String currentDay = DateFormat('E').format(DateTime.now());
    int oneBoxWidth = ((screenwidth - 489.5) / 7).round();
    switch (currentDay) {
      case 'Mon':
        return defaultPositionValue;
      case 'Tue':
        return defaultPositionValue + oneBoxWidth;
      case 'Wed':
        return defaultPositionValue + oneBoxWidth * 2;
      case 'Thu':
        return defaultPositionValue + oneBoxWidth * 3;
      case 'Fri':
        return defaultPositionValue + oneBoxWidth * 4;
      case 'Sat':
        return defaultPositionValue + oneBoxWidth * 5;
      case 'Sun':
        return defaultPositionValue + oneBoxWidth * 6;
      default:
        return defaultPositionValue;
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
  Future<void> putCalendarData(String? uid) async {
    // uid 있을때만 nickname 가져오고 없으면 nickname에는 ''가 들어감

    if (uid != null) {
      var user = await AuthMethods().getUserPublic(uid);
      nickName = user.nickname!;
    }

    _reservationColRef
        .where('startTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .listen((snapshot) {
      var querySnapshot = snapshot;
      List startTimeList = [];
      _dataSource.appointments!.clear();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        //자기꺼
        ReservationModel reservation = doc.data() as ReservationModel;
        if ((reservation.user1Name == nickName ||
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
          startTimeList.add(reservation.startTime);
        }
      }
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        ReservationModel reservation = doc.data() as ReservationModel;
        if (!startTimeList.contains(reservation.startTime)) {
          if (reservation.user1Name == null || reservation.user2Name == null) {
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
            startTimeList.add(reservation.startTime);
          }
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
    _reservationColRef =
        _firestore.collection('reservation').withConverter<ReservationModel>(
              fromFirestore: ReservationModel.fromFirestore,
              toFirestore: (ReservationModel reservationModel, _) =>
                  reservationModel.toFirestore(),
            );
    _dataSource = _DataSource(appointments);
    putCalendarData(auth.currentUser?.uid);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String? uid = auth.currentUser?.uid;
    return Container(
        margin: EdgeInsets.only(top: 10),
        width: screenWidth,
        height: screenHeight - 250,
        child: SfCalendar(
          dataSource: _dataSource,
          firstDayOfWeek: 1,
          viewHeaderHeight: 80,
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
          todayHighlightColor: purple300,
          appointmentBuilder:
              (BuildContext context, CalendarAppointmentDetails details) {
            final Appointment meeting = details.appointments.first;
            return meeting.startTime == loadingAppointmentDateTime
                ? Container(
                    alignment: Alignment.center,
                    width: 5,
                    height: 5,
                    child: CircularProgressIndicator(color: purple300),
                  )
                : Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: meeting.subject.contains(nickName) && uid != null
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
                                      fontSize: 10,
                                      color:
                                          meeting.subject.contains(nickName) &&
                                                  uid != null
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
    String? uid = auth.currentUser?.uid;
    final appointment = calendarTapDetails.appointments?[0];

    if (calendarTapDetails.date == loadingAppointmentDateTime) {
      return;
    }

    setState(() {
      loadingAppointmentDateTime = calendarTapDetails.date!;
    });
    if (calendarTapDetails.date!.isBefore(DateTime.now())) {
      setState(() {
        loadingAppointmentDateTime = null;
      });
      return;
    }
    if (uid != null) {
      // 빈 공간에 클릭 했을 때
      if (appointment == null) {
        var datasource = _dataSource.appointments!.where((element) =>
            (element.startTime == calendarTapDetails.date &&
                element.subject == nickName));
        // 여백에 클릭했을 때 datasource appoitnemnts 배열과 현재 클릭한 calendartapdetails 및 useruid 비교
        if (datasource.isNotEmpty) {
          setState(() {
            loadingAppointmentDateTime = null;
          });
          return;
        }
        // 죄송합니다. 더티 코드 입니다. 빈공간에 클릭했을때, circularindicator가 늦게 나타나서, 임시방편으로 appointment를 하나 만들고 그 위에 circular indicator를 빌드하도록 했습니다.
        Appointment app = Appointment(
          startTime: calendarTapDetails.date!,
          endTime: calendarTapDetails.date!.add(Duration(minutes: 55)),
          subject: '',
          color: purple100,
        );
        _dataSource.appointments!.add(app);
        _dataSource.notifyListeners(
            CalendarDataSourceAction.reset, _dataSource.appointments!);
        // 정상적으로 빈공간에 클릭했을 때
        await MatchingMethods().matchRoom(
          startTime: calendarTapDetails.date!,
          endTime: calendarTapDetails.date!.add(Duration(hours: 1)),
        );
        setState(() {
          loadingAppointmentDateTime = null;
        });
      }

      // 이미 예약이 있는 공간에 클릭했을 때
      else {
        if (appointment.subject == nickName) {
          // 내가 넣은거에 다시 클릭할때
          docId = await appointment.id.toString();
          await MatchingMethods().cancelRoom(docId);
        } else {
          // 상대방이 넣은거에 다시 클릭할때
          await MatchingMethods().matchRoom(
            startTime: calendarTapDetails.date!,
            endTime: calendarTapDetails.date!.add(Duration(hours: 1)),
          );
        }
        setState(() {
          loadingAppointmentDateTime = null;
        });
        return;
      }
    } else {
      setState(() {
        loadingAppointmentDateTime = null;
      });
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

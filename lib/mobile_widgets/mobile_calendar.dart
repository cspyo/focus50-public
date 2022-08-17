import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/auth_method.dart';
import 'package:focus42/resources/matching_methods.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../models/reservation_model.dart';

class MobileCalendar extends StatefulWidget {
  @override
  MobileCalendarAppointment createState() => MobileCalendarAppointment();
}

class MobileCalendarAppointment extends State<MobileCalendar> {
  bool isHover = false;
  bool isEdit = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, UserPublicModel> users = {};
  bool isSignedUp = false;

  final LOADING = "loading";
  final RESERVE = "reserve";
  final MATCHING = "matching";
  final MATCHED = "matched";
  final CANCEL = "cancel";

  final HOVER = "hover";
  final CANT_RESERVE = "cant reserve";

  late CollectionReference _reservationColRef;

  CalendarController _calendarController = CalendarController();
  CalendarDetails? details;

  List<Appointment> appointments = <Appointment>[];
  List<DateTime> reservationTimeList = <DateTime>[];
  List<TimeRegion> onHoverRegions = <TimeRegion>[];
  List<TimeRegion> reservationRegions = <TimeRegion>[];
  List<TimeRegion> cantReserveRegions = <TimeRegion>[];

  Future<void> putCalendarData() async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      isSignedUp = await AuthMethods().isSignedUp(uid: uid);
      if (isSignedUp) {
        var user = await AuthMethods().getUserPublic(uid);
        if (!users.containsKey(uid)) {
          users.addAll({
            uid: user,
          });
        }
      }
    } else {
      uid = "";
    }

    _reservationColRef
        .where('startTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .listen((snapshot) async {
      var querySnapshot = snapshot;
      appointments.clear();
      reservationRegions.clear();
      cantReserveRegions.clear();
      reservationTimeList.clear();
      setState(() {});
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        ReservationModel reservation = doc.data() as ReservationModel;
        // 나의 예약 가져오기
        if ((reservation.user1Uid == uid || reservation.user2Uid == uid)) {
          DateTime? startTime = reservation.startTime!;
          Appointment app;

          // 매칭이 완료된 예약이라면
          if (reservation.isFull!) {
            var partnerUid = reservation.user1Uid == uid
                ? reservation.user2Uid
                : reservation.user1Uid;
            if (!users.containsKey(partnerUid!)) {
              var partner = await AuthMethods().getUserPublic(partnerUid);
              users.addAll({
                partnerUid: partner,
              });
            }
            app = Appointment(
              startTime: reservation.startTime!,
              endTime: reservation.endTime!,
              notes: partnerUid,
              subject: MATCHED, // LOADING,MATCHING,MATCHED
              id: doc.id,
            );
          } else {
            // 매칭이 안된 예약이라면
            app = Appointment(
              startTime: reservation.startTime!,
              endTime: reservation.endTime!,
              subject: MATCHING,
              id: doc.id,
            );
          }
          appointments.removeWhere((element) => element.startTime == startTime);
          appointments.add(app);

          cantReserveRegions.add(
            TimeRegion(
              startTime: startTime.subtract(Duration(minutes: 30)),
              endTime: startTime.add(Duration(minutes: 60)),
              enablePointerInteraction: false,
              text: CANT_RESERVE,
            ),
          );

          reservationTimeList.add(reservation.startTime!);
          reservationTimeList.add(startTime.add(Duration(minutes: 30)));
          reservationTimeList.add(startTime.subtract(Duration(minutes: 30)));
        }
        setState(() {});
      }
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        ReservationModel reservation = doc.data() as ReservationModel;
        if (!reservationTimeList.contains(reservation.startTime)) {
          if (reservation.user1Uid == null || reservation.user2Uid == null) {
            // uid 로 유저정보 가져와서 map에 저장
            var partnerUid = reservation.user1Uid == null
                ? reservation.user2Uid
                : reservation.user1Uid;

            if (!users.containsKey(partnerUid!)) {
              try {
                var partner = await AuthMethods().getUserPublic(partnerUid);
                users.addAll({
                  partnerUid: partner,
                });
              } catch (e) {
                print(e);
              }
            }

            DateTime? startTime = reservation.startTime!;
            reservationRegions.add(TimeRegion(
              startTime: startTime,
              endTime: startTime.add(Duration(minutes: 30)),
              text: reservation.user1Uid != null
                  ? reservation.user1Uid
                  : reservation.user2Uid,
            ));
          }
        }
      }
    });
    setState(() {});
  }

  _DataSource _getDataSource() {
    return _DataSource(appointments);
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    String? uid = _auth.currentUser?.uid;
    DateTime? tappedDate = calendarTapDetails.date;

    // 로그인이 안되어있으면 로그인 페이지로
    if (uid == null) {
      Get.rootDelegate.toNamed(Routes.LOGIN);
      return;
    }

    // 프로필 작성이 안되어 있으면 add profile 페이지로
    if (!isSignedUp) {
      Get.rootDelegate.toNamed(Routes.ADD_PROFILE);
      return;
    }

    // calendar cell 이 눌렸을 때
    if (calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      if (calendarTapDetails.date!.isBefore(DateTime.now())) {
        return;
      }

      DateTime startTime = tappedDate!;
      DateTime endTime = tappedDate.add(Duration(hours: 1));

      onHoverRegions.clear();
      cantReserveRegions.add(
        TimeRegion(
          startTime: startTime.subtract(Duration(minutes: 30)),
          endTime: startTime.add(Duration(minutes: 60)),
          enablePointerInteraction: false,
          text: CANT_RESERVE,
        ),
      );

      reservationTimeList.add(startTime);
      reservationTimeList.add(startTime.add(Duration(minutes: 30)));
      reservationTimeList.add(startTime.subtract(Duration(minutes: 30)));
      appointments.add(Appointment(
          startTime: startTime, endTime: endTime, subject: RESERVE));
      setState(() {});
    }
    // Appointment 가 눌렸을 때 (취소 버튼만 눌리게 바로 return)
    else if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      return;
    } else {
      return;
    }
    setState(() {});
  }

  // 캘린더 안에서의 hover action
  void onHover(PointerEvent event) {
    details =
        _calendarController.getCalendarDetailsAtOffset!(event.localPosition);

    if (details != null) {
      onHoverRegions.clear();

      if (details!.targetElement == CalendarElement.calendarCell) {
        // 현재 시간보다 뒤쪽이면 호버 안되게
        if (details!.date!.isBefore(DateTime.now())) {
          onHoverRegions.clear();
          setState(() {});
          return;
        }
        //
        if (reservationTimeList.contains(details?.date)) {
          onHoverRegions.clear();
          setState(() {});
          return;
        }
        DateTime? timeRegionDateTime = details!.date;
        onHoverRegions.add(
          TimeRegion(
            startTime: timeRegionDateTime!,
            endTime: timeRegionDateTime.add(Duration(hours: 1)),
            enablePointerInteraction: true,
            text: HOVER,
          ),
        );
      } else if (details!.targetElement == CalendarElement.appointment) {}
    }
    setState(() {
      isHover = true;
    });
  }

  // 캘린더에서 마우스가 나갔을 때
  void onExit(PointerEvent details) {
    setState(() {
      onHoverRegions.clear();
      isHover = false;
    });
  }

  // 다른 사람 예약, 현재 마우스 위치의 예약 가능 표시, calendarTap을 막아주는 region 리스트들 합쳐서 regionBuilder에 보내기
  List<TimeRegion> _getTimeRegions() {
    List<TimeRegion> regions = [
      ...reservationRegions,
      ...cantReserveRegions,
      ...onHoverRegions,
    ];
    return regions;
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
    putCalendarData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String? uid = _auth.currentUser?.uid;
    return Container(
        width: screenWidth - 40,
        height: screenHeight - 210,
        margin: EdgeInsets.only(
          top: 10,
        ),
        padding: EdgeInsets.only(right: 5),
        // decoration: BoxDecoration(
        //     border: Border(right: BorderSide(color: Color(0xffEBEBEB)))),
        child: Stack(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: onHover,
              onExit: onExit,
              child: SfCalendarTheme(
                data: SfCalendarThemeData(
                  // 마우스 호버했을 때 경계선
                  selectionBorderColor: Colors.white,
                ),
                child: SfCalendar(
                  controller: _calendarController,
                  dataSource: _getDataSource(),

                  // 기본 캘린더 경계선
                  cellBorderColor: Colors.grey.withOpacity(0.4),
                  // 클릭했을 때 경계선
                  selectionDecoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Colors.transparent,
                  ),
                  viewHeaderHeight: 100,
                  headerHeight: 0,
                  timeSlotViewSettings: TimeSlotViewSettings(
                      dayFormat: 'EEE',
                      timeIntervalHeight: 40,
                      timeIntervalWidth: -2,
                      timeInterval: Duration(minutes: 30),
                      timeFormat: 'HH:mm'),
                  viewHeaderStyle: ViewHeaderStyle(
                      backgroundColor: calendarBackgroundColor,
                      dateTextStyle: TextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                      dayTextStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400)),
                  onTap: calendarTapped,
                  view: CalendarView.day,
                  monthViewSettings: MonthViewSettings(showAgenda: true),
                  todayHighlightColor: purple300,
                  specialRegions: _getTimeRegions(),
                  // 남의 예약 보여주는 부분
                  timeRegionBuilder: (BuildContext context,
                      TimeRegionDetails timeRegionDetails) {
                    if (timeRegionDetails.region.text == HOVER) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: purple300, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: 150,
                        height: 80,
                        padding: EdgeInsets.all(3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 132,
                              height: 32,
                              decoration: BoxDecoration(
                                color: purple300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // border:
                              // Border.all(color: purple300, width: 2)),
                              child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    '예약하기',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      );
                    } else if (timeRegionDetails.region.text == CANT_RESERVE) {
                      Color cantReserveColor;
                      if (timeRegionDetails.date.day == DateTime.now().day) {
                        cantReserveColor = Colors.white; //sda
                      } else {
                        cantReserveColor = calendarBackgroundColor;
                      }
                      return Container(
                        color: cantReserveColor,
                        width: 150,
                        height: 100,
                      );
                    } else {
                      String photoUrl =
                          users[timeRegionDetails.region.text]!.photoUrl!;
                      String nickname =
                          users[timeRegionDetails.region.text]!.nickname!;
                      // String job = users[timeRegionDetails.region.text]!.job!;
                      return Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.black38,
                                backgroundImage: NetworkImage(
                                  photoUrl,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 5),
                                  decoration: BoxDecoration(),
                                  height: 30,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        nickname,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ]),
                      );
                    }
                  },
                  // 내 예약 보여주는 부분
                  appointmentBuilder: (BuildContext context,
                      CalendarAppointmentDetails details) {
                    final Appointment appointment = details.appointments.first;
                    final String subject = appointment.subject;
                    final DateTime startTime = appointment.startTime;
                    final DateTime endTime = appointment.endTime;
                    final String startTimeFormatted =
                        DateFormat('Hm').format(startTime);
                    final String endTimeFormatted =
                        DateFormat('Hm').format(endTime);

                    // 로딩중~
                    if (subject == LOADING) {
                      return Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: CircularProgressIndicator(color: purple300),
                        ),
                      );
                    }
                    // 캘린더 그냥 탭했을 때 (예약하시겠습니까?)
                    else if (subject == RESERVE) {
                      return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: purple300, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  appointment.subject = LOADING;
                                  try {
                                    await MatchingMethods().matchRoom(
                                        startTime: startTime, endTime: endTime);
                                  } catch (err) {
                                    print(err);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: purple300,
                                  minimumSize: Size(40, 50),
                                  side: BorderSide(
                                    width: 1.5,
                                    color: purple300,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "예약",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  appointments.remove(appointment);
                                  reservationTimeList.remove(startTime);
                                  reservationTimeList.remove(
                                      startTime.add(Duration(minutes: 30)));
                                  reservationTimeList.remove(startTime
                                      .subtract(Duration(minutes: 30)));
                                  cantReserveRegions.removeWhere((element) =>
                                      element.startTime ==
                                      startTime
                                          .subtract(Duration(minutes: 30)));
                                  setState(() {}); //취소 누르고 가만히 있으면 안사라져서 추가함
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  minimumSize: Size(40, 50),
                                  side: BorderSide(
                                    width: 1.5,
                                    color: purple300,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "취소",
                                  style: TextStyle(
                                    color: purple300,
                                  ),
                                ),
                              ),
                            ],
                          ));
                    }
                    // 예약 (매칭중)
                    else if (subject == MATCHING) {
                      return Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: purple100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: purple300,
                              // color: Color.fromARGB(255, 119, 119, 119),
                              width: 2),
                        ),
                        child: Stack(children: [
                          Container(
                            padding:
                                EdgeInsets.only(left: 5, top: 5, bottom: 5),
                            width: 150,
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "${startTimeFormatted}~${endTimeFormatted}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '매칭중..',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10,
                                          color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: IconButton(
                                onPressed: () {
                                  appointment.subject = CANCEL;
                                  setState(() {});
                                },
                                padding: EdgeInsets.all(0),
                                icon: Icon(
                                  Icons.close,
                                  color: purple200,
                                ),
                                hoverColor: Colors.transparent,
                              ),
                            ),
                          )
                        ]),
                      );
                    }
                    // 예약 (매칭 완료 - 상대방 정보 보여주기)
                    else if (subject == MATCHED) {
                      return Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: purple100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: purple300, width: 2),
                        ),
                        child: Stack(children: [
                          Container(
                            padding:
                                EdgeInsets.only(left: 5, top: 5, bottom: 5),
                            width: 150,
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "${startTimeFormatted}~${endTimeFormatted}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    width: 50,
                                    child: Text(
                                      "${users[appointment.notes]!.nickname!}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          color: purple200),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: IconButton(
                                onPressed: () {
                                  appointment.subject = CANCEL;
                                  setState(() {});
                                },
                                padding: EdgeInsets.all(0),
                                icon: Icon(
                                  Icons.close,
                                  color: purple200,
                                ),
                                hoverColor: Colors.transparent,
                              ),
                            ),
                          )
                        ]),
                      );
                    }
                    // 예약 취소를 눌렀을 때 (취소하시겠습니까?)
                    else if (subject == CANCEL) {
                      return Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colors.red, width: 1.5)),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    String? docId = appointment.id as String;

                                    appointment.subject = LOADING;
                                    setState(() {});
                                    try {
                                      await MatchingMethods().cancelRoom(docId);
                                    } catch (e) {
                                      if (appointment.notes == null) {
                                        appointment.subject = MATCHING;
                                      } else {
                                        appointment.subject = MATCHED;
                                      }
                                    }
                                    AnalyticsMethod().logCancelReservation();
                                  },
                                  child: Text(
                                    "삭제",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(40, 50),
                                    primary: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (appointment.notes == null) {
                                      appointment.subject = MATCHING;
                                    } else {
                                      appointment.subject = MATCHED;
                                    }
                                    setState(() {});
                                  },
                                  child: Text(
                                    "취소",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(40, 50),
                                    primary: Colors.white,
                                    side: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                          ));
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
          ],
        ));
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/auth/show_auth_dialog.dart';
import 'package:focus42/feature/indicator/circular_progress_indicator.dart';
import 'package:focus42/resources/matching_methods.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/view_models.dart/appointments_notifier.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/view_models.dart/timeregions_notifier.dart';
import 'package:focus42/view_models.dart/users_notifier.dart';
import 'package:focus42/widgets/current_time_indicator.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class Calendar extends ConsumerStatefulWidget {
  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends ConsumerState<Calendar> {
  bool isEdit = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int tabletBoundSize = 1200;

  final LOADING_RESERVE = "loading reserve";
  final LOADING_CANCEL = "loading cancel";

  final RESERVE = "reserve";
  final MATCHING = "matching";
  final MATCHED = "matched";
  final CANCEL = "cancel";

  final HOVER = "hover";
  final CANT_RESERVE = "cant reserve";

  CalendarController _calendarController = CalendarController();
  CalendarDetails? details;

  List<TimeRegion> onHoverRegions = <TimeRegion>[];
  late ReservationViewModel reservationViewModel;

  late var database;
  late String groupId;
  //highlighter 위치 정하는 함수
  int _getFirstDayOfWeek(int highlighterPosition) {
    int currentDay = DateTime.now().weekday;
    int firstDayOfWeek =
        (currentDay - (highlighterPosition - 1)) % DateTime.daysPerWeek;
    return firstDayOfWeek == 0 ? DateTime.daysPerWeek : firstDayOfWeek;
  }

  double _getCurrentDayPosition(screenWidth) {
    int defaultPositionValue = 49;
    int currentDay = DateTime.tuesday;
    int oneBoxWidth = ((screenWidth - 560) / 7).round();
    return defaultPositionValue + oneBoxWidth * (currentDay - 1);
  }

  double _getCurrentDayPositionSmall(screenWidth) {
    int defaultPositionValue = 49;
    int currentDay = DateTime.tuesday;
    int oneBoxWidth = ((screenWidth - 100 - defaultPositionValue) / 7).round();
    return defaultPositionValue + oneBoxWidth * (currentDay - 1);
  }

  void _calendarTapped(CalendarTapDetails calendarTapDetails) async {
    String? uid = _auth.currentUser?.uid;
    DateTime? tappedDate = calendarTapDetails.date;

    final appointmentsNotifier = ref.read(appointmentsProvider.notifier);
    final timeRegionNotifier = ref.read(timeRegionsProvider.notifier);

    // 로그인이 안되어있으면 회원가입 페이지로
    if (uid == null) {
      ShowAuthDialog().showSignUpDialog(context);
      return;
    }

    // calendar cell 이 눌렸을 때
    if (calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      // 현재 시간 이전은 불가능
      if (calendarTapDetails.date!.isBefore(DateTime.now())) {
        return;
      }

      DateTime startTime = tappedDate!;
      DateTime endTime = tappedDate.add(Duration(hours: 1));

      onHoverRegions.clear();
      timeRegionNotifier.addCantReserveRegions(
        TimeRegion(
          startTime: startTime.subtract(Duration(minutes: 30)),
          endTime: startTime.add(Duration(minutes: 60)),
          enablePointerInteraction: false,
          text: CANT_RESERVE,
        ),
      );

      reservationViewModel.cantHoverTimeList.add(startTime);
      reservationViewModel.cantHoverTimeList
          .add(startTime.add(Duration(minutes: 30)));
      reservationViewModel.cantHoverTimeList
          .add(startTime.subtract(Duration(minutes: 30)));
      appointmentsNotifier.addAppointment(Appointment(
          startTime: startTime, endTime: endTime, subject: RESERVE));
    }
    // Appointment 가 눌렸을 때 (취소 버튼만 눌리게 바로 return)
    else if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      return;
    } else {
      return;
    }
  }

  // 캘린더 안에서의 hover action
  void _onHover(PointerEvent event) {
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
        // 호버할 수 없는 시간(예약이 있는 곳, 예약할 수 없는 곳)은 호버 안되게
        if (reservationViewModel.cantHoverTimeList.contains(details?.date)) {
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
    setState(() {});
  }

  // 캘린더에서 마우스가 나갔을 때
  void _onExit(PointerEvent details) {
    setState(() {
      onHoverRegions.clear();
    });
  }

  List<TimeRegion> _getTimeRegions() {
    final timeRegions = ref.read(timeRegionsProvider);

    List<TimeRegion> regions = [
      ...timeRegions,
      ...onHoverRegions,
    ];
    return regions;
  }

  @override
  void initState() {
    super.initState();
    groupId = ref.read(activatedGroupIdProvider);
    reservationViewModel = ref.read(reservationViewModelProvider);
    reservationViewModel.startView();
    database = ref.read(databaseProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletSize = screenWidth < tabletBoundSize ? true : false;

    final appointments = ref.watch(appointmentsProvider);
    final timeRegions = ref.watch(timeRegionsProvider);
    final newDatabase = ref.watch(databaseProvider);

    final oldGroupId = groupId;
    final newGroupId = ref.watch(activatedGroupIdProvider);

    if (database.uid != newDatabase.uid || oldGroupId != newGroupId) {
      reservationViewModel.cancelListener();
      reservationViewModel = ref.read(reservationViewModelProvider);
      groupId = newGroupId;
      database = newDatabase;
      reservationViewModel.startView();
    }

    return Container(
        width: isTabletSize ? screenWidth : screenWidth - 440,
        child: Stack(
          children: [
            Positioned(
              left: isTabletSize
                  ? _getCurrentDayPositionSmall(screenWidth)
                  : _getCurrentDayPosition(screenWidth),
              top: 100,
              child: CurrentTimeIndicator(),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: _onHover,
              onExit: _onExit,
              child: SfCalendarTheme(
                data: SfCalendarThemeData(
                  // 마우스 호버했을 때 경계선
                  selectionBorderColor: Colors.white,
                ),
                child: SfCalendar(
                  controller: _calendarController,
                  // 기본 캘린더 경계선
                  cellBorderColor: Colors.grey.withOpacity(0.4),
                  // 클릭했을 때 경계선
                  selectionDecoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Colors.transparent,
                  ),
                  firstDayOfWeek: _getFirstDayOfWeek(2),
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
                  onTap: _calendarTapped,
                  view: CalendarView.week,
                  monthViewSettings: MonthViewSettings(showAgenda: true),
                  todayHighlightColor: purple300,
                  // 남의 예약 보여주는 부분
                  specialRegions: [...timeRegions, ...onHoverRegions],
                  timeRegionBuilder: (context, details) =>
                      _timeRegionBuilder(context, details),
                  // 내 예약 보여주는 부분
                  dataSource: _DataSource(appointments),
                  appointmentBuilder: (context, details) => _appointmentBuilder(
                      context, details, isTabletSize, newGroupId),
                ),
              ),
            ),
          ],
        ));
  }

  // TimeRegionBuilder
  Widget _timeRegionBuilder(
      BuildContext context, TimeRegionDetails timeRegionDetails) {
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
        cantReserveColor = highlighterColor;
      } else {
        cantReserveColor = calendarBackgroundColor;
      }
      return Container(
        color: cantReserveColor,
        width: 150,
        height: 100,
      );
    } else {
      final users = ref.read(usersProvider);
      List<String> userIds = timeRegionDetails.region.text!.split(',');
      int reservedUserCount = userIds.length;
      List<String> photoUrl = [users[userIds.first]!.photoUrl!];
      for (int i = 0; i < reservedUserCount; i++) {
        photoUrl.add(users[userIds[i]]!.photoUrl!);
      }
      String nickname = users[userIds.first]!.nickname!;

      return _buildCalendarItem(
          context, users, userIds, reservedUserCount, nickname);
    }
  }

  Widget _buildCalendarItem(
      BuildContext context, users, userIds, reservedUserCount, nickname) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletSize = screenWidth < tabletBoundSize ? true : false;
    return Container(
      padding: EdgeInsets.only(
        left: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildUserProfileImage(reservedUserCount, users, userIds),
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 4),
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: isTabletSize
                        ? (screenWidth - 49) / 7 - 61
                        : (screenWidth - 489.5) / 7 - 58,
                    alignment: Alignment.centerLeft,
                    child: reservedUserCount == 1
                        ? Text(
                            "${nickname}",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            // maxLines: 1,
                            // textAlign: TextAlign.center,
                          )
                        : Text(
                            "${nickname} 외 ${reservedUserCount - 1}명",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            // maxLines: 1,
                            // textAlign: TextAlign.center,
                          ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  //
  Widget _appointmentBuilder(
    BuildContext context,
    CalendarAppointmentDetails details,
    bool isTabletSize,
    final String _groupId,
  ) {
    final appointmentNotifier = ref.read(appointmentsProvider.notifier);
    final timeRegionNotifier = ref.read(timeRegionsProvider.notifier);
    final Appointment appointment = details.appointments.first;
    final String subject = appointment.subject;
    final String? notes = appointment.notes;
    final DateTime startTime = appointment.startTime;
    final DateTime endTime = appointment.endTime;
    final String startTimeFormatted = DateFormat('Hm').format(startTime);
    final String endTimeFormatted =
        DateFormat('Hm').format(endTime.subtract(Duration(minutes: 10)));
    // 로딩중~
    if (subject == LOADING_RESERVE) {
      return Container(
        decoration: BoxDecoration(
          color: purple100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: purple300,
            width: 2,
          ),
        ),
        child: Center(
            child: CircularIndicator(
          color: MyColors.purple300,
          size: 15,
        )),
      );
    } else if (subject == LOADING_CANCEL) {
      return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red, width: 1.5)),
          child: CircularIndicator(
            color: Colors.red,
            size: 15,
          ));
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
                  setState(() {
                    appointment.subject = LOADING_RESERVE;
                  });

                  try {
                    await MatchingMethods(database: database).matchRoom(
                      startTime: startTime,
                      endTime: endTime,
                      groupId: _groupId,
                    );
                  } catch (err) {
                    appointment.subject = RESERVE;
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: purple300,
                  minimumSize: Size(0, 40),
                  side: BorderSide(
                    width: 1.5,
                    color: purple300,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                  padding:
                      isTabletSize ? EdgeInsets.all(10) : EdgeInsets.all(16),
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
                  appointmentNotifier.deleteAppointment(appointment.startTime);
                  reservationViewModel.cantHoverTimeList.remove(startTime);
                  reservationViewModel.cantHoverTimeList
                      .remove(startTime.add(Duration(minutes: 30)));
                  reservationViewModel.cantHoverTimeList
                      .remove(startTime.subtract(Duration(minutes: 30)));
                  timeRegionNotifier.deleteCantReserveRegions(
                      startTime.subtract(Duration(minutes: 30)));
                  setState(() {}); //취소 누르고 가만히 있으면 안사라져서 추가함
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    minimumSize: Size(0, 40),
                    side: BorderSide(
                      width: 1.5,
                      color: purple300,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding:
                        isTabletSize ? EdgeInsets.all(10) : EdgeInsets.all(16)),
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
            padding: EdgeInsets.only(left: 5, top: 5, bottom: 5),
            width: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${startTimeFormatted}~${endTimeFormatted}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '매칭중...',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
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
      final users = ref.read(usersProvider);
      final database = ref.read(databaseProvider);
      List<String> userIds = notes!.split(',');
      int reservedUserCount = userIds.length;
      userIds.removeWhere((element) => element == database.uid);

      return Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: purple100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: purple300, width: 2),
        ),
        child: Stack(children: [
          Container(
            padding: EdgeInsets.only(left: 5, top: 5, bottom: 5),
            width: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${startTimeFormatted}~${endTimeFormatted}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 150,
                    child: Row(
                      children: [
                        Icon(Icons.people_alt_rounded, size: 15.0),
                        SizedBox(
                          width: 4,
                        ),
                        reservedUserCount == 1
                            ? Text(
                                "${users[userIds.first]!.nickname!}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: purple200),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                "${users[userIds.first]!.nickname!} 외 ${reservedUserCount - 1}명",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: purple200),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                      ],
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
              border: Border.all(color: Colors.red, width: 1.5)),
          child: Container(
            width: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String? docId = appointment.id as String;

                    appointment.subject = LOADING_CANCEL;
                    setState(() {});
                    final database = ref.read(databaseProvider);
                    try {
                      await MatchingMethods(database: database)
                          .cancelRoom(docId);
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
                    minimumSize: Size(0, 40),
                    primary: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding:
                        isTabletSize ? EdgeInsets.all(10) : EdgeInsets.all(16),
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
                    minimumSize: Size(0, 40),
                    primary: Colors.white,
                    side: BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding:
                        isTabletSize ? EdgeInsets.all(10) : EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ));
    } else {
      return Container();
    }
  }

  Widget _buildUserProfileImage(
    reservedUserCount,
    users,
    userIds,
  ) {
    assert([1, 2, 3].contains(reservedUserCount));
    switch (reservedUserCount) {
      case 1:
        return Container(
          width: 38,
          height: 30,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    users[userIds.first]!.photoUrl!,
                    fit: BoxFit.cover,
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      case 2:
        return Container(
          width: 38,
          height: 30,
          child: Stack(
            children: [
              Positioned(
                top: 3,
                left: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    users[userIds.first]!.photoUrl!,
                    fit: BoxFit.cover,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              Positioned(
                top: 3,
                left: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    users[userIds[1]]!.photoUrl!,
                    fit: BoxFit.cover,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      case 3:
        return Container(
          width: 38,
          height: 30,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    users[userIds[0]]!.photoUrl!,
                    fit: BoxFit.cover,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    users[userIds[1]]!.photoUrl!,
                    fit: BoxFit.cover,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    users[userIds[2]]!.photoUrl!,
                    fit: BoxFit.cover,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

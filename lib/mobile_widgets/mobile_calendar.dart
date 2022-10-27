import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/auth/presentation/login_dialog.dart';
import 'package:focus42/feature/indicator/circular_progress_indicator.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/resources/matching_methods.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/view_models.dart/appointments_notifier.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/view_models.dart/timeregions_notifier.dart';
import 'package:focus42/view_models.dart/users_notifier.dart';
import 'package:focus42/widgets/group_setting_widget.dart';
import 'package:focus42/widgets/group_widget.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class MobileCalendar extends ConsumerStatefulWidget {
  MobileCalendar({
    Key? key,
    required this.calendarController,
    required this.isNotificationOpen,
    // required this.changeVisibleDates,
  }) : super(key: key);
  CalendarController calendarController;
  bool isNotificationOpen;
  // Function(List<DateTime>) changeVisibleDates;
  List<DateTime> visibleDates = [
    DateTime.now(),
  ];

  @override
  MobileCalendarAppointment createState() => MobileCalendarAppointment();
}

class MobileCalendarAppointment extends ConsumerState<MobileCalendar> {
  bool isEdit = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final LOADING_RESERVE = "loading reserve";
  final LOADING_CANCEL = "loading cancel";

  final RESERVE = "reserve";
  final MATCHING = "matching";
  final MATCHED = "matched";
  final CANCEL = "cancel";

  final HOVER = "hover";
  final CANT_RESERVE = "cant reserve";

  CalendarDetails? details;

  late var database;
  late String groupId;

  late ReservationViewModel reservationViewModel;

  Future<void> _showLoginDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return LoginDialog();
      },
    );
  }

  void _calendarTapped(CalendarTapDetails calendarTapDetails) async {
    String? uid = _auth.currentUser?.uid;
    DateTime? tappedDate = calendarTapDetails.date;

    final appointmentsNotifier = ref.read(appointmentsProvider.notifier);
    final timeRegionNotifier = ref.read(timeRegionsProvider.notifier);

    // 로그인이 안되어있으면 로그인 페이지로
    if (uid == null) {
      _showLoginDialog();
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

  // 캘린더에서 마우스가 나갔을 때
  void _onExit(PointerEvent details) {
    setState(() {});
  }

  void _changeActivatedGroup(String newGroupId) {
    ref.read(activatedGroupIdProvider.notifier).state = newGroupId;
    setState(() {});
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
  Widget build(BuildContext context) {
    final _myGroupStream = ref.watch(myGroupFutureProvider);
    final _myActivatedGroupId = ref.watch(activatedGroupIdProvider);

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

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final appointments = ref.watch(appointmentsProvider);
    final timeRegions = ref.watch(timeRegionsProvider);

    return Container(
      width: screenWidth - 40,
      // height: screenHeight - 235,
      // height: screenHeight - 267,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
                color: purple300,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.calendarController.backward!();
                    });
                  },
                ),
                Text(
                  DateFormat.MMMd().format(widget.visibleDates.first),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.calendarController.forward!();
                    });
                  },
                ),
                // Expanded(
                //   child: ListItemsBuilder2<GroupModel>(
                //     data: _myGroupStream,
                //     itemBuilder: (context, model) => _buildToggleButtonUi(
                //       context,
                //       model,
                //       _myActivatedGroupId == model.id ? true : false,
                //     ),
                //     creator: () => new GroupModel(
                //       id: 'public',
                //       name: '전체',
                //     ),
                //     axis: Axis.horizontal,
                //   ),
                // ),
              ],
            ),
          ),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              // onHover: onHover,
              onExit: _onExit,
              child: SfCalendarTheme(
                data: SfCalendarThemeData(
                  // 마우스 호버했을 때 경계선
                  selectionBorderColor: Colors.white,
                ),
                child: SfCalendar(
                  controller: widget.calendarController,
                  // 기본 캘린더 경계선
                  cellBorderColor: Colors.grey.withOpacity(0.4),
                  // 클릭했을 때 경계선
                  selectionDecoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Colors.transparent,
                  ),
                  viewHeaderHeight: 0,
                  headerHeight: 0,
                  onViewChanged: (ViewChangedDetails details) {
                    widget.visibleDates = details.visibleDates;
                  },
                  timeSlotViewSettings: TimeSlotViewSettings(
                      dayFormat: 'EEE',
                      timeIntervalHeight: 40,
                      timeIntervalWidth: -2,
                      timeInterval: Duration(minutes: 30),
                      timeFormat: 'HH:mm'),
                  onTap: _calendarTapped,
                  view: CalendarView.day,
                  monthViewSettings: MonthViewSettings(showAgenda: true),
                  todayHighlightColor: purple300,
                  // 남의 예약 보여주는 부분
                  specialRegions: [...timeRegions],
                  timeRegionBuilder: _timeRegionBuilder,
                  // 내 예약 보여주는 부분
                  dataSource: _DataSource(appointments),
                  appointmentBuilder: (context, details) =>
                      _appointmentBuilder(context, details, newGroupId),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildToggleButtonUi(
  //     BuildContext context, GroupModel group, bool isThisGroupActivated) {}

  Future<dynamic> _popupGroupSettingDialog(
      BuildContext context, GroupModel group) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GroupSettingAlertDialog(database: database, group: group);
        });
  }

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
        cantReserveColor = Colors.white;
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
    return Container(
      padding: EdgeInsets.only(
        left: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildUserProfileImage(reservedUserCount, users, userIds),
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 8),
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    alignment: Alignment.centerLeft,
                    child: reservedUserCount == 1
                        ? Text(
                            "${nickname}",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            "${nickname} 외 ${reservedUserCount - 1}명",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
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

  Widget _appointmentBuilder(BuildContext context,
      CalendarAppointmentDetails details, String _groupId) {
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
          child: CircularIndicator(size: 15, color: Colors.red));
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
                        groupId: _groupId);
                  } catch (err) {
                    appointment.subject = RESERVE;
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
                    AnalyticsMethod().mobileLogCancelReservation();
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

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

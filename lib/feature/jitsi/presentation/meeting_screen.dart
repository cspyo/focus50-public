import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/consts/routes.dart';
import 'package:focus50/feature/auth/data/user_model.dart';
import 'package:focus50/feature/calendar/data/reservation_model.dart';
import 'package:focus50/feature/jitsi/consts/times.dart';
import 'package:focus50/feature/jitsi/jitsi_meet_methods.dart';
import 'package:focus50/feature/jitsi/presentation/google_timer_widget.dart';
import 'package:focus50/feature/jitsi/presentation/list_items_builder_1.dart';
import 'package:focus50/feature/jitsi/presentation/text_style.dart';
import 'package:focus50/feature/jitsi/presentation/todo_list_tile_widget.dart';
import 'package:focus50/feature/jitsi/provider/provider.dart';
import 'package:focus50/feature/peer_feedback/provider/provider.dart';
import 'package:focus50/feature/report_abuse/presentation/report_user_dialog.dart';
import 'package:focus50/feature/todo/data/todo_model.dart';
import 'package:focus50/resources/matching_methods.dart';
import 'package:focus50/services/firestore_database.dart';
import 'package:focus50/top_level_providers.dart';
import 'package:focus50/utils/amplitude_analytics.dart';
import 'package:get/get.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';

// * Provider 를 이용해 이번 미팅에서의 투두를 List 타입으로 관리할 수 있어야 한다.

class MeetingScreen extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  MeetingScreen({required this.reservation});

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends ConsumerState<MeetingScreen> {
  final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();
  late final ReservationModel reservation;
  late final FirestoreDatabase database;

  @override
  void initState() {
    super.initState();
    database = ref.read(databaseProvider);

    reservation = widget.reservation;
    ref.read(runningSessionIdProvider.notifier).state = reservation.id!;

    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // * reservation.roomId 는 무조건 not null 보장
      final UserModel? myAuth = await ref.read(userStreamProvider.future);
      _jitsiMeetMethods.createMeeting(
        room: "focusmaker-${reservation.id!}",
        myAuth: myAuth!,
      );
    });
    html.window.onUnload.listen((event) async {
      MatchingMethods(database: database).leaveRoom(reservation.id!);
      AmplitudeAnalytics().logForceExitInSession();
    });
  }

  @override
  void dispose() {
    MatchingMethods(database: database).leaveRoom(reservation.id!);
    JitsiMeet.removeAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double _rightSideWidth = 350;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: MyColors.blackSession,
        textTheme: TextTheme(
          bodyText1: MyTextStyle.CbS18W400,
        ),
      ),
      home: Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildJitsiMeet(),
                  _buildWatermark(),
                ],
              ),
            ),
            Container(
              width: _rightSideWidth,
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMission(),
                  SizedBox(width: 330, height: 330, child: _buildGoogleTimer()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildReportButton(),
                      SizedBox(
                        width: 6,
                      ),
                      _buildExitButton(),
                      SizedBox(
                        width: 6,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatermark() {
    return Positioned(
      child: Container(
        width: 158,
        height: 70,
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(32)),
          color: Colors.black,
        ),
        child: PointerInterceptor(
          intercepting: true,
          child: GestureDetector(
            onTap: _launchURL,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Focus',
                  style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  '50',
                  style: TextStyle(
                      fontSize: 26,
                      color: MyColors.purple300,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJitsiMeet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32)),
      ),
      child: Container(
        color: Colors.black,
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32)),
          child: Container(
            color: Colors.black,
            child: JitsiMeetConferencing(
              extraJS: [
                // extraJs setup example
                '<script>function echo(){console.log("echo!!!")};</script>',
                '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>',
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMission() {
    final _myEntireTodoStream = ref.watch(myEntireTodoStreamProvider);
    final _mySessionTodoStream =
        ref.watch(mySessionTodoStreamProvider(reservation.id!));
    final _entireTodoFocusState = ref.watch(entireTodoFocusStateProvider);
    const double _missionContentWidth = 280;
    TextEditingController _todoAddTextFieldController = TextEditingController();

    const TextStyle borderBlack = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: blackSession,
    );
    const TextStyle normalWhite = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    );
    const TextStyle normalBlack = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    );

    return Container(
      height: 370,
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: _missionContentWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: (_missionContentWidth - 10) / 2,
                  height: 40,
                  margin: EdgeInsets.only(bottom: 5),
                  child: TextButton(
                      onPressed: _toggleEntireTodoButton,
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(
                                color: _entireTodoFocusState
                                    ? blackSession
                                    : Colors.transparent),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            _entireTodoFocusState
                                ? Colors.white
                                : blackSession),
                      ),
                      child: Text(
                        '50분 할 일',
                        style:
                            _entireTodoFocusState ? normalBlack : normalWhite,
                      )),
                ),
                Container(
                  width: (_missionContentWidth - 10) / 2,
                  height: 40,
                  margin: EdgeInsets.only(bottom: 5),
                  child: TextButton(
                    onPressed: _toggleEntireTodoButton,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(
                              color: _entireTodoFocusState
                                  ? Colors.transparent
                                  : blackSession),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          _entireTodoFocusState ? blackSession : Colors.white),
                    ),
                    child: Text(
                      '전체 할 일',
                      style: _entireTodoFocusState ? normalWhite : normalBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _entireTodoFocusState
              ? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  width: _missionContentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            // margin: EdgeInsets.only(top: 9),
                            width: _missionContentWidth,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              autofocus: false,
                              controller: _todoAddTextFieldController,
                              textInputAction: TextInputAction.go,
                              onSubmitted: (value) {
                                DateTime now = DateTime.now();
                                _onAdd(value);
                                _todoAddTextFieldController.clear();
                              },
                              decoration: InputDecoration(
                                hintText: '할 일 추가하기',
                                fillColor: Colors.white,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 2.0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 2.0),
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   width: 30,
                          //   height: 30,
                          //   child: TextButton(
                          //     onPressed: () {},
                          //     style: ButtonStyle(
                          //       shape: MaterialStateProperty.all<
                          //           RoundedRectangleBorder>(
                          //         RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(4.0),
                          //           side: BorderSide(
                          //               color: Colors.black, width: 1.5),
                          //         ),
                          //       ),
                          //       backgroundColor:
                          //           MaterialStateProperty.all<Color>(
                          //               Colors.white),
                          //     ),
                          //     child: Center(
                          //       child: Icon(
                          //         Icons.add,
                          //         color: Colors.black,
                          //         size: 16,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      // Text(
                      //   '체크하거나 추가하시고, \'50분 동안 할 일 선택\'을 다시 눌러주세요',
                      //   style: TextStyle(color: MyColors.blackSession),
                      // ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
          Container(
            margin: _entireTodoFocusState
                ? EdgeInsets.all(0)
                : EdgeInsets.only(top: 8),
            // width: _missionContentWidth,
            height: _entireTodoFocusState ? 222 : 270,
            child: ListItemsBuilder1<TodoModel>(
              data: (_entireTodoFocusState)
                  ? _myEntireTodoStream
                  : _mySessionTodoStream,
              itemBuilder: (context, model) => TodoListTile(
                  model: model,
                  reservationId: reservation.id,
                  contentWidth: _missionContentWidth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleTimer() {
    return Container(
      child: Center(
        child: GoogleTimer(
          duration: Times.min50,
          startTime: reservation.startTime!,
          // duration: Duration(seconds: 10),
          // startTime: DateTime.now(),
        ),
      ),
    );
  }

  Widget _buildExitButton() {
    return Container(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 50,
        height: 50,
        child: TextButton(
          onPressed: () {
            Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR());
            AmplitudeAnalytics().logClickExitButtonDuringSession();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white)),
            ),
          ),
          child: Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<dynamic> reportUserAlertdialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReportUserDialog(reservation: reservation);
        // return AlertDialog(content: Text('asdas'));
      },
    );
  }

  Widget _buildReportButton() {
    return Container(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 50,
        height: 50,
        child: TextButton(
          onPressed: () {
            reportUserAlertdialog(context);
            AmplitudeAnalytics().logClickReportButton();
          },
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(MyColors.reportIconColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Color.fromARGB(255, 254, 227, 227))),
            ),
          ),
          child: Icon(
            Icons.notifications,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _launchURL() async {
    const url = 'https://focus50.day';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      AmplitudeAnalytics().logClickLogoInSession();
    } else {
      throw 'Could not launch $url';
    }
  }

  void _toggleEntireTodoButton() {
    if (ref.read(entireTodoFocusStateProvider.notifier).state == true) {
      ref.read(entireTodoFocusStateProvider.notifier).state = false;
    } else {
      ref.read(entireTodoFocusStateProvider.notifier).state = true;
    }
    AmplitudeAnalytics().logToggleTodoList();
  }

  void _onAdd(text) async {
    database.setTodo(TodoModel.newTodo(database.uid, text));
    AmplitudeAnalytics().logMakeTodoInSession();
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/jitsi/consts/times.dart';
import 'package:focus42/feature/jitsi/jitsi_meet_methods.dart';
import 'package:focus42/feature/jitsi/presentation/google_timer_widget.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/feature/jitsi/provider/my_auth.dart';
import 'package:focus42/feature/jitsi/provider/provider.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/resources/matching_methods.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:get/get.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';

// * Provider 를 이용해 이번 미팅에서의 투두를 List 타입으로 관리할 수 있어야 한다.

class MobileMeetingScreen extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  MobileMeetingScreen({required this.reservation});

  @override
  _MobileMeetingScreenState createState() => _MobileMeetingScreenState();
}

class _MobileMeetingScreenState extends ConsumerState<MobileMeetingScreen> {
  final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();
  late final ReservationModel reservation;
  late final MyAuth myAuth;
  late final database;

  @override
  void initState() {
    super.initState();
    database = ref.read(databaseProvider);

    reservation = widget.reservation;

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

      AnalyticsMethod().mobileLogForceExit();
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
    final double _screenWidth = MediaQuery.of(context).size.width;
    final double _screenHeight = MediaQuery.of(context).size.height;
    final double _missionHeight = 60;
    const double _hPadding = 16.0;
    const double _vPadding = 5.0;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyText1: MyTextStyle.CbS18W400,
        ),
      ),
      home: Scaffold(
        body: Container(
          width: _screenWidth * 1,
          height: _screenHeight * 1,
          color: Colors.black,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                child: Container(
                  width: _screenWidth * 1,
                  height: _missionHeight,
                  // padding: const EdgeInsets.symmetric(
                  //   horizontal: _hPadding,
                  //   vertical: _vPadding,
                  // ),
                  child: _buildTop(_screenWidth, _missionHeight),
                ),
              ),
              Positioned(
                top: _missionHeight,
                child: Container(
                  width: _screenWidth * 1,
                  height: _screenHeight * 1 - _missionHeight,
                  // padding: const EdgeInsets.symmetric(
                  //   horizontal: _hPadding,
                  //   vertical: _vPadding,
                  // ),
                  child: Stack(
                    children: [
                      _buildJitsiMeet(),
                      _buildWatermark(),
                      // _buildLeaveButton(_vPadding, _missionHeight),
                      _buildGoogleTimer(_screenWidth, _screenHeight),
                      // _buildEntireTodoList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatermark() {
    return Positioned(
      top: 0,
      child: Container(
        width: 150,
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

  void _launchURL() async {
    const url = 'https://focus50.day';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      AnalyticsMethod().mobileLogPressSessionLogo();
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildTop(screenWidth, _missionHeight) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
          ),
          IconButton(
            alignment: Alignment.center,
            onPressed: _toggleTimer,
            icon: Icon(
              Icons.timer,
              color: Colors.white,
              size: 30,
            ),
          ),
          _buildExitButton(),
        ],
      ),
    );
  }

  Widget _buildExitButton() {
    return Container(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 40,
        height: 40,
        child: TextButton(
          onPressed: () {
            Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR());
            AnalyticsMethod().mobileLogPressExitButton();
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

  Widget _buildLeaveButton(_vPadding, _missionHeight) {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        width: 130,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 80,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.red,
            ),
            child: TextButton(
              onPressed: () {},
              child: Text(
                '나가기',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleTimer(_screenWidth, _screenHeight) {
    final _timerState = ref.watch(timerToggleStateProvider);
    return Offstage(
      offstage: _timerState == false,
      child: Container(
        width: _screenWidth * 1,
        height: _screenHeight * 1,
        color: MyColors.blackSession.withOpacity(0.7),
        child: Center(
          child: SizedBox(
            width: _screenHeight * 0.7,
            height: _screenHeight * 0.7,
            child: GoogleTimer(
              duration: Times.min50,
              startTime: reservation.startTime!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntireTodoList() {
    final myEntireTodoStream = ref.watch(myEntireTodoStreamProvider);
    final _entireTodoTogglestate = ref.watch(entireTodoFocusStateProvider);
    return Positioned(
      top: 0,
      right: 40,
      child: PointerInterceptor(
        intercepting: true,
        // intercepting: _entireTodoTogglestate == true,
        // child: Container(
        //   width: 300,
        //   height: 400,
        //   child: ListItemsBuilder<TodoModel>(
        //     data: myEntireTodoStream,
        //     itemBuilder: (context, model) => TodoListTile(model: model),
        //   ),
        // ),
        child: Offstage(
          offstage: _entireTodoTogglestate == false,
          child: Container(
            width: 300,
            height: 400,
          ),
        ),
      ),
      // child: Offstage(
      //   offstage: _entireTodoTogglestate == false,
      //   child: PointerInterceptor(
      //     intercepting: true,
      //     // intercepting: _entireTodoTogglestate == true,
      //     child: Container(
      //       width: 300,
      //       height: 400,
      //       child: ListItemsBuilder<TodoModel>(
      //         data: myEntireTodoStream,
      //         itemBuilder: (context, model) => TodoListTile(model: model),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  void _toggleTimer() {
    if (ref.read(timerToggleStateProvider.notifier).state == true) {
      ref.read(timerToggleStateProvider.notifier).state = false;
    } else {
      ref.read(timerToggleStateProvider.notifier).state = true;
    }
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

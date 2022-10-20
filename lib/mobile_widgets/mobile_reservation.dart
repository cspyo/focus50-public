// import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/auth/presentation/login_dialog.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/widgets/reservation.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

import '../consts/colors.dart';

class MobileReservation extends ConsumerStatefulWidget {
  MobileReservation({Key? key}) : super(key: key);
  @override
  _MobileReservationState createState() => _MobileReservationState();
}

class _MobileReservationState extends ConsumerState<MobileReservation> {
  String userAgent = html.window.navigator.userAgent.toString().toLowerCase();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showLoginDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return LoginDialog();
      },
    );
  }

  void enterReservation(ReservationModel nextReservation) {
    final database = ref.read(databaseProvider);
    final uid = database.uid;
    database.updateReservationUserInfo(
        nextReservation.id!, uid, "enterDTTM", DateTime.now());
    AnalyticsMethod().mobileLogEnterSession();
    Get.rootDelegate.toNamed(Routes.MEET, arguments: nextReservation);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final authState = ref.watch(authStateChangesProvider);
    final nextReservationStream = ref.watch(myNextReservationStreamProvider);

    return Container(
      height: 90,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: _buildBody(context, authState, nextReservationStream, screenWidth),
    ); //모바일
  }

  Widget _buildBody(
      BuildContext context,
      AsyncValue user,
      AsyncValue<List<ReservationModel?>> nextReservationStream,
      double screenWidth) {
    if (user.asData?.value == null) {
      return _buildNeedLogin(context);
    } else {
      return nextReservationStream.when(
          data: (nextReservation) {
            if (nextReservation.isEmpty) {
              return _buildNoReservation(context);
            } else
              return _buildReservation(
                  context, screenWidth, nextReservation.first!);
          },
          error: (_, __) => Text("Something went wrong"),
          loading: () => _buildLoading(context));
    }
  }

  Widget _buildLoading(
    BuildContext context,
  ) {
    return Text(
      '로딩중입니다...',
      style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 24, 24, 24)),
    );
  }

  Widget _buildNeedLogin(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 250,
      child: TextButton(
        onPressed: () {
          _showLoginDialog();
        },
        child: Text('로그인이 필요합니다',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 24, 24, 24))),
      ),
    );
  }

  Widget _buildNoReservation(BuildContext context) {
    return Container(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Text('예약이 없습니다',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 24, 24, 24))),
      Text('캘린더에서 원하는 시간대를 골라 클릭해보세요!',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(105, 105, 105, 100))),
    ]));
  }

  Widget _buildReservation(BuildContext context, double screenWidth,
      ReservationModel nextReservation) {
    // 10분 전에 입장 가능하게 만들어주는 타이머
    bool canEnter = false;
    if (nextReservation.startTime!
            .difference(DateTime.now())
            .compareTo(Duration(minutes: 10)) <=
        0) {
      canEnter = true;
    } else {
      canEnter = false;
      Timer(
          nextReservation.startTime!.difference(DateTime.now()) -
              Duration(minutes: 10),
          () => setState(() {
                canEnter = true;
              }));
    }
    return Container(
      width: screenWidth - 40,
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimerCountdown(
                format: CountDownTimerFormat.hoursMinutesSeconds,
                endTime:
                    Timestamp.fromDate(nextReservation.startTime!).toDate(),
                enableDescriptions: false,
                timeTextStyle: TextStyle(
                  height: 1.0,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                colonsTextStyle: TextStyle(
                  height: 1.0,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                spacerWidth: 0,
              ),
              Text(' 남았습니다',
                  // textAlign: TextAlign.center,
                  style: const TextStyle(
                    height: 1.0,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          Container(
            width: screenWidth - 160,
            height: 36,
            child: canEnter
                ? TextButton(
                    onPressed: () {
                      enterReservation(nextReservation);
                      // if (userAgent.contains('android')) {
                      //   enterReservation(nextReservation);
                      // } else {
                      //   showSnackBar(
                      //     '세션 입장은 안드로이드 및 PC 브라우저만 지원하고 있습니다 : )',
                      //     context,
                      //   );
                      // }
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Colors.transparent))),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(purple300),
                    ),
                    child: Text(
                      '입장하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: BorderSide(color: Colors.transparent))),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black38),
                    ),
                    child: Text(
                      '입장하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

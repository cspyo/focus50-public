import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/auth/presentation/login_dialog.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final myNextReservationStreamProvider =
    StreamProvider.autoDispose<List<ReservationModel?>>(
  (ref) {
    final database = ref.watch(databaseProvider);
    return database.myNextReservationStream();
  },
);

class Reservation extends ConsumerStatefulWidget {
  @override
  ReservationState createState() => ReservationState();
}

class ReservationState extends ConsumerState<Reservation> {
  DateTime now = new DateTime.now();

  bool partnerIsEmpty = true;
  String? partnerUid = '';
  String? partnerName = null;

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
    AnalyticsMethod().logEnterSession();
    Get.rootDelegate.toNamed(Routes.MEET, arguments: nextReservation);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletSize = screenWidth < 1200 ? true : false;

    final authState = ref.watch(authStateChangesProvider);
    final nextReservationStream = ref.watch(myNextReservationStreamProvider);

    if (isTabletSize) {
      // 태블릿 사이즈일 때
      if (authState.asData?.value == null) {
        return _tabletBuildNeedLogin(context, ref);
      } else {
        return nextReservationStream.when(
            data: (nextReservation) {
              if (nextReservation.isEmpty) {
                return _tabletBuildNoReservation(context, ref);
              } else
                return _tabletBuildReservation(
                    context, ref, nextReservation.first!);
            },
            error: (_, __) => Text("Something went wrong"),
            loading: () => _tabletBuildLoading(context, ref));
      }
    } else {
      // 데스크탑 사이즈일 때
      if (authState.asData?.value == null) {
        return _buildNeedLogin(context, ref);
      } else {
        return nextReservationStream.when(
            data: (nextReservation) {
              if (nextReservation.isEmpty) {
                return _buildNoReservation(context, ref);
              } else
                return _buildReservation(context, ref, nextReservation.first!);
            },
            error: (_, __) => Text("Something went wrong"),
            loading: () => _buildLoading(context, ref));
      }
    }
  }

  Widget _buildReservation(
      BuildContext context, WidgetRef ref, ReservationModel nextReservation) {
    final reservationTime =
        DateFormat('HH:mm').format(nextReservation.startTime!);

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

    return Stack(children: [
      Container(
          margin: EdgeInsets.only(top: 32),
          padding: EdgeInsets.all(15),
          width: 380,
          height: 292, //355
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1.5, color: border100),
              borderRadius: BorderRadius.all(Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(0, 6),
                ),
              ]),
          child: Container(
              margin: EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TimerCountdown(
                        format: CountDownTimerFormat.hoursMinutesSeconds,
                        endTime: Timestamp.fromDate(nextReservation.startTime!)
                            .toDate(),
                        enableDescriptions: false,
                        timeTextStyle: TextStyle(
                          height: 1.0,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                        colonsTextStyle: TextStyle(
                          height: 1.0,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                        spacerWidth: 0,
                      ),
                      Text(' 남았습니다',
                          // textAlign: TextAlign.center,
                          style: const TextStyle(
                            height: 1.0,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  !partnerIsEmpty
                      ? Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$partnerName',
                                  style: const TextStyle(
                                    height: 1.0,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: purple300,
                                  )),
                              Text(
                                '님과의 세션이 $reservationTime에 예약되었어요!',
                                style: TextStyle(
                                  height: 1.0,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: black100,
                                ),
                              )
                            ],
                          ))
                      : Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$reservationTime',
                                  style: const TextStyle(
                                    height: 1.0,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: purple300,
                                  )),
                              Text(
                                '에 예약되었어요!',
                                style: TextStyle(
                                  height: 1.0,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: black100,
                                ),
                              )
                            ],
                          )),
                  Image.asset(
                    'assets/images/meet.png',
                    height: 200,
                  ),
                ],
              ))),
      Positioned(
          bottom: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  width: 119,
                  height: 54,
                  child: canEnter
                      ? ElevatedButton(
                          onPressed: () {
                            enterReservation(nextReservation);
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    side:
                                        BorderSide(color: Colors.transparent))),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(purple300),
                          ),
                          child: Text('입장하기',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              )))
                      : TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    side:
                                        BorderSide(color: Colors.transparent))),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.black38),
                          ),
                          child: Text('입장하기',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              )))),
            ],
          ))
    ]);
  }

  Widget _buildLoading(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      padding: EdgeInsets.all(15),
      width: 380,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1.5, color: border100),
          borderRadius: BorderRadius.all(Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 6),
            ),
          ]),
      child: Text(
        '로딩중입니다...',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 24, 24, 24)),
      ),
    );
  }

  Widget _buildNeedLogin(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      padding: EdgeInsets.all(15),
      width: 380,
      height: 120,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1.5, color: border100),
          borderRadius: BorderRadius.all(Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 6),
            ),
          ]),
      child: Center(
        child: SizedBox(
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
        ),
      ),
    );
  }

  Widget _buildNoReservation(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      padding: EdgeInsets.all(15),
      width: 380,
      height: 120,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1.5, color: border100),
          borderRadius: BorderRadius.all(Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 6),
            ),
          ]),
      child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
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
          ])),
    );
  }

  ///////// 태블릿 /////////////////
  Widget _tabletBuildLoading(BuildContext context, WidgetRef ref) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(width: 1.5, color: border100))),
        child: Text(
          '로딩중입니다...',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 24, 24, 24)),
        ));
  }

  Widget _tabletBuildReservation(
      BuildContext context, WidgetRef ref, ReservationModel nextReservation) {
    final reservationTime =
        DateFormat('HH:mm').format(nextReservation.startTime!);

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
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(width: 1.5, color: border100))),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 119,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TimerCountdown(
                        format: CountDownTimerFormat.hoursMinutesSeconds,
                        endTime: Timestamp.fromDate(nextReservation.startTime!)
                            .toDate(),
                        enableDescriptions: false,
                        timeTextStyle: TextStyle(
                          height: 1.0,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                        colonsTextStyle: TextStyle(
                          height: 1.0,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                        spacerWidth: 0,
                      ),
                      Text(' 남았습니다',
                          // textAlign: TextAlign.center,
                          style: const TextStyle(
                            height: 1.0,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  partnerName != null
                      ? Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$partnerName',
                                  style: const TextStyle(
                                    height: 1.0,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: purple300,
                                  )),
                              Text(
                                '님과의 세션이 $reservationTime시에 예약되었어요!',
                                style: TextStyle(
                                  height: 1.0,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: black100,
                                ),
                              )
                            ],
                          ))
                      : Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$reservationTime',
                                  style: const TextStyle(
                                    height: 1.0,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: purple300,
                                  )),
                              Text(
                                '시에 예약되었어요!',
                                style: TextStyle(
                                  height: 1.0,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: black100,
                                ),
                              )
                            ],
                          ),
                        ),
                ],
              ),
              Container(
                  width: 119,
                  height: 54,
                  child: canEnter
                      ? ElevatedButton(
                          onPressed: () {
                            enterReservation(nextReservation);
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    side:
                                        BorderSide(color: Colors.transparent))),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(purple300),
                          ),
                          child: Text('입장하기',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              )))
                      : TextButton(
                          onPressed: () {
                            // enterReservation();
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    side:
                                        BorderSide(color: Colors.transparent))),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.black38),
                          ),
                          child: Text('입장하기',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              )))),
            ],
          ),
        ));
  }

  Widget _tabletBuildNoReservation(BuildContext context, WidgetRef ref) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(width: 1.5, color: border100))),
        child: Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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
            ])));
  }

  Widget _tabletBuildNeedLogin(BuildContext context, WidgetRef ref) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(width: 1.5, color: border100))),
      child: Container(
        child: SizedBox(
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
        ),
      ),
    );
  }
}

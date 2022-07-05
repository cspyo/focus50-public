import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class CountDownTimer extends StatefulWidget {
  final Duration duration;
  final DateTime startTime;
  const CountDownTimer(
      {Key? key, required this.duration, required this.startTime})
      : super(key: key);
  // const CountDownTimer({Key? key, required this.duration}) : super(key: key);
  @override
  _CountDownTimerState createState() =>
      _CountDownTimerState(duration: duration, startTime: startTime);
  // _CountDownTimerState createState() =>
  //     _CountDownTimerState(duration: duration);
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  _CountDownTimerState({required this.duration, required this.startTime})
      : super();
  // _CountDownTimerState({required this.duration}) : super();
  late AnimationController controller;
  final Duration duration;
  final DateTime startTime;
  Timer? _timer;

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void startTimer() {
    if (!controller.isAnimating) {
      controller.reverse(
          from: controller.value == 0.0 ? 1.0 : controller.value);
    }
  }

  void stopTimer() {
    if (controller.isAnimating) {
      controller.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    // TODO: duration 무조건 50분 아니고 만약에 시작 시간 이후에 들어오면 50분 보다 적음
    controller = AnimationController(
      vsync: this,
      duration: duration,
    );
    // ..addStatusListener((status) { })
    // TODO: timer 끝났을 때 event 걸기

    Duration diff = DateTime.now().difference(startTime);
    // _timer = Timer(diff, startTimer);
    // TODO: timer duration argument firebase 데이터 포맷 맞추기
    _timer = Timer(const Duration(seconds: 15), startTimer);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: themedata 색상 설정
    ThemeData themeData = Theme.of(context);
    return Scaffold(
        backgroundColor: Colors.white10,
        body: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: FractionalOffset.center,
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: CustomPaint(
                                        painter: CustomTimerPainter(
                                            animation: controller,
                                            backgroundColor: Colors.red,
                                            color: themeData.canvasColor)),
                                  ),
                                  Align(
                                    alignment: FractionalOffset.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "남은 시간",
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: themeData.primaryColor),
                                        ),
                                        Text(
                                          timerString,
                                          style: TextStyle(
                                              fontSize: 80.0,
                                              color: themeData.primaryColor),
                                        ),
                                        // AnimatedBuilder(
                                        //     animation: controller,
                                        //     builder: (context, child) {
                                        //       return FloatingActionButton
                                        //           .extended(
                                        //               onPressed: () {
                                        //                 if (controller
                                        //                     .isAnimating) {
                                        //                   controller.stop();
                                        //                 } else {
                                        //                   controller.reverse(
                                        //                       from: controller
                                        //                                   .value ==
                                        //                               0.0
                                        //                           ? 1.0
                                        //                           : controller
                                        //                               .value);
                                        //                 }
                                        //               },
                                        //               icon: Icon(controller
                                        //                       .isAnimating
                                        //                   ? Icons.pause
                                        //                   : Icons.play_arrow),
                                        //               label: Text(
                                        //                   controller.isAnimating
                                        //                       ? "Pause"
                                        //                       : "Play"));
                                        //     }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }));
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 30.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint
      ..color = color
      ..strokeWidth = paint.strokeWidth + 2.0;

    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}

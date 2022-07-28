import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:focus42/consts/colors.dart';
import 'package:video_player/video_player.dart';

class CountDownTimer extends StatefulWidget {
  final Duration duration;
  final DateTime startTime;
  const CountDownTimer(
      {Key? key, required this.duration, required this.startTime})
      : super(key: key);
  @override
  _CountDownTimerState createState() =>
      _CountDownTimerState(duration: duration, startTime: startTime);
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  _CountDownTimerState({required this.duration, required this.startTime})
      : super();
  late AnimationController controller;
  final Duration duration;
  final DateTime startTime;
  Timer? _timer;

  late VideoPlayerController _startSoundController;
  late VideoPlayerController _finishSoundController;

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void startTimer() {
    _startSoundController.play();

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

    _startSoundController = VideoPlayerController.network(
      'https://www.mboxdrive.com/ring.mp3',
    );
    _finishSoundController = VideoPlayerController.network(
      'https://www.mboxdrive.com/ring.mp3',
    );
    _startSoundController.initialize();
    _finishSoundController.initialize();

    controller = AnimationController(
      vsync: this,
      // duration 무조건 50분 아니고 만약에 시작 시간 이후에 들어오면 50분 보다 적음
      duration: (DateTime.now().isBefore(startTime))
          ? duration
          : duration - DateTime.now().difference(startTime),
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _finishSoundController.play();
      }
    });
    _timer = Timer(startTime.difference(DateTime.now()), startTimer);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _startSoundController.pause();
    _startSoundController.dispose();
    _finishSoundController.pause();
    _finishSoundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: themedata 색상 설정
    ThemeData themeData = Theme.of(context);
    return Scaffold(
        backgroundColor: blackSession,
        body: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Stack(
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
                                        children: (controller.isAnimating)
                                            ? <Widget>[
                                                Wrap(
                                                  children: [
                                                    Text(
                                                      "남은 시간",
                                                      style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      timerString,
                                                      style: TextStyle(
                                                        fontSize: 80.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ]
                                            : [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Wrap(
                                                    children: [
                                                      Text('시작까지 ',
                                                          style:
                                                              const TextStyle(
                                                            height: 1.0,
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.white,
                                                          )),
                                                      TimerCountdown(
                                                        format:
                                                            CountDownTimerFormat
                                                                .minutesSeconds,
                                                        endTime: startTime,
                                                        enableDescriptions:
                                                            false,
                                                        timeTextStyle:
                                                            TextStyle(
                                                          height: 1.0,
                                                          fontSize: 26,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                        colonsTextStyle:
                                                            TextStyle(
                                                          height: 1.0,
                                                          fontSize: 26,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                        spacerWidth: 0,
                                                      ),
                                                      Text(' 남았습니다',
                                                          style:
                                                              const TextStyle(
                                                            height: 1.0,
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.white,
                                                          )),
                                                    ],
                                                  ),
                                                )
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
                ),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:focus42/feature/jitsi/presentation/custom_timer_painter.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/feature/peer_feedback/presentation/peer_feedback_dialog.dart';
import 'package:video_player/video_player.dart';

Future<dynamic> peerFeedbackPopup(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return PeerFeedbackDialog();
    },
  );
}

const TextStyle style1 = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    decoration: TextDecoration.none);

const TextStyle style1Small = TextStyle(
    fontSize: 8.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    decoration: TextDecoration.none);

const TextStyle style2 = TextStyle(
    fontSize: 60.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    decoration: TextDecoration.none);

const TextStyle style2Small = TextStyle(
    fontSize: 40.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    decoration: TextDecoration.none);

class GoogleTimer extends StatefulWidget {
  final Duration duration;
  final DateTime startTime;
  const GoogleTimer({required this.duration, required this.startTime});

  @override
  _GoogleTimerState createState() =>
      _GoogleTimerState(duration: duration, startTime: startTime);
}

class _GoogleTimerState extends State<GoogleTimer>
    with SingleTickerProviderStateMixin {
  _GoogleTimerState({required this.duration, required this.startTime})
      : super();

  final Duration duration;
  final DateTime startTime;
  late final AnimationController _animationController;
  late final Timer _timerWaitingStartTime;

  late VideoPlayerController _startSoundController;
  late VideoPlayerController _finishSoundController;

  bool _isTimerStarted = false;
  bool _isStartSoundCompleted = false;
  bool _isFinishSoundCompleted = false;

  String startSound = "assets/sound/ring.mp3";
  String finishSound = "assets/sound/ring.mp3";

  void _initSoundController() {
    // sound controller initialize
    _startSoundController = VideoPlayerController.asset(startSound);
    _startSoundController.initialize();
    _startSoundController.addListener(_startSoundDispose);

    _finishSoundController = VideoPlayerController.asset(finishSound);
    _finishSoundController.initialize();
    _finishSoundController.addListener(_finishSoundDispose);
  }

  @override
  void initState() {
    super.initState();

    // _initSoundController();

    // animation controller initialize - animation for google timer
    // Todo: animation dismiss 가 종료 소리 trigger 라 화면에 떠있어야 함
    _animationController = AnimationController(
      vsync: this,
      duration: duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          peerFeedbackPopup(context);
          // _playFinishSound();
        }
      });

    // timer for waiting start time of google timer initialize
    _timerWaitingStartTime =
        Timer(startTime.difference(DateTime.now()), _startTimer);
  }

  @override
  void dispose() {
    _timerWaitingStartTime.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            child: Align(
              alignment: FractionalOffset.center,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: CustomPaint(
                          painter: CustomTimerPainter(
                              animation: _animationController,
                              backgroundColor: Colors.red,
                              color: themeData.canvasColor)),
                    ),
                    Align(
                      alignment: FractionalOffset.center,
                      child: (_animationController.isAnimating)
                          ? _buildLeftTimeToFinish()
                          : _buildLeftTimeToStart(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftTimeToFinish() {
    final _timerWidth = MediaQuery.of(context).size.width;
    return Wrap(
      children: [
        Text(
          "남은 시간",
          style: (_timerWidth > 1000) ? style1 : style1Small,
        ),
        Text(
          _getLeftTimerTime(),
          style: (_timerWidth > 1000) ? style2 : style2Small,
        ),
      ],
    );
  }

  Widget _buildLeftTimeToStart() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Wrap(
        children: [
          Text(
            '시작까지 ',
            style: MyTextStyle.CwS24W500H1,
          ),
          TimerCountdown(
            format: CountDownTimerFormat.minutesSeconds,
            endTime: startTime,
            enableDescriptions: false,
            timeTextStyle: MyTextStyle.CwS26W500H1,
            colonsTextStyle: MyTextStyle.CwS26W500H1,
            spacerWidth: 0,
          ),
          Text(
            ' 남았습니다',
            style: MyTextStyle.CwS24W500H1,
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    // _playStartSound();

    if (!_animationController.isAnimating) {
      _animationController.reverse(
          from: _animationController.value == 0.0
              ? 1.0
              : _animationController.value);
    }

    _animationController.addListener(_makeTimerAccurate);
  }

  void _stopTimer() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  void _makeTimerAccurate() {
    if (_animationController.isAnimating && !_isTimerStarted) {
      double remaining_value =
          (duration - DateTime.now().difference(startTime)).inSeconds /
              duration.inSeconds;
      _animationController.reverse(from: remaining_value);
      _animationController.removeListener(_makeTimerAccurate);
      _isTimerStarted = true;
    }
  }

  void _playStartSound() {
    _startSoundController.play();
  }

  void _playFinishSound() {
    _finishSoundController.play();
  }

  void _startSoundDispose() {
    if (!_startSoundController.value.isPlaying &&
        _startSoundController.value.position > Duration.zero &&
        _startSoundController.value.position.inSeconds >=
            _startSoundController.value.duration.inSeconds &&
        !_isStartSoundCompleted) {
      // 세션 시작 알림음이 완료된 후 콜백하는 함수
      _startSoundController.removeListener(_startSoundDispose);
      _startSoundController.dispose();
      _isStartSoundCompleted = true;
    }
  }

  void _finishSoundDispose() {
    if (!_finishSoundController.value.isPlaying &&
        _finishSoundController.value.position > Duration.zero &&
        _finishSoundController.value.position.inSeconds >=
            _finishSoundController.value.duration.inSeconds &&
        !_isFinishSoundCompleted) {
      // 세션 종료 알림음이 완료된 후 콜백하는 함수
      _finishSoundController.removeListener(_finishSoundDispose);
      _finishSoundController.dispose();
      _isFinishSoundCompleted = true;
    }
  }

  String _getLeftTimerTime() {
    Duration duration =
        _animationController.duration! * _animationController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  // Duration _getLeftDuration() {
  //   Duration _duration = (DateTime.now().isBefore(startTime))
  //       ? duration
  //       : duration - DateTime.now().difference(startTime);
  //   return _duration;
  // }
}

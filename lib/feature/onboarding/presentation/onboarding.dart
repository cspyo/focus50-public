import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/feature/auth/data/user_model.dart';
import 'package:focus50/feature/auth/data/user_private_model.dart';
import 'package:focus50/feature/auth/data/user_public_model.dart';
import 'package:focus50/feature/auth/view_model/auth_view_model.dart';
import 'package:focus50/feature/jitsi/presentation/text_style.dart';
import 'package:focus50/top_level_providers.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Onboarding {
  static GlobalKey calendarButton = GlobalKey();
  static GlobalKey reservationButton = GlobalKey();
  static late TutorialCoachMark tutorialCoachMark;

  static Future<dynamic>? popupOnboardingStart(
      WidgetRef ref, BuildContext context) async {
    await Future.delayed(Duration(microseconds: 1));
    final database = ref.watch(databaseProvider);
    final user = await database.getUserPublic();
    bool isOnboarded = user.isOnboarded ?? false;
    final authViewModel = ref.read(authViewModelProvider);
    String username = user.nickname ?? "회원";

    if (isOnboarded) {
      return null;
    } else {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          double _screenWidth = MediaQuery.of(context).size.width;
          bool isMobile = _screenWidth < 500 ? true : false;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset('assets/images/fogong_character.png'),
                ),
                SizedBox(
                  height: 16,
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      '안녕하세요 ${username}님!',
                      textStyle: isMobile
                          ? MyTextStyle.CbS18W400
                          : MyTextStyle.CbS20W400,
                      textAlign: TextAlign.center,
                      speed: const Duration(milliseconds: 70),
                    ),
                    TypewriterAnimatedText(
                      "손님이 오셨다고 해서 \n마중 나온 '포공이'입니다",
                      textStyle: isMobile
                          ? MyTextStyle.CbS18W400
                          : MyTextStyle.CbS20W400,
                      textAlign: TextAlign.center,
                      speed: const Duration(milliseconds: 50),
                    ),
                    TypewriterAnimatedText(
                      '세상에서 가장 집중이 잘되는 공간, \nFocus50에 오신 걸 환영합니다.',
                      textStyle: isMobile
                          ? MyTextStyle.CbS18W400
                          : MyTextStyle.CbS20W400,
                      textAlign: TextAlign.center,
                      speed: const Duration(milliseconds: 50),
                    ),
                    TypewriterAnimatedText(
                      '화면에서 직접 설명드릴게요!\n따라오세요!',
                      textStyle: isMobile
                          ? MyTextStyle.CbS18W400
                          : MyTextStyle.CbS20W400,
                      textAlign: TextAlign.center,
                      speed: const Duration(milliseconds: 50),
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 300),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 50,
                  width: 140,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (_screenWidth < 500) {
                        mobileCreateTutorialBeforeReservation();
                      } else if (_screenWidth >= 500 && _screenWidth < 1200) {
                        tabletCreateTutorialBeforeReservation();
                      } else {
                        createTutorialBeforeReservation(context);
                      }
                      showTutorial(context);
                    },
                    child: Text(
                      '다음',
                      style: MyTextStyle.CwS16W600,
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(MyColors.purple300),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
    }
  }

  static void showTutorial(context) {
    tutorialCoachMark.show(context: context);
  }

  static void createTutorialBeforeReservation(context) {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargetsBeforeReservation(context),
      colorShadow: MyColors.purple200,
      textSkip: "그만 보기",
      paddingFocus: 10,
      opacityShadow: 0.9,
    );
  }

  static void createTutorialAfterReservation(ref) {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargetsAfterReservation(ref),
      colorShadow: MyColors.purple200,
      textSkip: "그만 보기",
      paddingFocus: 10,
      opacityShadow: 0.9,
    );
  }

  static List<TargetFocus> _createTargetsBeforeReservation(context) {
    List<TargetFocus> targets = [];
    double height = MediaQuery.of(context).size.height;

    targets.add(
      TargetFocus(
        identify: "calendarButton",
        keyTarget: calendarButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(left: 20),
            builder: (context, controller) {
              return Container(
                width: 200,
                height: height,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: [
                        Text("나 자신과의 약속보다 ", style: MyTextStyle.CwS20W400),
                        Text("타인과의 약속은", style: MyTextStyle.CwS22W600),
                      ],
                    ),
                    Text("지킬 확률이 87% 더 높아요!", style: MyTextStyle.CwS20W400),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text("캘린더에 집중할 시간을 ", style: MyTextStyle.CwS20W400),
                        Text("예약", style: MyTextStyle.CwS22W600),
                        Text("해 볼까요?", style: MyTextStyle.CwS20W400),
                        Icon(
                          Icons.arrow_right_alt_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/calendar_screen_reserve.gif',
                        width: 320,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("원하는 시간에 클릭하고", style: MyTextStyle.CwS20W400),
                    Row(
                      children: [
                        Text("'예약'", style: MyTextStyle.CwS22W600),
                        Text(" 버튼을 눌러봐요!", style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("예약하시고 나서, 전 다시 찾아올게요!", style: MyTextStyle.CwS20W400),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  static List<TargetFocus> _createTargetsAfterReservation(ref) {
    List<TargetFocus> targets = [];
    updateIsOnboardedTrue(ref);
    targets.add(
      TargetFocus(
        identify: "calendarButton",
        keyTarget: calendarButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(left: 30),
            builder: (context, controller) {
              return Container(
                width: 200,
                height: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("훌륭해요!", style: MyTextStyle.CwS20W400),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text("이제 평범한 ", style: MyTextStyle.CwS20W400),
                        Text("50분", style: MyTextStyle.CwS22W600),
                        Text("을 특별한 ", style: MyTextStyle.CwS20W400),
                        Text("50분", style: MyTextStyle.CwS22W600),
                        Text("으로 ", style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    Text("바꿀 준비가 끝났어요!", style: MyTextStyle.CwS20W400),
                    SizedBox(
                      height: 20,
                    ),
                    Text("아무 곳이나 클릭해주세요", style: MyTextStyle.CwS12W400),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "reservationButton",
        keyTarget: reservationButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            builder: (context, controller) {
              return Container(
                width: 200,
                height: 500,
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: [
                        Text('예약 시간 ', style: MyTextStyle.CwS20W400),
                        Text('10분', style: MyTextStyle.CwS22W600),
                        Text(' 전부터', style: MyTextStyle.CwS20W400),
                        Text(" 입장할 수 있어요", style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text("입장 후에 ", style: MyTextStyle.CwS20W400),
                        Text("딱 50분만", style: MyTextStyle.CwS22W600),
                        Text(" 집중해봐요", style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    Text(
                      '다른 사람들과 함께한 50분',
                      style: MyTextStyle.CwS20W400,
                    ),
                    Text('분명 특별한 시간이 될 거에요!!', style: MyTextStyle.CwS20W400),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text('노쇼', style: MyTextStyle.CwS22W600),
                        Text('는 금물!', style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    Text('노쇼 당한 상대방은 외로이 남겨져요 ㅠㅠ',
                        style: MyTextStyle.CwS20W600),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      '오늘도 화이팅입니다 :)',
                      style: MyTextStyle.CwS20W400,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
    return targets;
  }

  static void mobileCreateTutorialBeforeReservation() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _mobileCreateTargetsBeforeReservation(),
      colorShadow: MyColors.purple200,
      textSkip: "그만 보기",
      paddingFocus: 10,
      opacityShadow: 0.9,
    );
  }

  static void mobileCreateTutorialAfterReservation(ref) {
    tutorialCoachMark = TutorialCoachMark(
      targets: _mobileCreateTargetsAfterReservation(ref),
      colorShadow: MyColors.purple200,
      textSkip: "그만 보기",
      paddingFocus: 10,
      opacityShadow: 0.9,
    );
  }

  static List<TargetFocus> _mobileCreateTargetsBeforeReservation() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "calendarButton",
        keyTarget: calendarButton,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            customPosition: CustomTargetContentPosition(bottom: 0, left: 0),
            builder: (context, controller) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: [
                        Text("원하는 시간에 클릭하고 ", style: MyTextStyle.CwS16W400),
                        Text("'예약'", style: MyTextStyle.CwS18W600),
                        Text(" 버튼을 눌러봐요!", style: MyTextStyle.CwS16W400),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text("예약하시고 나서, 전 다시 찾아올게요!", style: MyTextStyle.CwS16W400),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  static List<TargetFocus> _mobileCreateTargetsAfterReservation(ref) {
    updateIsOnboardedTrue(ref);
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "calendarButton",
        keyTarget: calendarButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            customPosition: CustomTargetContentPosition(bottom: 0, left: 0),
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Text("이제 평범한 ", style: MyTextStyle.CwS16W400),
                        Text("50분", style: MyTextStyle.CwS18W600),
                        Text("을 특별한 ", style: MyTextStyle.CwS16W400),
                        Text("50분", style: MyTextStyle.CwS18W600),
                        Text("으로 ", style: MyTextStyle.CwS16W400),
                      ],
                    ),
                    Text("바꿀 준비가 끝났어요!", style: MyTextStyle.CwS16W400),
                    SizedBox(
                      height: 5,
                    ),
                    Text("아무 곳이나 클릭해주세요", style: MyTextStyle.CwS12W400),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "reservationButton",
        keyTarget: reservationButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                width: 200,
                height: 500,
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: [
                        Text('예약 시간 ', style: MyTextStyle.CwS16W400),
                        Text('10분', style: MyTextStyle.CwS18W600),
                        Text(' 전부터 입장할 수 있어요', style: MyTextStyle.CwS16W400),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text("입장 후에 ", style: MyTextStyle.CwS16W400),
                        Text("딱 50분만 ", style: MyTextStyle.CwS16W400),
                        Text("집중해봐요", style: MyTextStyle.CwS16W400),
                      ],
                    ),
                    Text(
                      '다른 사람들과 함께한 50분',
                      style: MyTextStyle.CwS16W400,
                    ),
                    Text('분명 특별한 시간이 될 거에요!', style: MyTextStyle.CwS16W400),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text('노쇼', style: MyTextStyle.CwS18W600),
                        Text('는 금물!', style: MyTextStyle.CwS16W400),
                      ],
                    ),
                    Text('노쇼 당한 상대방은 외로이 남겨져요 ㅠㅠ',
                        style: MyTextStyle.CwS18W600),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      '오늘도 화이팅입니다 :)',
                      style: MyTextStyle.CwS16W400,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  static void tabletCreateTutorialBeforeReservation() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _tabletCreateTargetsBeforeReservation(),
      colorShadow: MyColors.purple200,
      textSkip: "그만 보기",
      paddingFocus: 10,
      opacityShadow: 0.9,
    );
  }

  static void tabletCreateTutorialAfterReservation(ref) {
    tutorialCoachMark = TutorialCoachMark(
      targets: _tabletCreateTargetsAfterReservation(ref),
      colorShadow: MyColors.purple200,
      textSkip: "그만 보기",
      paddingFocus: 10,
      opacityShadow: 0.9,
    );
  }

  static List<TargetFocus> _tabletCreateTargetsBeforeReservation() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "calendarButton",
        keyTarget: calendarButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(),
            builder: (context, controller) {
              return Container(
                width: 300,
                height: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/calendar_screen_reserve.gif',
                        width: 175,
                      ),
                    ),
                    SizedBox(width: 30),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Text("원하는 시간에 클릭하고", style: MyTextStyle.CwS20W400),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("'예약'", style: MyTextStyle.CwS22W600),
                            Text(" 버튼을 눌러봐요!", style: MyTextStyle.CwS20W400),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text("예약하시고 나서, 전 다시 찾아올게요!",
                            style: MyTextStyle.CwS20W400),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  static List<TargetFocus> _tabletCreateTargetsAfterReservation(ref) {
    List<TargetFocus> targets = [];
    updateIsOnboardedTrue(ref);
    targets.add(
      TargetFocus(
        identify: "calendarButton",
        keyTarget: calendarButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(top: 20),
            builder: (context, controller) {
              return Container(
                width: 300,
                height: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("이제 평범한 ", style: MyTextStyle.CwS20W400),
                        Text("50분", style: MyTextStyle.CwS22W600),
                        Text("을 특별한 ", style: MyTextStyle.CwS20W400),
                        Text("50분", style: MyTextStyle.CwS22W600),
                        Text("으로 ", style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    Text("바꿀 준비가 끝났어요!", style: MyTextStyle.CwS20W400),
                    SizedBox(
                      height: 10,
                    ),
                    Text("아무 곳이나 클릭해주세요", style: MyTextStyle.CwS16W400),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "reservationButton",
        keyTarget: reservationButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                width: 200,
                height: 500,
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text('예약 시간 ', style: MyTextStyle.CwS20W400),
                        Text('10분', style: MyTextStyle.CwS22W600),
                        Text(' 전부터', style: MyTextStyle.CwS20W400),
                        Text(" 입장할 수 있어요", style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text("입장 후에 ", style: MyTextStyle.CwS20W400),
                        Text("딱 50분만", style: MyTextStyle.CwS22W600),
                        Text(" 집중해봐요", style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    Text(
                      '다른 사람들과 함께한 50분',
                      style: MyTextStyle.CwS20W400,
                    ),
                    Text('분명 특별한 시간이 될 거에요!!', style: MyTextStyle.CwS20W400),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text('노쇼', style: MyTextStyle.CwS22W600),
                        Text('는 금물!', style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    Text('노쇼 당한 상대방은 외로이 남겨져요 ㅠㅠ',
                        style: MyTextStyle.CwS20W600),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      '오늘도 화이팅입니다 :)',
                      style: MyTextStyle.CwS20W400,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
    return targets;
  }

  static void updateIsOnboardedTrue(ref) async {
    final database = ref.read(databaseProvider);
    UserPublicModel userPublic = UserPublicModel(
      isOnboarded: true,
    );
    UserPrivateModel userPrivate = UserPrivateModel();
    UserModel updateUser = UserModel(userPublic, userPrivate);
    await database.updateUser(updateUser);
  }
}

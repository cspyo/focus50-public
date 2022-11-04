import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/auth/auth_view_model.dart';
import 'package:focus42/feature/jitsi/presentation/list_items_builder_2.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/mobile_widgets/mobile_calendar.dart';
import 'package:focus42/mobile_widgets/mobile_drawer.dart';
import 'package:focus42/mobile_widgets/mobile_group_widget.dart';
import 'package:focus42/mobile_widgets/mobile_reservation.dart';
import 'package:focus42/mobile_widgets/mobile_row_group_toggle_button_widget.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/models/user_private_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/widgets/group_widget.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../widgets/line.dart';

class MobileCalendarScreen extends ConsumerStatefulWidget {
  MobileCalendarScreen({Key? key}) : super(key: key);
  @override
  _MobileCalendarScreenState createState() => _MobileCalendarScreenState();
}

class _MobileCalendarScreenState extends ConsumerState<MobileCalendarScreen> {
  bool isNotificationOpen = true;
  final Uri toLaunch = Uri(
    scheme: 'https',
    host: 'forms.gle',
    path: '/3bGecKhsiAwtyk4k9',
  );
  CalendarController calendarController = CalendarController();
  GlobalKey calendarButtonKey = GlobalKey();
  GlobalKey reservationButton = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => popupOnboardingStart(ref, context));
  }

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final _myGroupStream = ref.watch(myGroupFutureProvider);
    final _myActivatedGroupId = ref.watch(activatedGroupIdProvider);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Focus',
                style: TextStyle(
                  fontFamily: 'Okddung',
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              Text(
                '50',
                style: TextStyle(
                  fontFamily: 'Okddung',
                  fontSize: 30,
                  color: purple300,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: purple300),
        ),
        drawer: MobileDrawer(),
        body: SingleChildScrollView(
          child: Column(
            //페이지 전체 구성
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Line(),
              Column(children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: screenWidth - 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '그룹',
                        style: MyTextStyle.CgS18W500,
                      ),
                      Container(width: 68, height: 32, child: MobileGroup()),
                    ],
                  ),
                ),
                Container(
                  width: screenWidth - 40,
                  height: 80,
                  child: ListItemsBuilder2<GroupModel>(
                    data: _myGroupStream,
                    itemBuilder: (context, model) =>
                        MobilRowGroupToggleButtonWidget(
                      group: model,
                      isThisGroupActivated:
                          _myActivatedGroupId == model.id ? true : false,
                    ),
                    creator: () => new GroupModel(
                      id: 'public',
                      name: '전체',
                    ),
                    axis: Axis.horizontal,
                  ),
                ),
                Container(
                  key: calendarButtonKey,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: border100)),
                  height: screenHeight - 245,
                  child: MobileCalendar(
                    calendarController: calendarController,
                    isNotificationOpen: isNotificationOpen,
                    createTutorial: createTutorialAfterReservation,
                    showTutorial: showTutorial,
                  ),
                ),
                Container(
                  key: reservationButton,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: MyColors.purple300,
                  ),
                  child: MobileReservation(),
                ),
              ])
            ],
          ),
        ));
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    required String route,
  }) {
    final color = Colors.white;
    return ListTile(
        leading: Icon(icon, color: color),
        onTap: () {
          Get.rootDelegate.toNamed(route);
        },
        title: Text(
          text,
          style: TextStyle(color: color),
        ));
  }

  List<TargetFocus> _createTargetsBeforeReservation() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "calendarButtonKey",
        keyTarget: calendarButtonKey,
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
                    // Row(
                    //   children: [
                    //     Text("나 자신과의 약속보다 ", style: MyTextStyle.CwS20W400),
                    //     Text("타인과의 약속은", style: MyTextStyle.CwS24W500H1),
                    //   ],
                    // ),
                    // Text("지킬 확률이 87% 더 높아요!", style: MyTextStyle.CwS20W400),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // Row(
                    //   children: [
                    //     Text("캘린더에 집중할 시간을 ", style: MyTextStyle.CwS20W400),
                    //     Text("예약", style: MyTextStyle.CwS24W500H1),
                    //     Text("해 볼까요?", style: MyTextStyle.CwS20W400),
                    //     Icon(
                    //       Icons.arrow_right_alt_rounded,
                    //       color: Colors.white,
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(16),
                    //   child: Image.asset(
                    //     'assets/images/calendar_screen_reserve.gif',
                    //     width: 220,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),

                    Row(
                      children: [
                        Text("원하는 시간에 클릭하고 ", style: MyTextStyle.CwS16W400),
                        Text("'예약'", style: MyTextStyle.CwS16W600),
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

  List<TargetFocus> _createTargetsAfterReservation() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "calendarButtonKey",
        keyTarget: calendarButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            // padding: EdgeInsets.only(left: 20),
            customPosition: CustomTargetContentPosition(bottom: 0, left: 0),
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                // width: 200,
                // height: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    // Text('훌륭해요!', style: MyTextStyle.CwS16W400),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Text("이제 평범한 ", style: MyTextStyle.CwS16W400),
                        Text("50분", style: MyTextStyle.CwS16W600),
                        Text("을 특별한 ", style: MyTextStyle.CwS16W400),
                        Text("50분", style: MyTextStyle.CwS16W600),
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
          // TargetContent(child: Text('ㅇㄴ머엄눙'))
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
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: [
                        Text('예약 시간 ', style: MyTextStyle.CwS20W400),
                        Text('10분', style: MyTextStyle.CwS24W500H1),
                        Text(' 전부터', style: MyTextStyle.CwS20W400),
                        Text(" 입장할 수 있어요", style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text("입장 후에 ", style: MyTextStyle.CwS20W400),
                        Text("딱 50분만 ", style: MyTextStyle.CwS24W500H1),
                        Text("집중해봐요", style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    Text(
                      '다른 사람들과 함께한 50분',
                      style: MyTextStyle.CwS20W400,
                    ),
                    Text('분명 특별한 시간이 될 거에요😁', style: MyTextStyle.CwS20W400),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text('노쇼', style: MyTextStyle.CwS24W500H1),
                        Text('는 금물!', style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    Text('노쇼 당한 상대방은 외로이 남겨져요🥲', style: MyTextStyle.CwS20W600),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      '오늘도 화이팅입니다🙌',
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

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void createTutorialBeforeReservation() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargetsBeforeReservation(),
      colorShadow: MyColors.purple200,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.9,
    );
  }

  void createTutorialAfterReservation() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargetsAfterReservation(),
      colorShadow: MyColors.purple200,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.9,
    );
  }

  Future<dynamic>? popupOnboardingStart(
      WidgetRef ref, BuildContext context) async {
    final database = ref.watch(databaseProvider);
    final user = await database.getUserPublic();
    bool? isOnboarded = user.isOnboarded;
    final authViewModel = ref.read(authViewModelProvider);
    if (isOnboarded != null && isOnboarded ||
        !(await authViewModel.isSignedUp()) ||
        isOnboarded == null) {
      return null;
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
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
                      '안녕하세요!',
                      textStyle: MyTextStyle.CbS20W400,
                      speed: const Duration(milliseconds: 70),
                    ),
                    TypewriterAnimatedText(
                      "손님이 오셨다고 해서\n마중 나온 '포공이'입니다",
                      textStyle: MyTextStyle.CbS20W400,
                      speed: const Duration(milliseconds: 50),
                    ),
                    TypewriterAnimatedText(
                      '세상에서 가장 집중이 잘되는 공간,\nFocus50에 오신 걸 환영합니다.',
                      textStyle: MyTextStyle.CbS20W400,
                      speed: const Duration(milliseconds: 50),
                    ),
                    TypewriterAnimatedText(
                      '화면에서 직접 설명드릴게요!\n따라오세요!',
                      textStyle: MyTextStyle.CbS20W400,
                      speed: const Duration(milliseconds: 50),
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 400),
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
                    onPressed: () async {
                      Navigator.pop(context);
                      createTutorialBeforeReservation();
                      showTutorial();
                      updateIsOnboardedTrue();
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

  void updateIsOnboardedTrue() async {
    final database = ref.read(databaseProvider);
    UserPublicModel userPublic = UserPublicModel(
      isOnboarded: true,
    );
    UserPrivateModel userPrivate = UserPrivateModel();
    UserModel updateUser = UserModel(userPublic, userPrivate);
    await database.updateUser(updateUser);
  }
}

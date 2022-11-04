import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/auth/auth_view_model.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/models/notice_model.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/models/user_private_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/color_convert.dart';
import 'package:focus42/widgets/calendar.dart';
import 'package:focus42/widgets/desktop_header.dart';
import 'package:focus42/widgets/group_widget.dart';
import 'package:focus42/widgets/line.dart';
import 'package:focus42/widgets/reservation.dart';
import 'package:focus42/widgets/todo.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';

final noticeStreamProvider =
    StreamProvider.autoDispose<List<NoticeModel?>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getNotices();
});

// ignore: use_key_in_widget_constructors
class CalendarScreen extends ConsumerStatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int remainingTime = 0;
  int tabletBoundSize = 1200;
  DateTime now = new DateTime.now();

  String fastReservation = '10시';

  DateTime fastestReservation =
      new DateTime.fromMicrosecondsSinceEpoch(10000000000000000);
  bool isNotificationOpen = true;
  GlobalKey calendarButton = GlobalKey();
  GlobalKey reservationButton = GlobalKey();
  GlobalKey groupSearchKey = GlobalKey();
  GlobalKey groupCreateKey = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  GlobalKey keyButton5 = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  // late TutorialCoachMark tutorialCoachMark2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => popupOnboardingStart(ref, context));
  }

  @override
  Widget build(BuildContext context) {
    final noticeStream = ref.watch(noticeStreamProvider);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletSize = screenWidth < 1200 ? true : false;
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(//페이지 전체 구성
          children: <Widget>[
        isNotificationOpen
            ? SizedBox(
                height: 50,
                width: screenWidth,
                child: noticeStream.when(
                  loading: () => Container(
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        '로딩중입니다',
                        style: TextStyle(
                          // color: Colors.black,
                          color: hexToColor('#FFFFFF'),
                        ),
                      ),
                    ),
                  ),
                  error: (_, __) => Container(
                    width: screenWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          hexToColor('#6087FF'),
                          hexToColor('#8365FF'),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '에러가 발생했습니다. 새로고침 해주세요',
                        style: TextStyle(
                          // color: Colors.black,
                          color: hexToColor('#FFFFFF'),
                        ),
                      ),
                    ),
                  ),
                  data: (notices) => (notices.length > 1)
                      ? CarouselSlider(
                          options: CarouselOptions(
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 7),
                            viewportFraction: 1.0,
                          ),
                          items: notices
                              .map(
                                (notice) => Container(
                                  width: screenWidth,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        hexToColor(notice!.startColor!),
                                        hexToColor(notice.endColor!),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          _launchURL(notice.url!);
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              child: Center(
                                                child: Text(
                                                  notice.text!,
                                                  style: TextStyle(
                                                    // color: Colors.black,
                                                    color: hexToColor(
                                                        notice.fontColor!),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_right,
                                              color:
                                                  hexToColor(notice.fontColor!),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isNotificationOpen = false;
                                            });
                                          },
                                          hoverColor: Colors.transparent,
                                          icon: Icon(
                                            Icons.close,
                                            color:
                                                hexToColor(notice.fontColor!),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : InkWell(
                          onTap: () {
                            _launchURL(notices.first!.url!);
                          },
                          child: Container(
                            width: screenWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  hexToColor(notices.first!.startColor!),
                                  hexToColor(notices.first!.endColor!),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                ),
                                InkWell(
                                  onTap: () {
                                    _launchURL(notices.first!.url!);
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Center(
                                          child: Text(
                                            notices.first!.text!,
                                            style: TextStyle(
                                              // color: Colors.black,
                                              color: hexToColor(
                                                  notices.first!.fontColor!),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_right,
                                        color: hexToColor(
                                            notices.first!.fontColor!),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isNotificationOpen = false;
                                      });
                                    },
                                    hoverColor: Colors.transparent,
                                    icon: Icon(
                                      Icons.close,
                                      color:
                                          hexToColor(notices.first!.fontColor!),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                ),
              )
            : SizedBox.shrink(), //carousel
        DesktopHeader(),
        const Line(),
        Container(
          height: isNotificationOpen ? screenHeight - 125 : screenHeight - 75,
          child: isTabletSize
              ? Column(
                  children: [
                    Container(
                      key: reservationButton,
                      height: 100,
                      child: Reservation(),
                    ),
                    Row(
                      children: [
                        Container(
                          // key: keyButton1,
                          width: 100,
                          height: isNotificationOpen
                              ? screenHeight - 225
                              : screenHeight - 175,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: border100, width: 1.5))),
                          child: Group(
                            groupCreateKey: groupCreateKey,
                            groupSearchKey: groupSearchKey,
                            isNotificationOpen: isNotificationOpen,
                          ),
                        ),
                        Container(
                          key: calendarButton,
                          height: isNotificationOpen
                              ? screenHeight - 225
                              : screenHeight - 175,
                          width: screenWidth - 100,
                          child: Calendar(
                            // calendarKey: keyButton,
                            createTutorial: createTutorialAfterReservation,
                            showTutorial: showTutorial,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              : Row(
                  children: <Widget>[
                    Container(
                      width: 420,
                      height: screenHeight - 70,
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(color: border100, width: 1.5))),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            key: reservationButton,
                            child: Reservation(),
                          ),
                          Todo(),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: isNotificationOpen
                              ? screenHeight - 125
                              : screenHeight - 75,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: border100, width: 1.5))),
                          child: Group(
                              groupCreateKey: groupCreateKey,
                              groupSearchKey: groupSearchKey,
                              isNotificationOpen: isNotificationOpen),
                        ),
                        Container(
                            key: calendarButton,
                            width: screenWidth - 520,
                            height: isNotificationOpen
                                ? screenHeight - 125
                                : screenHeight - 75,
                            child: Calendar(
                              createTutorial: createTutorialAfterReservation,
                              showTutorial: showTutorial,
                            )),
                      ],
                    ),
                  ],
                ),
        ),
      ]),
    ));
  }

  void _launchURL(String url) async {
    final _url = url;
    if (await canLaunchUrl(Uri.parse(_url))) {
      await launchUrl(Uri.parse(_url));
    } else {
      throw 'Could not launch $_url';
    }
  }

  List<TargetFocus> _createTargetsBeforeReservation() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "calendarButton",
        keyTarget: calendarButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            builder: (context, controller) {
              return Container(
                width: 200,
                height: 900,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: [
                        Text("나 자신과의 약속보다 ", style: MyTextStyle.CwS20W400),
                        Text("타인과의 약속은", style: MyTextStyle.CwS24W500H1),
                      ],
                    ),
                    Text("지킬 확률이 87% 더 높아요!", style: MyTextStyle.CwS20W400),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text("캘린더에 집중할 시간을 ", style: MyTextStyle.CwS20W400),
                        Text("예약", style: MyTextStyle.CwS24W500H1),
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
                        Text("'예약'", style: MyTextStyle.CwS24W500H1),
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

  List<TargetFocus> _createTargetsAfterReservation() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "calendarButton",
        keyTarget: calendarButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            builder: (context, controller) {
              return Container(
                width: 200,
                height: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('훌륭해요!', style: MyTextStyle.CwS20W400),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text("이제 평범한 ", style: MyTextStyle.CwS20W400),
                        Text("50분", style: MyTextStyle.CwS24W500H1),
                        Text("을 특별한 ", style: MyTextStyle.CwS20W400),
                        Text("50분", style: MyTextStyle.CwS24W500H1),
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
                        Text('10분', style: MyTextStyle.CwS24W500H1),
                        Text(' 전부터', style: MyTextStyle.CwS20W400),
                        Text(" 입장할 수 있어요", style: MyTextStyle.CwS20W400),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text("입장 후에 ", style: MyTextStyle.CwS20W400),
                        Text("딱 50분만", style: MyTextStyle.CwS24W500H1),
                        Text(" 집중해봐요", style: MyTextStyle.CwS20W400),
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
                      '안녕하세요 ${user.nickname}님!',
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
                    onPressed: () {
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

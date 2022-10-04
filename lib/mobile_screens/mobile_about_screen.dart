import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/auth_method.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/view_models.dart/users_notifier.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileAboutScreen extends ConsumerStatefulWidget {
  MobileAboutScreen({Key? key}) : super(key: key);
  @override
  _MobileAboutScreenState createState() => _MobileAboutScreenState();
}

class _MobileAboutScreenState extends ConsumerState<MobileAboutScreen>
    with TickerProviderStateMixin {
  bool getUserInfo = false;
  String userPhotoUrl =
      'https://firebasestorage.googleapis.com/v0/b/focus-50.appspot.com/o/profilePics%2Fuser.png?alt=media&token=69e13fc9-b2ea-460c-98e0-92fe6613461e';
  String userNickname = '';
  String userJob = '';

  late AnimationController _controller;
  double wavesStartPoint = 0.0;
  List<double> wavesEndPoints = [2.5, -2, 2.2];

  Future<void> getUserData() async {
    final usersNotifier = ref.read(usersProvider.notifier);
    final database = ref.read(databaseProvider);
    final auth = ref.read(firebaseAuthProvider);
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      if (!usersNotifier.containsKey(uid)) {
        UserPublicModel user = await database.getUserPublic(othersUid: uid);
        usersNotifier.addAll({uid: user});
      }
      final users = ref.read(usersProvider);
      userPhotoUrl = users[uid]!.photoUrl!;
      userNickname = users[uid]!.nickname!;
      userJob = users[uid]!.job!;
      setState(() {
        getUserInfo = true;
      });
    }
  }

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 20))
          ..repeat();
    getUserData();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final authState = ref.watch(authStateChangesProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
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
      drawer: Drawer(
        backgroundColor: purple300,
        child:
            ListView(padding: EdgeInsets.symmetric(horizontal: 20), children: [
          SizedBox(
            height: 20,
          ),
          SizedBox(
              height: 60,
              child: getUserInfo
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          Image.network(
                            userPhotoUrl,
                          ),
                          SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userNickname,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.left),
                              Text(
                                userJob,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.left,
                              )
                            ],
                          )
                        ])
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          Image.asset('assets/images/default_profile.png'),
                          SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userNickname,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.left),
                              Text(
                                userJob,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.left,
                              )
                            ],
                          )
                        ])
              // : Container(
              //     alignment: Alignment.center,
              //     width: 20,
              //     height: 20,
              //     child:
              //         CircularProgressIndicator(color: Colors.white)),
              ),
          SizedBox(
            height: 10,
          ),
          buildMenuItem(
              text: 'About', icon: Icons.waving_hand, route: Routes.ABOUT),
          SizedBox(
            height: 10,
          ),
          buildMenuItem(
              text: 'Calendar',
              icon: Icons.calendar_month,
              route: Routes.CALENDAR),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: Colors.white,
            thickness: 1,
          ),
          SizedBox(
            height: 20,
          ),
          (authState != null)
              ? SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      setState(() {
                        AuthMethods().signOut();
                      });
                      Get.rootDelegate.toNamed(Routes.LOGIN);
                    },
                    child: const Text(
                      '  로그아웃  ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: purple300,
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Get.rootDelegate.toNamed(Routes.SIGNUP);
                    },
                    child: const Text(
                      '  회원가입  ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: purple300,
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 10,
          ),
          (authState != null)
              ? Container()
              : SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: purple300,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Colors.white,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Get.rootDelegate.toNamed(Routes.LOGIN);
                    },
                    child: const Text(
                      '  로그인  ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ]),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight - 50,
                  color: purple300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '낮은 집중력, 당신의 문제가 아닙니다.',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          Text(
                            '성격의 문제가 아니라, 설계의 결함입니다.',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '스탠포드 행동설계 연구에 입각한',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w500),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '집중향상 ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500),
                              ),
                              Stack(
                                children: [
                                  Positioned(
                                    bottom: 4,
                                    child: Container(
                                      width: 134,
                                      height: 22,
                                      color: textHighlightColor,
                                      child: Text(''),
                                    ),
                                  ),
                                  Text(
                                    '캠스터디',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Text(
                                ' Focus 50',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Image.asset(
                        'assets/images/demo.png',
                        height: screenWidth * 0.5,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Chrome PC 사용을 권장합니다',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: -screenWidth * 0.8,
                  child: RotationTransition(
                    turns: Tween(begin: wavesStartPoint, end: wavesEndPoints[0])
                        .animate(_controller),
                    child: Container(
                      width: screenWidth,
                      height: screenWidth,
                      decoration: BoxDecoration(
                          color: secondWaveColor,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.46)),
                      child: const Text(''),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -screenWidth * 0.5,
                  left: -screenWidth * 0.3,
                  child: RotationTransition(
                    turns: Tween(begin: wavesStartPoint, end: wavesEndPoints[1])
                        .animate(_controller),
                    child: Container(
                      width: screenWidth * 0.7,
                      height: screenWidth * 0.7,
                      decoration: BoxDecoration(
                          color: firstWaveColor,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.31)),
                      child: const Text(''),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -screenWidth * 0.6,
                  right: -screenWidth * 0.4,
                  child: RotationTransition(
                    turns: Tween(begin: wavesStartPoint, end: wavesEndPoints[2])
                        .animate(_controller),
                    child: Container(
                      width: screenWidth * 0.8,
                      height: screenWidth * 0.8,
                      decoration: BoxDecoration(
                          color: thirdWaveColor,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.31)),
                      child: const Text(''),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: screenWidth,
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/contributor1.png',
                    width: screenWidth * 0.35,
                  ),
                  Image.asset(
                    'assets/images/contributor2.png',
                    width: screenWidth * 0.25,
                  ),
                  Image.asset(
                    'assets/images/contributor3.jpeg',
                    width: screenWidth * 0.3,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '우리 서비스를 이용하지 않아도 좋아요',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Column(
                    children: [
                      Text(
                        '어디서 어떤 공부를 하든,',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '진짜 공부',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '를 하길 바라요.',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '서비스를 기획하며 습득한 ',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '모든 지식과 이론',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '이',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '공통적으로 말하던 ',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '세가지',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            ' 방법을 알려드릴게요.',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            Column(
              children: [
                SvgPicture.asset('assets/images/postit1.svg'),
                SvgPicture.asset('assets/images/postit2.svg'),
                SvgPicture.asset('assets/images/postit3.svg'),
              ],
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '다른 사람들과',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w400),
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 134,
                                  height: 24,
                                  color: textHighlightColor,
                                  child: Text(''),
                                ),
                              ),
                              Text(
                                '오공',
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            '을 ',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '예약',
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '해봐요',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Text(
                    "*오공은 '오늘 공부'의 줄임말로, Focus50에서 공부 하는 시간 단위입니다.",
                    style: TextStyle(fontSize: 10),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(
                      'assets/images/calendarClick.gif',
                      width: screenWidth * 0.85,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '예약 후에는,',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w400),
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 134,
                                  height: 24,
                                  color: textHighlightColor,
                                  child: Text(''),
                                ),
                              ),
                              Text(
                                '오공',
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            '을 ',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '50분',
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '동안',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      Text(
                        '진행 해봐요',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "여러 명이 '오공'할 때보다, 1:1로 진행했을 때 집중이 잘 된대요!",
                    style: TextStyle(fontSize: 10),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    "이번 '오공'에서 할 일들을 투두에 적어 봐요.",
                    style: TextStyle(fontSize: 10),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(
                      'assets/images/sessionTimer.gif',
                      width: screenWidth * 0.85,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        '지금까지 사용자들은',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w400),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 134,
                                  height: 24,
                                  color: textHighlightColor,
                                  child: Text(''),
                                ),
                              ),
                              Text(
                                '70350',
                                style: TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            '분만큼',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Text(
                        '집중하셨습니다.',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.rootDelegate.toNamed(Routes.CALENDAR);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: purple300,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(16.0),
                        ),
                      ),
                      child: Text(
                        '집중하러 가기',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
                width: screenWidth,
                height: 300,
                color: footerBackgroundColor,
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Focus 50',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600),
                        ),
                        Column(
                          children: [
                            Text(
                              'SW마에스트로 지원',
                              style: TextStyle(
                                color: footerGreyColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              '과학기술정보통신부 주관',
                              style: TextStyle(
                                color: footerGreyColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SW 마에스트로 | Team : Focusmaker',
                              style: TextStyle(
                                color: footerGreyColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              '서울특별시 강남구 테헤란로 311 59-12 아남타워 7층',
                              style: TextStyle(
                                color: footerGreyColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Contact',
                                style: TextStyle(
                                  color: footerGreyColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      launch(
                                          'https://www.instagram.com/focus_50_/');
                                    },
                                    icon: SvgPicture.asset(
                                        'assets/images/instagram.svg'),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      launch(
                                          'https://open.kakao.com/o/gJyG7Dse');
                                    },
                                    icon: SvgPicture.asset(
                                        'assets/images/kakao.svg'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 1.5,
                      color: footerLineColor,
                    ),
                    SizedBox(
                      width: screenWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '© 2022 All rights reserved',
                            style: TextStyle(
                              color: footerGreyColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Terms',
                                style: TextStyle(
                                  color: footerGreyColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: footerGreyColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
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
}

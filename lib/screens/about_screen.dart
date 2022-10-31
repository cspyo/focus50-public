import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/widgets/desktop_header.dart';
import 'package:focus42/widgets/line.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  double wavesStartPoint = 0.0;
  List<double> wavesEndPoints = [2.5, -2, 2.2];
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 20))
          ..repeat();
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
    bool isTabletColumn =
        screenWidth < 900 && screenHeight > 1000 ? true : false;
    bool isOnlyWidthSmall =
        screenWidth <= 900 && screenHeight <= 1000 ? true : false;

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            DesktopHeader(),
            const Line(),
            Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: screenWidth,
                        height: screenHeight - 140,
                        decoration: BoxDecoration(
                          color: purple300,
                        ),
                        child: Flex(
                          direction:
                              isTabletColumn ? Axis.vertical : Axis.horizontal,
                          mainAxisAlignment: isTabletColumn
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              // decoration: BoxDecoration(
                              //     border:
                              //         Border.all(width: 1, color: Colors.red)),
                              // height: isSmall
                              //     ? screenHeight - 500
                              //     : screenHeight - 400,
                              height: isTabletColumn
                                  ? screenHeight - 760
                                  : screenHeight - 400,
                              child: Column(
                                mainAxisAlignment: isTabletColumn
                                    ? MainAxisAlignment.spaceEvenly
                                    : MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: isTabletColumn
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: isTabletColumn
                                        ? CrossAxisAlignment.center
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '낮은 집중력, 당신의 문제가 아닙니다.',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 26),
                                      ),
                                      Text(
                                        '성격의 문제가 아니라, 설계의 결함입니다.',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 26),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: isTabletColumn
                                        ? CrossAxisAlignment.center
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '스탠포드 행동설계 연구에 입각한',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '집중향상 ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.w500),
                                          ),
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
                                                '캠스터디',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 36,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            ' Focus',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 40,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Text(
                                            '50',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 40,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 110,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.rootDelegate
                                            .toNamed(Routes.CALENDAR);
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(16.0),
                                        ),
                                      ),
                                      child: Text(
                                        '입장하기',
                                        style: TextStyle(
                                            color: purple300, fontSize: 20),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: isTabletColumn ? 400 : 460,
                                  child: Image.asset(
                                    "assets/images/demo.png",
                                  ),
                                ),
                                Text(
                                  'Chrome PC 사용을 권장합니다',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ],
                        )),
                    Container(
                      color: purple300,
                      width: screenWidth,
                      height: 70,
                    ),
                  ],
                ),
                Positioned(
                  bottom: -screenWidth * 0.67,
                  left: -screenWidth * 0.2,
                  child: RotationTransition(
                    turns: Tween(begin: wavesStartPoint, end: wavesEndPoints[0])
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
                  bottom: -screenWidth * 0.96,
                  child: RotationTransition(
                    turns: Tween(begin: wavesStartPoint, end: wavesEndPoints[1])
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
                  bottom: -screenWidth * 0.77,
                  right: -screenWidth * 0.2,
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
              child: Column(
                children: [
                  SizedBox(
                    width: screenWidth,
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/contributor1.png',
                          height: 80,
                        ),
                        Image.asset(
                          'assets/images/contributor2.png',
                          height: 80,
                        ),
                        Image.asset(
                          'assets/images/contributor3.jpeg',
                          height: 80,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 70),
                  Text(
                    '집중에 다가가는 세 가지 방법',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
            Container(
              // height: isSmall ? 500 : 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/images/postit1.svg',
                    width: screenWidth * 0.3,
                  ),
                  SvgPicture.asset(
                    'assets/images/postit2.svg',
                    width: screenWidth * 0.3,
                  ),
                  SvgPicture.asset(
                    'assets/images/postit3.svg',
                    width: screenWidth * 0.3,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only(left: 40, right: 40),
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '더 이상',
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.w400),
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 180,
                                  height: 24,
                                  color: textHighlightColor,
                                  child: Text(''),
                                ),
                              ),
                              Text(
                                '미루지 않게',
                                style: TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            ' 해줄게요',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "캘린더에 집중할 시간을 예약해보세요",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    "나 자신만이 아닌 남과의 약속은 지킬 확률이 87% 더 높대요!",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.start,
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
            SizedBox(height: 100),
            Container(
              padding: EdgeInsets.only(left: 40, right: 40),
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '50분',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '동안',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 80,
                                  height: 24,
                                  color: textHighlightColor,
                                  child: Text(''),
                                ),
                              ),
                              Text(
                                '함께 ',
                                style: TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            '집중 해봐요',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "캠을 켜고 자신이 집중하는 모습을 공유해봐요",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    "감시효과는 딴짓을 막아주어 몰입도가 92% 높아진대요!",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(
                      'assets/images/photoInSession.png',
                      width: screenWidth * 0.85,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 110),
            Container(
              padding: EdgeInsets.only(left: 40, right: 40),
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 140,
                              height: 24,
                              color: textHighlightColor,
                              child: Text(''),
                            ),
                          ),
                          Text(
                            '집중 패턴을',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Text(
                        '분석해줄게요',
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "예약 패턴과 노쇼 비율, 세션의 목표 달성율 등을 AI가 분석해 알려줘요",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    "집중의 비밀은 얼마나 나를 아느냐에 달려있어요!",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(
                      'assets/images/report.png',
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
                            fontSize: 36, fontWeight: FontWeight.w400),
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
                                '176250',
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
                            fontSize: 36, fontWeight: FontWeight.w400),
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
                        Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR());
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
                padding: EdgeInsets.only(left: 100, right: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '소마일',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            Text(
                              'SW마에스트로 지원',
                              style: TextStyle(
                                color: footerGreyColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              '과학기술정보통신부 주관',
                              style: TextStyle(
                                color: footerGreyColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '사업자등록번호 | 627-15-01905',
                              style: TextStyle(
                                color: footerGreyColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              '남양주시 다산중앙로 82번길 15',
                              style: TextStyle(
                                color: footerGreyColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                child: Text(
                                  '이용약관',
                                  style: TextStyle(
                                    color: footerGreyColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                onPressed: () {
                                  launch(
                                      "https://cspyo.notion.site/Focus50-bf3dcea5936b4f3a96633ff2d57d71ee");
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                child: Text(
                                  '개인정보처리방침',
                                  style: TextStyle(
                                    color: footerGreyColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () {
                                  launch(
                                      "https://cspyo.notion.site/Focus50-9f22f670ba5c40a286d764cf055ce14a");
                                },
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
}

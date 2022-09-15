import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/widgets/desktop_header.dart';
import 'package:focus42/widgets/line.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx/webviewx.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late WebViewXController webviewController;

  @override
  void initState() {
    super.initState();
  }

  Animation<double> spinAnimation(int seconds, bool reverse) {
    AnimationController _controller =
        AnimationController(vsync: this, duration: Duration(seconds: seconds))
          ..repeat(reverse: reverse);
    return CurvedAnimation(parent: _controller, curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                  children: [
                    Container(
                        width: screenWidth,
                        height: screenHeight - 140,
                        color: purple300,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: screenHeight - 400,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '스탠포드 행동설계 연구에 입각한',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Row(
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
                                                    fontSize: 38,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            ' Focus 50',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.w500),
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
                            SizedBox(
                              width: screenHeight - 300,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/demo.png",
                                    height: screenHeight - 350,
                                  ),
                                  Text(
                                    'Chrome PC 사용을 권장합니다',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
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
                    turns: spinAnimation(4, false),
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
                    turns: spinAnimation(8, true),
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
                    turns: spinAnimation(7, false),
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
              height: screenHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  SizedBox(
                    height: screenHeight - 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '우리 서비스를 이용하지 않아도 좋아요',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.w600),
                        ),
                        Column(
                          children: [
                            Text(
                              '어디서 어떤 공부를 하든,',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '진짜 공부',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '를 하길 바라요.',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 28,
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
                                      fontSize: 28,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '모든 지식과 이론',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '이',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 28,
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
                                      fontSize: 28,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '세가지',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  ' 방법을 알려드릴게요.',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: screenWidth,
              height: screenHeight,
              padding: EdgeInsets.only(top: 100),
              child: SvgPicture.asset('assets/images/three_informations.svg'),
            ),
            Container(
              padding: EdgeInsets.only(left: 100, right: 100),
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
                            fontSize: 36, fontWeight: FontWeight.w400),
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
                                    fontSize: 36, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            '을 ',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '예약',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '해봐요',
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
                    "*오공은 '오늘 공부'의 줄임말로, Focus50(포커스 오공)에서 공부 하는 시간 단위입니다.",
                    style: TextStyle(fontSize: 16),
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
            Container(
              padding: EdgeInsets.only(left: 100, right: 100),
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
                            fontSize: 36, fontWeight: FontWeight.w400),
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
                                    fontSize: 36, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            '을 ',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w400),
                          ),
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
                      Text(
                        '진행 해봐요',
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "여러 명이 '오공'할 때보다, 1:1로 진행했을 때 집중이 잘 된대요!",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    "이번 '오공'에서 할 일들을 투두에 적어 봐요.",
                    style: TextStyle(fontSize: 16),
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
                padding: EdgeInsets.only(left: 100, right: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Focus 50',
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
                              'SW 마에스트로 | Team : Focusmaker',
                              style: TextStyle(
                                color: footerGreyColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              '서울특별시 강남구 테헤란로 311 59-12 아남타워 7층',
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
                              Text(
                                'Terms',
                                style: TextStyle(
                                  color: footerGreyColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: footerGreyColor,
                                  fontSize: 18,
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
}

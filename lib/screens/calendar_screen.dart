import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/widgets/calendar.dart';
import 'package:focus42/widgets/desktop_header.dart';
import 'package:focus42/widgets/group_widget.dart';
import 'package:focus42/widgets/line.dart';
import 'package:focus42/widgets/reservation.dart';
import 'package:focus42/widgets/todo.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: use_key_in_widget_constructors
class CalendarScreen extends StatefulWidget {
  CalendarScreen({Key? key}) : super(key: key);
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int remainingTime = 0;
  int tabletBoundSize = 1200;
  DateTime now = new DateTime.now();

  String fastReservation = '10시';

  DateTime fastestReservation =
      new DateTime.fromMicrosecondsSinceEpoch(10000000000000000);
  bool isNotificationOpen = true;
  final Uri toLaunch = Uri(
    scheme: 'https',
    host: 'forms.gle',
    path: '/3bGecKhsiAwtyk4k9',
  );

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletSize = screenWidth < 1200 ? true : false;
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(//페이지 전체 구성
          children: <Widget>[
        isNotificationOpen
            ? Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xff5E88FF),
                      Color(0xff8465FF),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: isTabletSize ? 10 : 210),
                    InkWell(
                      onTap: () {
                        launchUrl(toLaunch);
                      },
                      child: Row(
                        children: [
                          Text(
                            '더 나은 Focus50 이 되겠습니다. 아이스 아메리카노 받아가세요!  ',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            '설문하러 가기',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_right_alt_rounded,
                      color: Colors.white,
                    ),
                    SizedBox(width: isTabletSize ? 10 : 200),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isNotificationOpen = false;
                        });
                      },
                      hoverColor: Colors.transparent,
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            : SizedBox(),
        DesktopHeader(),
        const Line(),
        Container(
          height: isNotificationOpen ? screenHeight - 125 : screenHeight - 75,
          child: isTabletSize
              ? Column(
                  children: [
                    Container(
                      height: 100,
                      child: Reservation(),
                    ),
                    Container(
                      height: isNotificationOpen
                          ? screenHeight - 225
                          : screenHeight - 175,
                      child: Calendar(),
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
                          Reservation(),
                          Todo(),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: screenWidth - 420,
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: border100, width: 1.5))),
                          child: Group(),
                        ),
                        Container(
                          height: screenHeight - 175,
                          child: Calendar(),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ]),
    ));
  }
}

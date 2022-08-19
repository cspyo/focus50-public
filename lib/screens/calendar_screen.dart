import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/widgets/calendar.dart';
import 'package:focus42/widgets/desktop_header.dart';
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

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(//페이지 전체 구성
          children: <Widget>[
        isNotificationOpen
            ? Container(
                height: 50,
                padding: EdgeInsets.only(left: 450, right: 450),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        launchUrl(toLaunch);
                      },
                      child: Text(
                        '더 나은 Focus50 이 되겠습니다. 설문 부탁드려요. 아이스아메리카노 받아가세요!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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
          child: Row(
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
              Container(
                child: Calendar(),
              ),
            ],
          ),
        ),
      ]),
    ));
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/models/notice_model.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/color_convert.dart';
import 'package:focus42/widgets/calendar.dart';
import 'package:focus42/widgets/desktop_header.dart';
import 'package:focus42/widgets/group_widget.dart';
import 'package:focus42/widgets/line.dart';
import 'package:focus42/widgets/reservation.dart';
import 'package:focus42/widgets/todo.dart';
import 'package:url_launcher/url_launcher.dart';

final noticeStreamProvider =
    StreamProvider.autoDispose<List<NoticeModel?>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getNotices();
});

// ignore: use_key_in_widget_constructors
class CalendarScreen extends ConsumerStatefulWidget {
  CalendarScreen({Key? key}) : super(key: key);
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
  final Uri toLaunch = Uri(
    scheme: 'https',
    host: 'forms.gle',
    path: '/3bGecKhsiAwtyk4k9',
  );

  @override
  void initState() {
    super.initState();
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
        SizedBox(
          height: 50,
          width: screenWidth,
          child: noticeStream.when(
            loading: () => Text("로딩중입니다"),
            error: (_, __) => Text("에러가 발생하였습니다"),
            data: (notices) => (notices.length > 1)
                ? CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 7),
                    ),
                    items: notices
                        .map(
                          (notice) => InkWell(
                            onTap: () {
                              _launchURL(notice!.url!);
                            },
                            child: Container(
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
                              child: Center(
                                child: Text(
                                  notice.text!,
                                  style: TextStyle(
                                    // color: Colors.black,
                                    color: hexToColor(notice.fontColor!),
                                  ),
                                ),
                              ),
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
                      child: Center(
                        child: Text(
                          notices.first!.text!,
                          style: TextStyle(
                            // color: Colors.black,
                            color: hexToColor(notices.first!.fontColor!),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
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

  void _launchURL(String url) async {
    final _url = url;
    if (await canLaunchUrl(Uri.parse(_url))) {
      await launchUrl(Uri.parse(_url));
    } else {
      throw 'Could not launch $_url';
    }
  }
}

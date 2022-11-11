import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/feature/dashboard/hitmap/heatmap.dart';
import 'package:focus42/widgets/desktop_header.dart';
import 'package:focus42/widgets/line.dart';

// ignore: use_key_in_widget_constructors
class DashboardScreen extends ConsumerStatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletSize = screenWidth < 1200 ? true : false;
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(//페이지 전체 구성
            children: <Widget>[
          DesktopHeader(),
          const Line(),
          Container(
            child: Heatmap(),
          ),
        ]),
      ),
    ));
  }
}

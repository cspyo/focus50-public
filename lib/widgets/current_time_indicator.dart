import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';

class CurrentTimeIndicator extends StatefulWidget {
  CurrentTimeIndicator({Key? key}) : super(key: key);

  @override
  State<CurrentTimeIndicator> createState() => _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends State<CurrentTimeIndicator> {
  final curretTime = DateTime.now();
  int tabletBoundSize = 1200;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletSize = screenWidth < tabletBoundSize ? true : false;
    return Container(
      width: isTabletSize ? (screenWidth - 49) / 7 : (screenWidth - 570) / 7,
      height: 1000,
      decoration: new BoxDecoration(color: highlighterColor),
      child: Text(''),
    );
  }
}

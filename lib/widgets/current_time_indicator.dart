import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';

class CurrentTimeIndicator extends StatefulWidget {
  CurrentTimeIndicator({Key? key}) : super(key: key);

  @override
  State<CurrentTimeIndicator> createState() => _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends State<CurrentTimeIndicator> {
  final curretTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: ((screenWidth - 482) / 7),
      height: 1000,
      decoration: new BoxDecoration(color: purple100.withOpacity(0.5)),
      child: Text(''),
    );
  }
}

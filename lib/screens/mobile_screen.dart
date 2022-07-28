import 'package:flutter/material.dart';

class MobileScreen extends StatelessWidget {
  const MobileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Container(
            width: 240,
            height: 240,
            child: Image.asset('assets/images/sorry.png')),
        Text('아쉽지만 아직 모바일은 지원하지 않습니다. 죄송합니다.',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600)),
      ],
    ));
  }
}

import 'package:flutter/material.dart';

import '../consts/colors.dart';

class Line extends StatelessWidget {
  const Line({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.5,
      color: border100,
    );
  }
}

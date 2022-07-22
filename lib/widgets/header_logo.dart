import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Text(
          'Focus',
          style: TextStyle(
            fontFamily: 'Okddung',
            fontSize: 30,
            color: Colors.black,
          ),
        ),
        Text(
          '50',
          style: TextStyle(
            fontFamily: 'Okddung',
            fontSize: 30,
            color: purple300,
          ),
        ),
      ],
    );
  }
}

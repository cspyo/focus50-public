import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:get/get.dart';

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.rootDelegate.toNamed(Routes.ABOUT);
      },
      child: Row(
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
      ),
    );
  }
}
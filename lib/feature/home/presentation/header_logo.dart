import 'package:flutter/material.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/consts/routes.dart';
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text(
            'Focus',
            style: TextStyle(
              fontFamily: 'Okddung',
              fontSize: 30,
              color: Colors.black,
              // fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '50',
            style: TextStyle(
              fontFamily: 'Okddung',
              fontSize: 30,
              color: purple300,
              // fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

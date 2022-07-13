import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:get/get.dart';

class DesktopHeader extends StatefulWidget {
  DesktopHeader({Key? key}) : super(key: key);

  @override
  State<DesktopHeader> createState() => _DesktopHeaderState();
}

class _DesktopHeaderState extends State<DesktopHeader> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return // 데스크탑 헤더
        Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
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
          Row(
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    Get.rootDelegate.toNamed(Routes.ABOUT);
                  },
                  child: const Text('소개',
                      style: TextStyle(fontSize: 17, color: Colors.black))),
              SizedBox(width: 10),
              TextButton(
                  onPressed: () {
                    Get.rootDelegate.toNamed(Routes.CALENDAR);
                  },
                  child: const Text('캘린더',
                      style: TextStyle(fontSize: 17, color: Colors.black))),
              SizedBox(width: 10),
              (_auth.currentUser != null)
                  ? TextButton(
                      onPressed: () {
                        Get.rootDelegate.toNamed(Routes.PROFILE);
                      },
                      child: const Text('마이페이지',
                          style: TextStyle(fontSize: 17, color: Colors.black)))
                  : Container(),
              SizedBox(width: 10),
              (_auth.currentUser != null)
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: purple300,
                      ),
                      onPressed: () {
                        setState(() {
                          _auth.signOut();
                        });

                        Get.rootDelegate.toNamed(Routes.LOGIN);
                      },
                      child: const Text(
                        '  로그아웃  ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        primary: purple300,
                      ),
                      onPressed: () {
                        Get.rootDelegate.toNamed(Routes.SIGNUP);
                      },
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
              (_auth.currentUser != null) ? Container() : SizedBox(width: 20),
              (_auth.currentUser != null)
                  ? Container()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: purple300,
                      ),
                      onPressed: () {
                        Get.rootDelegate.toNamed(Routes.LOGIN);
                      },
                      child: const Text(
                        '  로그인  ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
    //header
  }
}

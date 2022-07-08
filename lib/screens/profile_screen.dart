import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../consts/colors.dart';
import '../consts/routes.dart';
import '../widgets/line.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Calendar'),
        // ),
        body: Column(children: <Widget>[
      // 데스크탑 헤더
      Container(
        padding:
            const EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: const <Widget>[
                Text('Focus',
                    style: TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                        color: Colors.black)),
                Text('50',
                    style: TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color: purple300)),
              ],
            ),
            Row(
              children: <Widget>[
                TextButton(
                    onPressed: () {
                      Get.rootDelegate.toNamed(Routes.ABOUT);
                    },
                    child: const Text('About',
                        style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                            color: Colors.black))),
                SizedBox(width: 10),
                TextButton(
                    onPressed: () {
                      Get.rootDelegate.toNamed(Routes.CALENDAR);
                    },
                    child: const Text('Calendar',
                        style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                            color: Colors.black))),
                SizedBox(width: 10),
                TextButton(
                    onPressed: () {
                      Get.rootDelegate.toNamed(Routes.PROFILE);
                    },
                    child: const Text('Profile',
                        style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                            color: Colors.black))),
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
                        child: const Text('  Logout  '),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          primary: purple300,
                        ),
                        onPressed: () {
                          Get.rootDelegate.toNamed(Routes.SIGNUP);
                        },
                        child: const Text('Sign Up')),
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
                        child: const Text('  Log In  '),
                      ),
              ],
            ),
          ],
        ),
      ), //header
      const Line(),
      Container(
        child: Text('profile'),
      )
    ]));
  }
}

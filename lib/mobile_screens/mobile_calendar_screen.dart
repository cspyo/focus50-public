import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/mobile_widgets/mobile_calendar.dart';
import 'package:focus42/mobile_widgets/mobile_reservation.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/auth_method.dart';
import 'package:get/get.dart';

import '../widgets/line.dart';

// ignore: use_key_in_widget_constructors
class MobileCalendarScreen extends StatefulWidget {
  MobileCalendarScreen({Key? key}) : super(key: key);
  @override
  State<MobileCalendarScreen> createState() => _MobileCalendarScreenState();
}

class _MobileCalendarScreenState extends State<MobileCalendarScreen> {
  int remainingTime = 0;

  DateTime now = new DateTime.now();

  String fastReservation = '10시';

  DateTime fastestReservation =
      new DateTime.fromMicrosecondsSinceEpoch(10000000000000000);
  final _auth = FirebaseAuth.instance;
  final _authMethods = new AuthMethods();
  bool isUserDifferentImg = false;
  String userPhotoUrl =
      'https://firebasestorage.googleapis.com/v0/b/focus50-8b405.appspot.com/o/profilePics%2Fuser.png?alt=media&token=f3d3b60c-55f8-4576-bfab-e219d9c225b3';
  String userNickname = '';
  String userJob = '';

  Future<void> getUserData() async {
    UserPublicModel user =
        await AuthMethods().getUserPublic(_auth.currentUser!.uid);
    userNickname = user.nickname!;
    userJob = user.job!;
    setState(() {
      if (userPhotoUrl != user.photoUrl) {
        userPhotoUrl = user.photoUrl!;
        isUserDifferentImg = true;
      } else {
        isUserDifferentImg = false;
      }
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: purple300),
        ),
        drawer: Drawer(
          backgroundColor: purple300,
          child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                SizedBox(
                  height: 20,
                ),
                _auth.currentUser?.uid == null
                    ? Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Get.rootDelegate.toNamed(Routes.LOGIN);
                          },
                          child: const Text(
                            '로그인 해주세요',
                            style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 60,
                        child: isUserDifferentImg
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                    Image.network(userPhotoUrl),
                                    SizedBox(width: 20),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(userNickname,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.left),
                                        Text(
                                          userJob,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.left,
                                        )
                                      ],
                                    )
                                  ])
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                    Image.asset(
                                        'assets/images/default_profile.png'),
                                    SizedBox(width: 20),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(userNickname,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.left),
                                        Text(
                                          userJob,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.left,
                                        )
                                      ],
                                    )
                                  ])
                        // : Container(
                        //     alignment: Alignment.center,
                        //     width: 20,
                        //     height: 20,
                        //     child:
                        //         CircularProgressIndicator(color: Colors.white)),
                        ),
                SizedBox(
                  height: 10,
                ),
                buildMenuItem(
                    text: 'About',
                    icon: Icons.waving_hand,
                    route: Routes.ABOUT),
                SizedBox(
                  height: 10,
                ),
                buildMenuItem(
                    text: 'Calendar',
                    icon: Icons.calendar_month,
                    route: Routes.CALENDAR),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.white,
                  thickness: 1,
                ),
                SizedBox(
                  height: 20,
                ),
                (_auth.currentUser != null)
                    ? SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            setState(() {
                              _authMethods.signOut();
                            });
                            Get.rootDelegate.toNamed(Routes.LOGIN);
                          },
                          child: const Text(
                            '  로그아웃  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: purple300,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Get.rootDelegate.toNamed(Routes.SIGNUP);
                          },
                          child: const Text(
                            '  회원가입  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: purple300,
                            ),
                          ),
                        ),
                      ),
                SizedBox(
                  height: 10,
                ),
                (_auth.currentUser != null)
                    ? Container()
                    : SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: purple300,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.white,
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Get.rootDelegate.toNamed(Routes.LOGIN);
                          },
                          child: const Text(
                            '  로그인  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ]),
        ),
        body: SingleChildScrollView(
          child: Column(//페이지 전체 구성
              children: <Widget>[
            const Line(),
            Column(children: <Widget>[
              Container(
                child: MobileReservation(),
              ),
              Container(
                child: MobileCalendar(),
              )
            ])
          ]),
        ));
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    required String route,
  }) {
    final color = Colors.white;
    return ListTile(
        leading: Icon(icon, color: color),
        onTap: () {
          Get.rootDelegate.toNamed(route);
        },
        title: Text(
          text,
          style: TextStyle(color: color),
        ));
  }
}

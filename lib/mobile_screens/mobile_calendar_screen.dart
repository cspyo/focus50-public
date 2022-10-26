import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/auth/auth_view_model.dart';
import 'package:focus42/feature/auth/presentation/login_dialog.dart';
import 'package:focus42/feature/auth/presentation/sign_up_dialog.dart';
import 'package:focus42/mobile_widgets/mobile_calendar.dart';
import 'package:focus42/mobile_widgets/mobile_reservation.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/storage_method.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/view_models.dart/users_notifier.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/line.dart';

class MobileCalendarScreen extends ConsumerStatefulWidget {
  MobileCalendarScreen({Key? key}) : super(key: key);
  @override
  _MobileCalendarScreenState createState() => _MobileCalendarScreenState();
}

class _MobileCalendarScreenState extends ConsumerState<MobileCalendarScreen> {
  bool getUserInfo = false;
  String userPhotoUrl = StorageMethods.defaultImageUrl;
  String userNickname = '';
  bool isNotificationOpen = true;
  final Uri toLaunch = Uri(
    scheme: 'https',
    host: 'forms.gle',
    path: '/3bGecKhsiAwtyk4k9',
  );
  CalendarController calendarController = CalendarController();

  Future<void> _showLoginDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return LoginDialog();
      },
    );
  }

  Future<void> _showSignUpDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SignUpDialog();
      },
    );
  }

  Future<void> getUserData() async {
    final usersNotifier = ref.read(usersProvider.notifier);
    final database = ref.read(databaseProvider);
    final auth = ref.read(firebaseAuthProvider);
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      if (!usersNotifier.containsKey(uid)) {
        UserPublicModel user = await database.getUserPublic(othersUid: uid);
        usersNotifier.addAll({uid: user});
      }
      final users = ref.read(usersProvider);
      userPhotoUrl = users[uid]!.photoUrl!;
      userNickname = users[uid]!.nickname!;
      setState(() {
        getUserInfo = true;
      });
    }
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final authState = ref.watch(authStateChangesProvider).asData?.value;

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
                authState == null
                    ? Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            _showLoginDialog();
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
                        child: getUserInfo
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
                                      ],
                                    )
                                  ])),
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
                (authState != null)
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
                            ref.read(authViewModelProvider).signOut();
                            setState(() {});
                            AnalyticsMethod().mobileLogSignOut();
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
                            _showSignUpDialog();
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
                (authState != null)
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
                            _showLoginDialog();
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
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: border100)),
                  height: screenHeight - 165,
                  child: Column(
                    children: [
                      MobileCalendar(
                        calendarController: calendarController,
                        isNotificationOpen: isNotificationOpen,
                      ),
                    ],
                  )),
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

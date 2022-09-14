import 'package:focus42/consts/routes.dart';
import 'package:focus42/mobile_screens/mobile_about_screen.dart';
// import 'package:focus42/m.screens/m.profile_screen.dart';
import 'package:focus42/mobile_screens/mobile_add_profile_screen.dart';
import 'package:focus42/mobile_screens/mobile_calendar_screen.dart';
import 'package:focus42/mobile_screens/mobile_login_screen.dart';
import 'package:focus42/mobile_screens/mobile_session_screen.dart';
import 'package:focus42/mobile_screens/mobile_signup_screen.dart';
import 'package:focus42/screens/add_profile_screen.dart';
import 'package:focus42/screens/calendar_screen.dart';
import 'package:focus42/screens/profile_screen.dart';
import 'package:focus42/screens/session_screen.dart';
import 'package:get/get.dart';

import '../screens/about_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';

abstract class AppPages {
  static final pcPages = [
    GetPage(
      name: Routes.ABOUT,
      page: () => AboutScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignUpScreen(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: Routes.ADD_PROFILE,
      page: () => AddProfileScreen(),
    ),
    GetPage(
      name: Routes.CALENDAR,
      page: () => CalendarScreen(),
    ),
    GetPage(
      name: Routes.SESSION,
      page: () => SessionScreen(
        session: Get.rootDelegate.arguments(),
      ),
    ),
  ];
  static final mobilePages = [
    GetPage(
      name: Routes.ABOUT,
      page: () => MobileAboutScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => MobileLoginScreen(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => MobileSignUpScreen(),
    ),
    // GetPage(
    //   name: Routes.PROFILE,
    //   page: () => MobileProfileScreen(),
    // ),
    GetPage(
      name: Routes.ADD_PROFILE,
      page: () => MobileAddProfileScreen(),
    ),
    GetPage(
      name: Routes.CALENDAR,
      page: () => MobileCalendarScreen(),
    ),
    GetPage(
      name: Routes.SESSION,
      page: () => MobileSessionScreen(
        session: Get.rootDelegate.arguments(),
      ),
    ),
  ];
}

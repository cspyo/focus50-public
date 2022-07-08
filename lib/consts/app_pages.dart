import 'package:focus42/consts/routes.dart';
import 'package:focus42/screens/add_profile_screen.dart';
import 'package:focus42/screens/calendar_screen.dart';
import 'package:focus42/screens/profile_screen.dart';
import 'package:focus42/screens/session_screen.dart';
import 'package:get/get.dart';

import '../screens/about_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';

abstract class AppPages {
  static final pages = [
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
        session: Get.arguments,
      ),
    ),
  ];
}

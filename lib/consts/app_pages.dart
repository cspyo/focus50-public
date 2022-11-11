import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/dashboard/presentation/dashboard_screen.dart';
import 'package:focus42/feature/jitsi/presentation/meeting_screen.dart';
import 'package:focus42/feature/profile/presentation/profile_screen.dart';
import 'package:focus42/mobile_screens/mobile_about_screen.dart';
// import 'package:focus42/m.screens/m.profile_screen.dart';
import 'package:focus42/mobile_screens/mobile_calendar_screen.dart';
import 'package:focus42/mobile_screens/mobile_meeting_screen.dart';
import 'package:focus42/mobile_screens/mobile_profile_screen.dart';
import 'package:focus42/screens/calendar_screen.dart';
import 'package:get/get.dart';

import '../screens/about_screen.dart';

abstract class AppPages {
  static final pcPages = [
    GetPage(
      name: Routes.ABOUT,
      page: () => AboutScreen(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: Routes.CALENDAR,
      page: () => CalendarScreen(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardScreen(),
    ),
    GetPage(
      name: Routes.MEET,
      page: () => MeetingScreen(
        reservation: Get.rootDelegate.arguments(),
      ),
    ),
  ];
  static final mobilePages = [
    GetPage(
      name: Routes.ABOUT,
      page: () => MobileAboutScreen(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => MobileProfileScreen(),
    ),
    GetPage(
      name: Routes.CALENDAR,
      page: () => MobileCalendarScreen(),
    ),
    GetPage(
      name: Routes.MEET,
      page: () => MobileMeetingScreen(
        reservation: Get.rootDelegate.arguments(),
      ),
    ),
  ];
}

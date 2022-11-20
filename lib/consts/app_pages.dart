import 'package:focus50/consts/routes.dart';
import 'package:focus50/feature/about/presentation/mobile/mobile_about_screen.dart';
import 'package:focus50/feature/calendar/presentation/calendar_screen.dart';
import 'package:focus50/feature/calendar/presentation/mobile/mobile_calendar_screen.dart';
import 'package:focus50/feature/jitsi/presentation/meeting_screen.dart';
import 'package:focus50/feature/jitsi/presentation/mobile_meeting_screen.dart';
import 'package:focus50/feature/profile/presentation/mobile/mobile_profile_screen.dart';
import 'package:focus50/feature/profile/presentation/profile_screen.dart';
import 'package:get/get.dart';

import '../feature/about/presentation/about_screen.dart';

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
      name: Routes.GROUPCALENDAR,
      page: () => CalendarScreen(),
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
      name: Routes.GROUPCALENDAR,
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

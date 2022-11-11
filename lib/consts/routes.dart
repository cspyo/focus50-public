abstract class Routes {
  static const ABOUT = '/';
  static const PROFILE = '/profile';
  static const CALENDAR = '/calendar';
  static const MEET = '/meet';
  static const DASHBOARD = '/dashboard';
}

class DynamicRoutes {
  static String CALENDAR({String? groupId}) =>
      groupId != null ? '/calendar/$groupId' : '/calendar';
}

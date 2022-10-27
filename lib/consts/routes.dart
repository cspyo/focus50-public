abstract class Routes {
  static const ABOUT = '/';
  static const PROFILE = '/profile';
  static const CALENDAR = '/calendar';
  static const GROUPCALENDAR = '/calendar/:groupId';
  static const SESSION = '/session';
  static const MEET = '/meet';
}

class DynamicRoutes {
  static String CALENDAR({String? groupId}) =>
      groupId != null ? '/calendar/$groupId' : '/calendar';
}

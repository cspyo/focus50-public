import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsMethod {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future logPageView(String pageName) async {
    await analytics
        .logEvent(name: "page-view", parameters: {"page_name": pageName});
  }

  Future logLogin(String loginMethod) async {
    await analytics.logLogin(loginMethod: loginMethod);
  }

  Future logCreateProfile() async {
    await analytics.logEvent(name: "create_profile");
  }

  Future logSignUp(String signUpMethod) async {
    await analytics.logSignUp(signUpMethod: signUpMethod);
  }

  Future logSignOut() async {
    await analytics.logEvent(name: "sign_out");
  }

  Future setUserAgent(String userAgent) async {
    await analytics.setUserProperty(name: 'user_agent', value: userAgent);
  }

  Future setUserProperty(String name, String value) async {
    await analytics.setUserProperty(name: name, value: value);
  }

  Future logUserAgent(String userAgent) async {
    await analytics.logEvent(
        name: "log_user_agent", parameters: {"user_agent": userAgent});
  }

  Future logCalendarTapDateBefore() async {
    await analytics.logEvent(name: "calendar_tap_date_before");
  }

  Future logMakeReservationOnEmpty() async {
    await analytics.logEvent(name: "make_reservation_on_empty");
  }

  Future logMakeReservationOnSomeone() async {
    await analytics.logEvent(name: "make_reservation_on_someone");
  }

  Future logCancelReservation() async {
    await analytics.logEvent(name: "cancel_reservation");
  }

  Future logEnterSession() async {
    await analytics.logEvent(name: "enter_session");
  }

  Future logMakeTodoInSession() async {
    await analytics.logEvent(name: "make_todo_session");
  }

  Future logMakeTodoInCalendar() async {
    await analytics.logEvent(name: "make_todo_calendar");
  }

  Future logMicOn() async {
    await analytics.logEvent(name: "mic_on");
  }

  Future logMicOff() async {
    await analytics.logEvent(name: "mic_off");
  }

  Future logCameraOn() async {
    await analytics.logEvent(name: "camera_on");
  }

  Future logCameraOff() async {
    await analytics.logEvent(name: "camera_off");
  }

  Future logPressExitButton() async {
    await analytics.logEvent(name: "press_exit");
  }
}

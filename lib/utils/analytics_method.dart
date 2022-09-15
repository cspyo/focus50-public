import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsMethod {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future logPageView(String pageName) async {
    await analytics
        .logEvent(name: "page-view", parameters: {"page_name": pageName});
  } //X

  Future logLogin(String loginMethod) async {
    await analytics.logLogin(loginMethod: loginMethod);
  } //O

  Future logCreateProfile() async {
    await analytics.logEvent(name: "create_profile");
  } //O

  Future logSignUp(String signUpMethod) async {
    await analytics.logSignUp(signUpMethod: signUpMethod);
  } //O

  Future logSignOut() async {
    await analytics.logEvent(name: "sign_out");
  } //O

  Future setUserAgent(String userAgent) async {
    await analytics.setUserProperty(name: 'user_agent', value: userAgent);
  } //O

  Future setUserProperty(String name, String value) async {
    await analytics.setUserProperty(name: name, value: value);
  } //X

  Future logUserAgent(String userAgent) async {
    await analytics.logEvent(
        name: "log_user_agent", parameters: {"user_agent": userAgent});
  } //O

  Future logCalendarTapWithoutSignIn() async {
    await analytics.logEvent(name: "calendar_tap_without_signin");
  } //O

  Future logCalendarTapWithoutProfile() async {
    await analytics.logEvent(name: "mobile_calendar_tap_without_profile");
  } //O

  Future logCalendarTapDateBefore() async {
    await analytics.logEvent(name: "calendar_tap_date_before");
  } //O

  Future logMakeReservationOnEmpty() async {
    await analytics.logEvent(name: "make_reservation_on_empty");
  } //O

  Future logMakeReservationOnSomeone() async {
    await analytics.logEvent(name: "make_reservation_on_someone");
  } //X

  Future logCancelReservation() async {
    await analytics.logEvent(name: "cancel_reservation");
  } //O

  Future logEnterSession() async {
    await analytics.logEvent(name: "enter_session");
  } //O

  Future logMakeTodoInSession() async {
    await analytics.logEvent(name: "make_todo_session");
  } //O

  Future logMakeTodoInCalendar() async {
    await analytics.logEvent(name: "make_todo_calendar");
  } //O

  Future logMicOn() async {
    await analytics.logEvent(name: "mic_on");
  } //O

  Future logMicOff() async {
    await analytics.logEvent(name: "mic_off");
  } //O

  Future logCameraOn() async {
    await analytics.logEvent(name: "camera_on");
  } //O

  Future logCameraOff() async {
    await analytics.logEvent(name: "camera_off");
  } //O

  Future logPressExitButton() async {
    await analytics.logEvent(name: "press_exit");
  } //O

  Future mobileLogPageView(String pageName) async {
    await analytics.logEvent(
        name: "mobile-page-view", parameters: {"page_name": pageName});
  } //X

  Future mobileLogLogin(String loginMethod) async {
    await analytics.logLogin(loginMethod: loginMethod);
  } //O

  Future mobileLogCreateProfile() async {
    await analytics.logEvent(name: "mobile_create_profile");
  } //O

  Future mobileLogSignUp(String signUpMethod) async {
    await analytics.logSignUp(signUpMethod: signUpMethod);
  } //O

  Future mobileLogSignOut() async {
    await analytics.logEvent(name: "mobile_sign_out");
  } //O

  Future mobileLogCalendarTapWithoutSignIn() async {
    await analytics.logEvent(name: "mobile_calendar_tap_without_signin");
  } //O

  Future mobileLogCalendarTapWithoutProfile() async {
    await analytics.logEvent(name: "mobile_calendar_tap_without_profile");
  } //O

  Future mobileLogCalendarTapDateBefore() async {
    await analytics.logEvent(name: "mobile_calendar_tap_date_before");
  } //O

  Future mobileLogMakeReservationOnEmpty() async {
    await analytics.logEvent(name: "mobile_make_reservation_on_empty");
  } //O

  Future mobileLogMakeReservationOnSomeone() async {
    await analytics.logEvent(name: "mobile_make_reservation_on_someone");
  } //X

  Future mobileLogCancelReservation() async {
    await analytics.logEvent(name: "mobile_cancel_reservation");
  } //O

  Future mobileLogEnterSession() async {
    await analytics.logEvent(name: "mobile_enter_session");
  } //O

  Future mobileLogMakeTodoInSession() async {
    await analytics.logEvent(name: "mobile_make_todo_session");
  } //X

  Future mobileLogMakeTodoInCalendar() async {
    await analytics.logEvent(name: "mobile_make_todo_calendar");
  } //X

  Future mobileLogMicOn() async {
    await analytics.logEvent(name: "mobile_mic_on");
  } //O

  Future mobileLogMicOff() async {
    await analytics.logEvent(name: "mobile_mic_off");
  } //O

  Future mobileLogCameraOn() async {
    await analytics.logEvent(name: "mobile_camera_on");
  } //O

  Future mobileLogCameraOff() async {
    await analytics.logEvent(name: "mobile_camera_off");
  } //O

  Future mobileLogPressExitButton() async {
    await analytics.logEvent(name: "mobile_press_exit");
  } //O
}

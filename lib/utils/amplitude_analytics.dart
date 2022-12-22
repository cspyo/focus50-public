import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus50/options.dart';
import 'package:focus50/services/firestore_database.dart';
import 'package:universal_html/html.dart' as html;

class AmplitudeAnalytics {
  late final Amplitude analytics;
  late final String agent;

  String username = "none";

  String APIKey = Options.amplitudeApiKey;

  AmplitudeAnalytics._privateConstructor() {
    analytics = Amplitude.getInstance();
    analytics.init(APIKey);
    analytics.enableCoppaControl();
    analytics.trackingSessionEvents(true);

    String userAgent = html.window.navigator.userAgent.toString().toLowerCase();
    if (userAgent.contains("iphone") || userAgent.contains("android")) {
      agent = "mobile";
    } else {
      agent = "web";
    }
  }

  static final AmplitudeAnalytics _instance =
      AmplitudeAnalytics._privateConstructor();

  factory AmplitudeAnalytics() {
    return _instance;
  }

  bool isLogin() {
    return FirebaseAuth.instance.currentUser != null;
  }

  void logEvent(String eventName,
      {Map<String, dynamic>? eventProperties}) async {
    if (isLogin() && username == "none") {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      final user = await FirestoreDatabase(uid: uid).getUserPublic();
      username = user.nickname!;
      await analytics.setUserId(uid);
      await analytics
          .setUserProperties({"uid": uid, "nickname": user.nickname});
    }
    analytics.logEvent(eventName, eventProperties: eventProperties);
  }

  // o
  void logClickLogo() {
    logEvent("click logo", eventProperties: {"agent": agent});
  }

  // o
  void logClickAboutNavigator() {
    logEvent("click about screen navigator", eventProperties: {"agent": agent});
  }

  // o
  void logClickCalendarNavigator() {
    logEvent("click calendar screen navigator",
        eventProperties: {"agent": agent});
  }

  // o
  void logClickProfilePopUpButton() {
    logEvent("click profile pop up button", eventProperties: {"agent": agent});
  }

  // o
  void logClickProfileNavigator() {
    logEvent("click profile screen navigator",
        eventProperties: {"agent": agent});
  }

  // o
  void logClickNoticeNavigator() {
    logEvent("click notice screen navigator",
        eventProperties: {"agent": agent});
  }

  // o
  void logClickInquiryNavigator() {
    logEvent("click inquiry screen navigator",
        eventProperties: {"agent": agent});
  }

  // o
  void logClickSignUpButton(String signUpMethod) {
    logEvent("click sign up button",
        eventProperties: {"sign up method": signUpMethod, "agent": agent});
  }

  // o
  void logCompleteSignUp(String signUpMethod) {
    logEvent("complete sign up",
        eventProperties: {"sign up method": signUpMethod, "agent": agent});
  }

  // o
  void logClickCorrectProfileButton() {
    logEvent("click correct profile button", eventProperties: {"agent": agent});
  }

  // o
  void logClickGoToFocusButton() {
    logEvent("click go to focus button", eventProperties: {"agent": agent});
  }

  // o
  void logClickLoginButton(String loginMethod) {
    logEvent("click login button",
        eventProperties: {"login method": loginMethod, "agent": agent});
  }

  // o
  void logCompleteLogin(String loginMethod) {
    logEvent("complete login",
        eventProperties: {"login method": loginMethod, "agent": agent});
  }

  // o
  void logSignOut() {
    logEvent("sign out", eventProperties: {"agent": agent});
  }

  // o
  void logCalendarTapBeforeNow() {
    logEvent("tap calendar before now", eventProperties: {"agent": agent});
  }

  // o
  void logCalendarTapWithoutLogin() {
    logEvent("tap calendar without login", eventProperties: {"agent": agent});
  }

  // o
  void logCalendarTapToReserve() {
    logEvent("tap calendar to reserve", eventProperties: {"agent": agent});
  }

  // o
  void logReserveComplete(
      DateTime startTime, String groupId, String groupName) {
    logEvent("reserve complete", eventProperties: {
      "start time": startTime,
      "group id": groupId,
      "group name": groupName,
      "agent": agent,
    });
  }

  // o
  void logCancelReservation(
      DateTime startTime, String groupId, String groupName) {
    logEvent("cancel reservation", eventProperties: {
      "start time": startTime,
      "group id": groupId,
      "group name": groupName,
      "agent": agent
    });
  }

  // o
  void logEnterSession(DateTime startTime, String groupId, String groupName) {
    logEvent("enter session", eventProperties: {
      "start time": startTime,
      "group id": groupId,
      "group name": groupName,
      "agent": agent
    });
  }

  // o
  void logMakeTodoInSession() {
    logEvent("make todo in session", eventProperties: {"agent": agent});
  }

  // o
  void logAssignTodoInSession() {
    logEvent("assign todo in session", eventProperties: {"agent": agent});
  }

  // o
  void logUnassignTodoInSession() {
    logEvent("unassign todo in session", eventProperties: {"agent": agent});
  }

  // o
  void logCompleteTodoInSession() {
    logEvent("complete todo in session", eventProperties: {"agent": agent});
  }

  // o
  void logUncompleteTodoInSession() {
    logEvent("uncomplete todo in session", eventProperties: {"agent": agent});
  }

  // o
  void logDeleteTodoInSession() {
    logEvent("delete todo in session", eventProperties: {"agent": agent});
  }

  // o
  void logMakeTodoInCalendar() {
    logEvent("make todo in calendar", eventProperties: {"agent": agent});
  }

  // o
  void logToggleTodoList() {
    logEvent("toggle todo list", eventProperties: {"agent": agent});
  }

  // o
  void logClickLogoInSession() {
    logEvent("click logo in session", eventProperties: {"agent": agent});
  }

  // o
  void logClickReportButton() {
    logEvent("click report button", eventProperties: {"agent": agent});
  }

  // o
  void logCompleteReport() {
    logEvent("complete report", eventProperties: {"agent": agent});
  }

  // o
  void logRatingFocus() {
    logEvent("rating focus", eventProperties: {"agent": agent});
  }

  // o
  void logShowTutorial() {
    logEvent("show tutorial", eventProperties: {"agent": agent});
  }

  // o
  void logCompleteTutorial() {
    logEvent("complete tutorial", eventProperties: {"agent": agent});
  }

  // o
  void logClickCarousel(String url) {
    logEvent("show tutorial", eventProperties: {"url": url, "agent": agent});
  }

  // o
  void logForceExitInSession() {
    logEvent("force exit in session", eventProperties: {"agent": agent});
  }

  // o
  void logClickExitButtonDuringSession() {
    logEvent("click exit button during session",
        eventProperties: {"agent": agent});
  }

  // o
  void logClickExitButtonAfterSession() {
    logEvent("click exit button After session",
        eventProperties: {"agent": agent});
  }

  // o
  void logSendPeerFeedback(String feedbackType) {
    logEvent("send peer feedback",
        eventProperties: {"feedback type": feedbackType, "agent": agent});
  }

  // o
  void logClickUploadProfileImageButton() {
    logEvent("click upload profile image button",
        eventProperties: {"agent": agent});
  }

  // o
  void logClickKakaoSyncButton() {
    logEvent("click kakao sync button", eventProperties: {"agent": agent});
  }

  // o
  void logCompleteKakaoSync() {
    logEvent("complete kakao sync", eventProperties: {"agent": agent});
  }

  // o
  void logCompleteUpdateProfile() {
    logEvent("complete update profile", eventProperties: {"agent": agent});
  }

  // o
  void logClickPublicGroupButton() {
    logEvent("click public group button", eventProperties: {"agent": agent});
  }

  // o
  void logClickPrivateGroupButton() {
    logEvent("click private group button", eventProperties: {"agent": agent});
  }

  // o
  void logClickSearchGroupButton() {
    logEvent("click search group button", eventProperties: {"agent": agent});
  }

  // o
  void logClickCreateGroupButton() {
    logEvent("click create group button", eventProperties: {"agent": agent});
  }

  // o
  void logCompleteCreateGroup() {
    logEvent("complete create group", eventProperties: {"agent": agent});
  }

  // o
  void logChangeGroup() {
    logEvent("change group", eventProperties: {"agent": agent});
  }

  // o
  void logSignUpGroup() {
    logEvent("complete sign up group", eventProperties: {"agent": agent});
  }

  // o
  void logCopyGroupLink() {
    logEvent("copy group link", eventProperties: {"agent": agent});
  }

  // o
  void logInviteGroupByLink() {
    logEvent("invite group by link", eventProperties: {"agent": agent});
  }
}

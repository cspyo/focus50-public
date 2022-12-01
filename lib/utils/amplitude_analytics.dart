import 'package:amplitude_flutter/amplitude.dart';

class AmplitudeAnalytics {
  late final Amplitude analytics;
  String APIKey = 'fa192e47c997442220759cf62b71e816';

  AmplitudeAnalytics._privateConstructor() {
    analytics = Amplitude.getInstance();
    analytics.init(APIKey);
    analytics.enableCoppaControl();
    analytics.trackingSessionEvents(true);
  }

  static final AmplitudeAnalytics _instance =
      AmplitudeAnalytics._privateConstructor();

  factory AmplitudeAnalytics() {
    return _instance;
  }

  Future<void> setUserId(String uid) async {
    await analytics.setUserId(uid);
  }

  Future<void> logEvent(String eventName,
      {Map<String, dynamic>? eventProperties}) async {
    await analytics.logEvent(eventName, eventProperties: eventProperties);
  }
}

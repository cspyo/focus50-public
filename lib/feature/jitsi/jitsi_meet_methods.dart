import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:focus42/models/user_model.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class JitsiMeetMethods {
  Future<void> createMeeting({
    required String room,
    required UserModel myAuth,
  }) async {
    final options = _getOptions(room, myAuth);

    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            JitsiMeet.executeCommand("setTileView", []);
            debugPrint("[DEBUG] ${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
  }

  Map<FeatureFlagEnum, bool> _getFeatureFlags() {
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.ADD_PEOPLE_ENABLED: false,
      FeatureFlagEnum.CALENDAR_ENABLED: false,
      FeatureFlagEnum.CALL_INTEGRATION_ENABLED: false,
      FeatureFlagEnum.CLOSE_CAPTIONS_ENABLED: false,
      FeatureFlagEnum.INVITE_ENABLED: false,
      FeatureFlagEnum.IOS_RECORDING_ENABLED: false,
      FeatureFlagEnum.LIVE_STREAMING_ENABLED: false,
      FeatureFlagEnum.MEETING_NAME_ENABLED: false,
      FeatureFlagEnum.MEETING_PASSWORD_ENABLED: false,
      FeatureFlagEnum.RECORDING_ENABLED: false,
      FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE: false,
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
    }

    return featureFlags;
  }

  JitsiMeetingOptions _getOptions(String room, UserModel myAuth) {
    JitsiMeetingOptions options = JitsiMeetingOptions(room: room)
      ..userDisplayName = myAuth.userPublicModel!.nickname ?? "null"
      ..audioMuted = true
      ..videoMuted = false
      ..featureFlags.addAll(_getFeatureFlags())
      ..webOptions = {
        "roomName": room,
        "width": "100%",
        "height": "100%",
        "userInfo": {"displayName": myAuth.userPublicModel!.nickname ?? "null"},
        "configOverwrite": {
          "enableWelcomePage": false,
          "prejoinConfig": {
            "enabled": false,
            "hideDisplayName": true,
          },
          "remoteVideoMenu": {
            "disabled": false,
            "disableKick": true,
          },
          "hideConferenceSubject": true,
          "disableFilmstripAutohiding": true,
          "filmstrip": {
            "disableResizable": true,
            "disableStageFilmstrip": true,
            "stageFilmstripParticipants": 1,
          },
          /* If true, the tiles will be displayed contained within the available space rather than enlarged to cover it,
           * with a 16:9 aspect ratio (old behaviour). */
          "disableTileEnlargement": true,
          /* If true, any checks to handoff to another application will be prevented
           * and instead the app will continue to display in the current browser.*/
          "disableDeepLinking": true,
          "hideConferenceTimer": true,
          "disableSelfViewSettings": true,
          "readOnlyName": true,
          "startWithAudioMuted": true,
          /* Performance setting. reference: https://community.jitsi.org/t/reducing-resource-usage-to-improve-performance-both-client-side-and-server-side/39891 */
          "disableAudioLevels": true,
          "enableLayerSuspension": true,
          "disableH264": true,
          "resolution": 480,
          "constraints": {
            "video": {
              "height": {
                "ideal": 480,
                "max": 480,
              },
            },
          },
        },
        "interfaceConfigOverwrite": {
          "TOOLBAR_BUTTONS": [
            'microphone',
            'camera',
            'select-background',
            'tileview',
          ],
          "SHOW_CHROME_EXTENSION_BANNER": false,
          /* Performance setting. reference: https://community.jitsi.org/t/reducing-resource-usage-to-improve-performance-both-client-side-and-server-side/39891 */
          "DISABLE_FOCUS_INDICATOR": true,
          "DISABLE_DOMINANT_SPEAKER_INDICATOR": true,
          "VIDEO_QUALITY_LABEL_DISABLED": true,
        },
      };

    return options;
  }

  /* roomId 랜덤생성 - ex.focusmaker-1234567890asdfghjkla
  static String _getRandomRoomId() {
    var _random = Random();
    String randomNumber = (_random.nextInt(10000000) + 10000000).toString();

    _random = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    String randomString = String.fromCharCodes(Iterable.generate(
        10, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));

    final String roomId = "focusmaker-" + randomNumber + randomString;
    print("roomId: ${roomId}");
    return roomId;
  }
  */
}

import 'dart:html';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/consts/app_pages.dart';
import 'package:focus50/consts/app_router_delegate.dart';
import 'package:focus50/firebase_options.dart';
import 'package:focus50/services/firestore_database.dart';
import 'package:focus50/top_level_providers.dart';
import 'package:focus50/utils/amplitude_analytics.dart';
import 'package:focus50/utils/version_compare.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_strategy/url_strategy.dart';

const String VERSION = "1.11.1";
late final AGENT;

Future<void> versionCheck() async {
  const version = VERSION;
  final remoteVersionStream = await FirestoreDatabase(uid: "none").getVersion();
  remoteVersionStream.listen((v) {
    if (version.isLessThan(v)) {
      html.window.location.reload();
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: '1a793b7dbc55cd4e80c9971c6c5bdc6e',
    javaScriptAppKey: '47caa6871b9758b5895998565adcb42b',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool isMobile = false;
  if (kIsWeb) {
    String userAgent = html.window.navigator.userAgent.toString().toLowerCase();
    AGENT = userAgent;
    // smartphones
    if (userAgent.contains("iphone") || userAgent.contains("android")) {
      isMobile = true;
    }
    await FirebaseAuth.instance.authStateChanges().first;
  }
  AmplitudeAnalytics().logEvent("in session");
  setPathUrlStrategy();
  runApp(ProviderScope(child: MyApp(isMobile)));
}

class MyApp extends ConsumerWidget {
  // This widget is the root of your application.
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  bool isMobile = false;
  MyApp(this.isMobile);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    versionCheck();
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    int screenWidth = window.screen!.width!;

    return GetMaterialApp.router(
      title: "Focus50 - 스탠포드 행동설계 연구에 입각한 집중향상 캠스터디",
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'IBMPlexSans',
      ),
      defaultTransition: Transition.noTransition,
      getPages: isMobile && screenWidth < 560
          ? AppPages.mobilePages
          : AppPages.pcPages,
      routerDelegate: AppRouterDelegate(),
    );
  }
}

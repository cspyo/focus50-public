import 'dart:html';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/app_pages.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_strategy/url_strategy.dart';

import 'consts/app_router_delegate.dart';
import 'firebase_options.dart';

const String VERSION = "1.6.1";

Future<void> versionCheck(FirestoreDatabase databse) async {
  const version = VERSION;
  final remoteVersionStream = await databse.getVersion();
  remoteVersionStream.listen((v) {
    print("[DEBUG] stream listen $v");
    if (version != v) {
      html.window.location.reload();
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool isMobile = false;
  if (kIsWeb) {
    String userAgent = html.window.navigator.userAgent.toString().toLowerCase();
    AnalyticsMethod().logUserAgent(userAgent);
    AnalyticsMethod().setUserAgent(userAgent);
    // smartphones
    if (userAgent.contains("iphone") || userAgent.contains("android")) {
      isMobile = true;
    }
    await FirebaseAuth.instance.authStateChanges().first;
  }
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
    final databse = ref.watch(databaseProvider);
    versionCheck(databse);

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

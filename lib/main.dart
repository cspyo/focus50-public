import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/app_pages.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_strategy/url_strategy.dart';

import 'consts/app_router_delegate.dart';
import 'firebase_options.dart';

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
    // smartphone
    if (userAgent.contains("iphone") || userAgent.contains("android")) {
      isMobile = true;
    }
    await FirebaseAuth.instance.authStateChanges().first;
  }
  setPathUrlStrategy();
  runApp(MyApp(isMobile));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  bool isMobile = false;
  MyApp(this.isMobile);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: "Focus50",
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'IBMPlexSans',
      ),
      defaultTransition: Transition.noTransition,
      getPages: isMobile ? AppPages.mobilePages : AppPages.pcPages,
      routerDelegate: AppRouterDelegate(),
    );
  }
}

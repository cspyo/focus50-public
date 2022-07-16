import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/app_pages.dart';
import 'package:get/get.dart';

import 'consts/app_router_delegate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    await FirebaseAuth.instance.authStateChanges().first;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'IBMPlexSans',
      ),
      defaultTransition: Transition.noTransition,
      getPages: AppPages.pages,
      routerDelegate: AppRouterDelegate(),
      // routes: {
      //   '/': (context) => AboutScreen(),
      //   '/calendar': (context) => CalendarScreen(),
      //   '/profile': (context) => ProfileScreen(),
      //   '/login': (context) => LoginScreen(),
      //   '/signup': (context) => SignUpScreen(),
      //   '/addProfile': (context) => AddProfileScreen(),
      // '/session': (context) => SessionScreen(),
      // },
    );
  }
}

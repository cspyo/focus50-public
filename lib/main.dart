// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:focus42/screens/about_screen.dart';
import 'package:focus42/screens/calendar_screen.dart';
import 'package:focus42/screens/login_screen_demo.dart';
import 'package:focus42/screens/profile_screen.dart';

import 'firebase_options.dart';
import 'screens/add_profile_screen.dart';
import 'screens/signup_email_screen.dart';

// FirebaseFirestore firestore = FirebaseFirestore.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: new ThemeData(scaffoldBackgroundColor: Colors.white),
      routes: {
        '/': (context) => AboutScreen(),
        '/calendar': (context) => CalendarScreen(),
        '/profile': (context) => ProfileScreen(),
        '/login': (context) => LoginScreenDemo(),
        '/signup': (context) => SignupEmailScreen(),
        '/addProfile': (context) => AddProfileScreen(),
        // '/session': (context) => SessionScreen(),
      },
    );
  }
}

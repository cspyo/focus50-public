// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:focus42/screens/about_screen.dart';
import 'package:focus42/screens/calendar_screen.dart';
import 'package:focus42/screens/login_screen.dart';
import 'package:focus42/screens/profile_screen.dart';
import 'package:focus42/screens/session_screen.dart';
import 'package:focus42/screens/signup_screen.dart';

import 'firebase_options.dart';

// FirebaseFirestore firestore = FirebaseFirestore.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// CollectionReference users = FirebaseFirestore.instance.collection('users');
// Future<void> addUser() {
//   // Call the user's CollectionReference to add a new user
//   return users
//       .add({
//         'full_name': 'HwangJaewon', // John Doe
//         'company': 'Soma', // Stokes and Sons
//         'age': 21 // 42
//       })
//       .then((value) => print("User Added"))
//       .catchError((error) => print("Failed to add user: $error"));
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AboutScreen(),
        '/calendar': (context) => CalendarScreen(),
        '/profile': (context) => ProfileScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/session': (context) => SessionScreen(),
      },
      // title: "focus42",
      // home: Scaffold(
      //   appBar: AppBar(
      //     title: Text('MaterialApp'),
      //     centerTitle: true,
      //   ),
      //   body: Center(
      //     child: TextButton(
      //       onPressed: addUser,
      //       child: Text('add user'),
      //     ),
      //   ),
      // )
    );
  }
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/desktop_header.dart';
import '../widgets/line.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State createState() => LogInState();
}

class LogInState extends State<LoginScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await auth.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  getCurrentUser() async {
    final userCredential = await signInWithGoogle();
    print(userCredential.user?.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      DesktopHeader(), //header
      const Line(),
      Container(
          //child: ElevatedButton(child: ),
          )
    ]));
  }
}

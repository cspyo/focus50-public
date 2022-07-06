import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';

import '../widgets/line.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      // 데스크탑 헤더
      Container(
        padding:
            const EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: const <Widget>[
                Text('Focus',
                    style: TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                        color: Colors.black)),
                Text('50',
                    style: TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color: purple300)),
              ],
            ),
            Row(
              children: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: const Text('About',
                        style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                            color: Colors.black))),
                SizedBox(width: 10),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/calendar');
                    },
                    child: const Text('Calendar',
                        style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                            color: Colors.black))),
                SizedBox(width: 10),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: const Text('Profile',
                        style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                            color: Colors.black))),
                SizedBox(width: 10),
                (_auth.currentUser != null)
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: purple300,
                        ),
                        onPressed: () {
                          setState(() {
                            _auth.signOut();
                          });
                          print(_auth.currentUser);
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text('  Logout  '),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          primary: purple300,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text('Sign Up')),
                (_auth.currentUser != null) ? Container() : SizedBox(width: 20),
                (_auth.currentUser != null)
                    ? Container()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: purple300,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text('  Log In  '),
                      ),
              ],
            ),
          ],
        ),
      ), //header, //header
      const Line(),
      Container(
        child: Text('about'),
      )
    ]));
  }
}

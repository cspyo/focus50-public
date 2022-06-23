import 'package:flutter/material.dart';

import '../consts/colors.dart';

class desktopheader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                  Text('42',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                          color: purple300)),
                ],
              ),
              Row(children: <Widget>[
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
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      primary: purple300,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Login')),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: purple300,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Sign Up'),
                )
              ])
            ]));
  }
}

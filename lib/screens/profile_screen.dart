import 'package:flutter/material.dart';

import '../widgets/desktop_header.dart';
import '../widgets/line.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Calendar'),
        // ),
        body: Column(children: <Widget>[
          desktopheader(), //header
          const Line(),
          Container(
            child: Text('profile'),
          )
      
    ]));
  }
}

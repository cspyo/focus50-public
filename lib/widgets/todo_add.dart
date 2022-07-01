import 'package:flutter/material.dart';

class TodoAdd extends StatelessWidget {
  const TodoAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 9),
        width: 380,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(width: 100, child: TextField()));
  }
}

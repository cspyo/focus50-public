import 'package:flutter/material.dart';

import '../consts/colors.dart';

class TodoList extends StatelessWidget {
  final String textContent;
  final bool isFinished;
  const TodoList({required this.textContent, required this.isFinished});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 9),
        width: 380,
        height: 60,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                spreadRadius: 0,
                blurRadius: 4,
                offset: Offset(0, 6),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 1.5,
              color: border100,
            )),
        child: Container(
          child: Row(
            children: [
              TextButton(
                  onPressed: () {},
                  child: !isFinished
                      ? Icon(Icons.radio_button_unchecked, color: Colors.black)
                      : Icon(Icons.radio_button_checked, color: Colors.black)),
              Text(textContent),
            ],
          ),
        ));
  }
}

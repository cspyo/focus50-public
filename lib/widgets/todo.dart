import 'package:flutter/material.dart';

import '../widgets/todo_add.dart';
// import 'package:focus42/consts/colors.dart';
import '../widgets/todo_list.dart';
// import 'package:todo/todo.dart';

// ignore: camel_case_types
class Todo extends StatefulWidget {
  @override
  TodoState createState() => TodoState();
}

class TodoState extends State<Todo> {
  // int buttonClick = 0;
  // bool isAdd = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 27),
      width: 380,
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text('Todo',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 32,
                          fontWeight: FontWeight.w600))),
              IconButton(
                  onPressed: () {
                    // buttonClick++;
                  },
                  iconSize: 30,
                  hoverColor: Colors.transparent,
                  icon: Icon(
                    Icons.add,
                    color: Colors.black,
                  )),
            ],
          ),
        ),
        TodoAdd(),
        TodoList(textContent: '영어회화 공부 20p부터', isFinished: true),
        TodoList(textContent: '최승표 절대 지켜', isFinished: false),
      ]),
    );
  }
}

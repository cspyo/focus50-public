import 'package:flutter/material.dart';

// import 'package:focus42/consts/colors.dart';
import '../widgets/todo_list.dart';

// ignore: camel_case_types
class Todo extends StatelessWidget {
  const Todo({Key? key}) : super(key: key);

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
                  onPressed: () {},
                  iconSize: 30,
                  hoverColor: Colors.transparent,
                  icon: Icon(
                    Icons.add,
                    color: Colors.black,
                  )),
            ],
          ),
        ),
        TodoList(textContent: '영어회화 공부 30p부터', isFinished: false),
        TodoList(textContent: '영어회화 공부 20p부터', isFinished: true),
        TodoList(textContent: '최승표 절대 지켜', isFinished: false),
      ]),
    );
  }
}

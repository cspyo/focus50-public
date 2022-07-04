import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/todo_ui.dart';

// import 'package:focus42/consts/colors.dart';
// import 'package:todo/todo.dart';

// ignore: camel_case_types
class Todo extends StatefulWidget {
  @override
  TodoState createState() => TodoState();
}

class TodoState extends State<Todo> {
  final collRef = FirebaseFirestore.instance.collection('todo');
  final user = FirebaseAuth.instance.currentUser;
  late String jsonString;
  int plusPressCount = 0;
  String todoList = '';
  List todoTest = [];
  @override
  Widget build(BuildContext context) {
    collRef
        .where('userUid', isEqualTo: user!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      todoTest.clear();
      querySnapshot.docs.forEach((doc) {
        setState(() {
          todoTest.add({
            'task': doc['task'],
            'isComplete': doc['isComplete'],
            'createdDate': doc['createdDate'],
            'userUid': doc['userUid'],
            'docId': doc.id,
          });
        });

        // print(todoTest[0]['docId']);
      });
    });
    return Container(
      margin: EdgeInsets.only(top: 27),
      width: 380,
      child: Column(children: [
        Container(
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
                    setState(() {
                      plusPressCount++;
                    });
                    // print(plus);
                  },
                  iconSize: 30,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: plusPressCount % 2 == 0
                      ? Icon(
                          Icons.add,
                          color: Colors.black,
                        )
                      : Icon(
                          Icons.close,
                          color: Colors.black,
                        )),
            ],
          ),
        ),
        plusPressCount % 2 == 1
            ? Container(
                margin: EdgeInsets.only(top: 9),
                width: 360,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) {
                      setState(() {
                        plusPressCount++;
                        collRef.add({
                          'userUid': user!.uid,
                          'task': value,
                          'createdDate': Timestamp.fromDate(DateTime.now()),
                          'isComplete': false,
                        });
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '할 일을 적어주세요',
                      fillColor: Colors.white,
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 2.0),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 2.0),
                      ),
                    )))
            : Text(''),
        for (var i = 0; i < todoTest.length; i++)
          todoTest.length == 0
              ? Text('')
              : TodoUi(
                  task: todoTest[i]['task'],
                  isComplete: todoTest[i]['isComplete'],
                  createdDate: todoTest[i]['createdDate'],
                  userUid: todoTest[i]['userUid'],
                  docId: todoTest[i]['docId'])
      ]),
    );
  }
}

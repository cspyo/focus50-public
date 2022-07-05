import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../consts/colors.dart';
import '../widgets/todo_ui.dart';

// import 'package:focus42/consts/colors.dart';
// import 'package:todo/todo.dart';

// ignore: camel_case_types
class Todo extends StatefulWidget {
  @override
  TodoState createState() => TodoState();
}

class TodoState extends State<Todo> {
  final user = FirebaseAuth.instance.currentUser;
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('todo')
      // .where('userUid', isEqualTo: user?.uid)
      .snapshots();
  final collRef = FirebaseFirestore.instance.collection('todo');

  late String jsonString;
  int plusPressCount = 0;
  String todoList = '';
  List todoTest = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        todoTest.clear();
        snapshot.data!.docs.forEach((doc) {
          todoTest.add({
            'task': doc['task'],
            'isComplete': doc['isComplete'],
            'createdDate': doc['createdDate'],
            'userUid': doc['userUid'],
            'docId': doc.id,
            'modifiedDate': doc['modifiedDate'],
            'completedDate': doc['completedDate']
          });
          todoTest.sort((a, b) => b['createdDate'].compareTo(a['createdDate']));
          todoTest
              .sort((a, b) => b['modifiedDate'].compareTo(a['modifiedDate']));
          todoTest
              .sort((a, b) => a['completedDate'].compareTo(b['completedDate']));
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
                              'modifiedDate': Timestamp.fromDate(
                                  DateTime.fromMicrosecondsSinceEpoch(0)),
                              'completedDate': Timestamp.fromDate(
                                  DateTime.fromMicrosecondsSinceEpoch(0))
                            });
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '할 일을 적어주세요',
                          fillColor: Colors.white,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2.0),
                          ),
                        )))
                : Text(''),
            for (var i = 0; i < todoTest.length; i++)
              todoTest.length == 0
                  ? Container(
                      margin: EdgeInsets.only(top: 32),
                      padding: EdgeInsets.all(15),
                      width: 380,
                      height: 120,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1.5, color: border100),
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: Offset(0, 6),
                            ),
                          ]),
                      child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                            Text('투두가 없습니다',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 24, 24, 24))),
                            Text('해야할 일을 정해 입력해보세요!',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(105, 105, 105, 100))),
                          ])))
                  : TodoUi(
                      task: todoTest[i]['task'],
                      isComplete: todoTest[i]['isComplete'],
                      createdDate: todoTest[i]['createdDate'],
                      userUid: todoTest[i]['userUid'],
                      docId: todoTest[i]['docId'])
          ]),
        );
      },
    );
  }
}

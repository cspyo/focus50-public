import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../consts/colors.dart';

class TodoUi extends StatefulWidget {
  final String task;
  final bool isComplete;
  final Timestamp createdDate;
  final String userUid;
  final String docId;
  const TodoUi(
      {Key? Key,
      required this.task,
      required this.isComplete,
      required this.createdDate,
      required this.userUid,
      required this.docId})
      : super(key: Key);
  @override
  State<TodoUi> createState() => TodoUiState();
}

class TodoUiState extends State<TodoUi> {
  final collRef = FirebaseFirestore.instance.collection('todo');
  @override
  Widget build(BuildContext context) {
    String task = widget.task;
    bool isComplete = widget.isComplete;
    // Timestamp createdDate = widget.createdDate;
    // String userUid = widget.userUid;

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
                  onPressed: () {
                    setState(() {
                      collRef
                          .doc(widget.docId)
                          .update({'isComplete': !isComplete});
                    });
                  },
                  child: isComplete
                      ? Icon(Icons.radio_button_checked, color: Colors.black)
                      : Icon(Icons.radio_button_unchecked,
                          color: Colors.black)),
              isComplete
                  ? Text(task,
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ))
                  : Text(task),
            ],
          ),
        ));
  }
}

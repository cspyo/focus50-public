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
  bool isHover = false;
  bool isEdit = false;
  void onHover(PointerEvent details) {
    // print('hovered');
    setState(() {
      isHover = true;
    });
  }

  void onExit(PointerEvent details) {
    // print('nothovered');
    setState(() {
      isHover = false;
    });
  }

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
        child: MouseRegion(
            onEnter: onHover,
            onExit: onExit,
            child: Container(
              child: Row(
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          if (!isComplete) {
                            collRef.doc(widget.docId).update({
                              'isComplete': !isComplete,
                              'completedDate':
                                  Timestamp.fromDate(DateTime.now())
                            });
                          } else {
                            collRef.doc(widget.docId).update({
                              'isComplete': !isComplete,
                              'completedDate': Timestamp.fromDate(
                                  DateTime.fromMicrosecondsSinceEpoch(0))
                            });
                          }
                        });
                      },
                      child: isComplete
                          ? Icon(Icons.radio_button_checked,
                              color: Colors.black)
                          : Icon(Icons.radio_button_unchecked,
                              color: Colors.black)),
                  isComplete
                      ? Container(
                          width: 235,
                          child: Text(task,
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                              )),
                        )
                      : isEdit
                          ? Container(
                              width: 235,
                              child: TextFormField(
                                  autofocus: true,
                                  initialValue: task,
                                  onFieldSubmitted: (value) {
                                    setState(() {
                                      collRef
                                          .doc(widget.docId)
                                          .update({'task': value});
                                      collRef.doc(widget.docId).update({
                                        'modifiedDate':
                                            Timestamp.fromDate(DateTime.now())
                                      });
                                      isEdit = false;
                                    });
                                  }))
                          : Container(width: 235, child: Text(task)),
                  isHover
                      ? Container(
                          alignment: Alignment.centerRight,
                          child: Row(children: [
                            Container(
                              width: 40,
                              child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isEdit = true;
                                    });
                                  },
                                  child: Container(
                                      width: 30,
                                      child: Icon(Icons.edit,
                                          color: Colors.black))),
                            ),
                            Container(
                              width: 40,
                              child: TextButton(
                                  onPressed: () {
                                    collRef.doc(widget.docId).delete();
                                  },
                                  child: Container(
                                      width: 30,
                                      child: Icon(Icons.delete,
                                          color: Colors.black))),
                            )
                          ]),
                        )
                      : Text(''),
                ],
              ),
            )));
  }
}

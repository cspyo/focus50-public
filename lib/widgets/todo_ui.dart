import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focus42/models/todo_model.dart';

import '../consts/colors.dart';

class TodoUi extends StatefulWidget {
  final String task;
  final bool isComplete;
  final Timestamp createdDate;
  final String userUid;
  final String docId;
  final String? assignedSessionId;

  const TodoUi({
    Key? Key,
    required this.task,
    required this.isComplete,
    required this.createdDate,
    required this.userUid,
    required this.docId,
    this.assignedSessionId,
  }) : super(key: Key);
  @override
  State<TodoUi> createState() =>
      TodoUiState(assignedSessionId: assignedSessionId);
}

class TodoUiState extends State<TodoUi> {
  final _todoColRef =
      FirebaseFirestore.instance.collection('todo').withConverter<TodoModel>(
            fromFirestore: TodoModel.fromMap,
            toFirestore: (TodoModel todoModel, _) => todoModel.toMap(),
          );
  bool isHover = false;
  bool isEdit = false;
  final String? assignedSessionId;
  void onHover(PointerEvent details) {
    setState(() {
      isHover = true;
    });
  }

  void onExit(PointerEvent details) {
    setState(() {
      isHover = false;
    });
  }

  TodoUiState({required this.assignedSessionId});

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
                          TodoModel newTodo;
                          if (!isComplete) {
                            newTodo = TodoModel(
                              completedDate: DateTime.now(),
                              isComplete: !isComplete,
                              assignedSessionId: assignedSessionId,
                            );
                          } else {
                            newTodo = TodoModel(
                              completedDate:
                                  DateTime.fromMicrosecondsSinceEpoch(0),
                              isComplete: !isComplete,
                              assignedSessionId: assignedSessionId,
                            );
                          }
                          _todoColRef
                              .doc(widget.docId)
                              .update(newTodo.toUpdateFirestore());
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
                                    setState(() async {
                                      TodoModel newTodo = TodoModel(
                                        task: value,
                                        modifiedDate: DateTime.now(),
                                      );
                                      _todoColRef
                                          .doc(widget.docId)
                                          .update(newTodo.toUpdateFirestore());
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
                                    _todoColRef.doc(widget.docId).delete();
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

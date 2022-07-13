import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:logger/logger.dart';

import '../consts/colors.dart';
import '../models/todo_model.dart';

// import 'package:focus42/consts/colors.dart';
// import 'package:todo/todo.dart';

// ignore: camel_case_types

class TodoPopup extends StatefulWidget {
  final ReservationModel session;
  TodoPopup({required this.session});
  @override
  TodoPopupState createState() => TodoPopupState(session: session);
}

class TodoPopupState extends State<TodoPopup> {
  final ReservationModel session;
  final _user = FirebaseAuth.instance;
  final _todoColRef =
      FirebaseFirestore.instance.collection('todo').withConverter<TodoModel>(
            fromFirestore: TodoModel.fromFirestore,
            toFirestore: (TodoModel todoModel, _) => todoModel.toFirestore(),
          );
  late final Stream<QuerySnapshot> _myTodoColRef;
  List<TodoModel> myTodo = [];
  bool isEditing = false;

  TodoPopupState({required this.session});

  @override
  void initState() {
    _myTodoColRef = _todoColRef
        .where('userUid', isEqualTo: _user.currentUser?.uid)
        .where('isComplete', isEqualTo: false)
        .orderBy('completedDate')
        .orderBy('modifiedDate', descending: true)
        .orderBy('createdDate', descending: true)
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _myTodoColRef,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          var logger = Logger();
          logger.e(snapshot.error);
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("");
        }
        // var logger = Logger();
        // logger.d("updated");
        myTodo.clear();
        snapshot.data!.docs.forEach((doc) {
          // TODO: 효율적으로 todo list 보여주기
          final TodoModel todo = doc.data() as TodoModel;
          todo.pk = doc.id;
          myTodo.add(todo);
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
                      child: Text('이번 세션에서 할 일을 선택해주세요 (최대 3개)',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600))),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                      iconSize: 30,
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      icon: isEditing == false
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
            isEditing == true
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
                          DateTime now = DateTime.now();
                          // ?(질문): setState 하는게 맞나?
                          setState(() {
                            isEditing = !isEditing;
                            TodoModel todo = TodoModel(
                              userUid: _user.currentUser!.uid,
                              task: value,
                              createdDate: now,
                              modifiedDate: now,
                              completedDate:
                                  DateTime.fromMicrosecondsSinceEpoch(0),
                              isComplete: false,
                            );
                            _todoColRef.add(todo);
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
            for (var i = 0; i < myTodo.length; i++)
              // ?(질문): for 문 사용법 모르겠어요
              TodoPopupUi(
                task: myTodo[i].task!,
                isComplete: myTodo[i].isComplete!,
                createdDate: Timestamp.fromDate(myTodo[i].createdDate!),
                userUid: myTodo[i].userUid!,
                docId: myTodo[i].pk!,
                currentSessionId: session.pk!,
                assignedSessionId: myTodo[i].assignedSessionId,
              )
          ]),
        );
      },
    );
  }
}

class TodoPopupUi extends StatefulWidget {
  final String task;
  final bool isComplete;
  final Timestamp createdDate;
  final String userUid;
  final String docId;

  final String? currentSessionId;
  final String? assignedSessionId;

  const TodoPopupUi({
    Key? Key,
    required this.task,
    required this.isComplete,
    required this.createdDate,
    required this.userUid,
    required this.docId,
    this.currentSessionId,
    this.assignedSessionId,
  }) : super(key: Key);
  @override
  State<TodoPopupUi> createState() => TodoPopupUiState(
      assignedSessionId: assignedSessionId, currentSessionId: currentSessionId);
}

class TodoPopupUiState extends State<TodoPopupUi> {
  final _todoColRef =
      FirebaseFirestore.instance.collection('todo').withConverter<TodoModel>(
            fromFirestore: TodoModel.fromFirestore,
            toFirestore: (TodoModel todoModel, _) => todoModel.toFirestore(),
          );
  final _user = FirebaseAuth.instance;
  bool isHover = false;
  bool isEdit = false;
  String? assignedSessionId;
  final String? currentSessionId;
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

  TodoPopupUiState({
    required this.assignedSessionId,
    required this.currentSessionId,
  });

  @override
  Widget build(BuildContext context) {
    String task = widget.task;
    bool isComplete = widget.isComplete;

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
                          if (assignedSessionId != currentSessionId) {
                            newTodo = TodoModel(
                              assignedSessionId: currentSessionId,
                            );
                            assignedSessionId = currentSessionId;
                          } else {
                            newTodo = TodoModel(
                              assignedSessionId: null,
                            );
                            assignedSessionId = null;
                          }
                          _todoColRef
                              .doc(widget.docId)
                              .update(newTodo.toUpdateFirestore());
                        });
                      },
                      child: assignedSessionId != null &&
                              assignedSessionId == currentSessionId
                          ? Icon(Icons.check, color: Colors.black)
                          : Icon(Icons.check_box_outline_blank_outlined,
                              color: Colors.black)),
                  Container(width: 235, child: Text(task)),
                ],
              ),
            )));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/models/todo_model.dart';

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
  Map<String, TodoModel> myTodo = {};

  bool isEditing = false;

  TodoPopupState({required this.session});

  @override
  void initState() {
    _todoColRef
        .where('userUid', isEqualTo: _user.currentUser?.uid)
        .where('isComplete', isEqualTo: false)
        .orderBy('completedDate')
        .orderBy('modifiedDate', descending: true)
        .orderBy('createdDate', descending: true)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      setState(() {
        querySnapshot.docChanges.forEach((change) {
          switch (change.type) {
            case DocumentChangeType.added:
              TodoModel todo = change.doc.data() as TodoModel;
              todo.pk = change.doc.id;
              myTodo[change.doc.id] = todo;
              break;
            case DocumentChangeType.removed:
              myTodo.remove(change.doc.id);
              break;
            case DocumentChangeType.modified:
              TodoModel todo = change.doc.data() as TodoModel;
              todo.pk = change.doc.id;
              myTodo[change.doc.id] = todo;
              break;
          }
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      setState(() {
                        isEditing = !isEditing;
                        TodoModel todo = TodoModel(
                          userUid: _user.currentUser!.uid,
                          task: value,
                          createdDate: now,
                          modifiedDate: now,
                          completedDate: DateTime.fromMicrosecondsSinceEpoch(0),
                          isComplete: false,
                        );
                        _todoColRef.add(todo);
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: myTodo.values
                  .map((element) => TodoPopupUi(
                        task: element.task!,
                        isComplete: element.isComplete!,
                        createdDate: Timestamp.fromDate(element.createdDate!),
                        userUid: element.userUid!,
                        docId: element.pk!,
                        currentSessionId: session.pk!,
                        assignedSessionId: element.assignedSessionId,
                      ))
                  .whereType<Widget>()
                  .toList(),
            ),
          ),
        )
      ]),
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
  State<TodoPopupUi> createState() => TodoPopupUiState();
}

class TodoPopupUiState extends State<TodoPopupUi> {
  final _todoColRef =
      FirebaseFirestore.instance.collection('todo').withConverter<TodoModel>(
            fromFirestore: TodoModel.fromFirestore,
            toFirestore: (TodoModel todoModel, _) => todoModel.toFirestore(),
          );
  bool isHover = false;
  bool isEdit = false;
  void onHover(PointerEvent details) {
    setState(() {
      isHover = true;
    });
  }

  TodoPopupUiState();

  void onExit(PointerEvent details) {
    setState(() {
      isHover = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String task = widget.task;

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
                      onPressed: setAssignedSession,
                      child: widget.assignedSessionId != null &&
                              widget.assignedSessionId ==
                                  widget.currentSessionId
                          ? Icon(Icons.check, color: Colors.black)
                          : Icon(Icons.check_box_outline_blank_outlined,
                              color: Colors.black)),
                  Container(width: 235, child: Text(task)),
                ],
              ),
            )));
  }

  void setAssignedSession() {
    return setState(() {
      TodoModel newTodo;
      if (widget.assignedSessionId != widget.currentSessionId) {
        newTodo = TodoModel(
          assignedSessionId: widget.currentSessionId,
        );
      } else {
        newTodo = TodoModel(
          assignedSessionId: null,
        );
      }
      _todoColRef.doc(widget.docId).update(newTodo.toUpdateFirestore());
    });
  }
}

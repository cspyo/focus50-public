import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/feature/auth/presentation/show_auth_dialog.dart';
import 'package:focus50/feature/calendar/presentation/todo_ui.dart';
import 'package:focus50/feature/todo/data/todo_model.dart';
import 'package:focus50/utils/analytics_method.dart';
import 'package:logger/logger.dart';

class Todo extends StatefulWidget {
  @override
  TodoState createState() => TodoState();
}

final _user = FirebaseAuth.instance;

class TodoState extends State<Todo> {
  String? userUid = _user.currentUser?.uid;
  final _todoColRef =
      FirebaseFirestore.instance.collection('todo').withConverter<TodoModel>(
            fromFirestore: TodoModel.fromMap,
            toFirestore: (TodoModel todoModel, _) => todoModel.toMap(),
          );
  late final Stream<QuerySnapshot> _myTodoColRef;

  List<TodoModel> myTodo = [];
  bool isTodoCompleted = false;

  @override
  void initState() {
    if (userUid != null) {
      _myTodoColRef = _todoColRef
          .where('userUid', isEqualTo: userUid)
          .orderBy('completedDate')
          .orderBy('modifiedDate', descending: true)
          .orderBy('createdDate', descending: true)
          .snapshots();
    } else {
      _myTodoColRef =
          _todoColRef.where('userUid', isEqualTo: 'none').snapshots();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _myTodoColRef,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // if (!snapshot.hasData) {
        //   return Text('');
        // }

        if (snapshot.hasError) {
          var logger = Logger();
          logger.e(snapshot.error);
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 80,
            width: 250,
            child: Text('Todo 로딩중입니다',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 24, 24, 24))),
          );
        }
        myTodo.clear();
        snapshot.data!.docs.forEach((doc) {
          // TODO: 효율적으로 todo list 보여주기
          final TodoModel todo = doc.data() as TodoModel;
          todo.id = doc.id;
          myTodo.add(todo);
        });
        return Expanded(
          child: Container(
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
                                fontSize: 32, fontWeight: FontWeight.w600))),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isTodoCompleted = !isTodoCompleted;
                          });
                        },
                        iconSize: 30,
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        icon: isTodoCompleted == false
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
              isTodoCompleted == true
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
                            if (userUid != null) {
                              DateTime now = DateTime.now();
                              setState(() {
                                isTodoCompleted = !isTodoCompleted;
                                TodoModel todo = TodoModel(
                                  userUid: userUid,
                                  task: value,
                                  createdDate: now,
                                  modifiedDate: now,
                                  completedDate:
                                      DateTime.fromMicrosecondsSinceEpoch(0),
                                  isComplete: false,
                                );
                                _todoColRef.add(todo);
                                AnalyticsMethod().logMakeTodoInCalendar();
                              });
                            } else {
                              ShowAuthDialog().showLoginDialog(context);
                            }
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < myTodo.length; i++)
                        // ?(질문): for 문 사용법 모르겠어요
                        myTodo.length == 0
                            ? Container(
                                margin: EdgeInsets.only(top: 32),
                                padding: EdgeInsets.all(15),
                                width: 380,
                                height: 120,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 1.5, color: border100),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32)),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                      Text('투두가 없습니다',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Color.fromARGB(
                                                  255, 24, 24, 24))),
                                      Text('해야할 일을 정해 입력해보세요!',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromARGB(
                                                  105, 105, 105, 100))),
                                    ])))
                            : TodoUi(
                                task: myTodo[i].task!,
                                isComplete: myTodo[i].isComplete!,
                                createdDate:
                                    Timestamp.fromDate(myTodo[i].createdDate!),
                                userUid: myTodo[i].userUid!,
                                docId: myTodo[i].id!)
                    ],
                  ),
                ),
              )
            ]),
          ),
        );
      },
    );
  }
}

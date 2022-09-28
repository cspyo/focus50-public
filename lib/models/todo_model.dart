import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  String? id;
  final String? userUid;
  final String? task;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final DateTime? completedDate;
  final bool? isComplete;
  final String? assignedSessionId;

//default Constructor
  TodoModel({
    this.id,
    this.userUid,
    this.task,
    this.createdDate,
    this.modifiedDate,
    this.completedDate,
    this.isComplete,
    this.assignedSessionId,
  });

  factory TodoModel.newTodo(String uid, String text) {
    return TodoModel(
      userUid: uid,
      task: text,
      createdDate: DateTime.now(),
      modifiedDate: DateTime.now(),
      completedDate: DateTime.fromMicrosecondsSinceEpoch(0),
      isComplete: false,
      assignedSessionId: null,
    );
  }

  factory TodoModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return TodoModel(
      id: snapshot.id,
      userUid: data?['userUid'],
      task: data?['task'],
      createdDate: data?['createdDate']?.toDate(),
      modifiedDate: data?['modifiedDate']?.toDate(),
      completedDate: data?['completedDate']?.toDate(),
      isComplete: data?['isComplete'],
      assignedSessionId: data?['assignedSessionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'task': task,
      'createdDate': createdDate,
      'modifiedDate': modifiedDate,
      'completedDate': completedDate,
      'isComplete': isComplete,
      'assignedSessionId': assignedSessionId,
    };
  }

  TodoModel doComplete() {
    TodoModel completedTodo = TodoModel(
      id: this.id,
      userUid: this.userUid,
      task: this.task,
      createdDate: this.createdDate,
      modifiedDate: this.modifiedDate,
      completedDate: this.completedDate,
      isComplete: true,
      assignedSessionId: this.assignedSessionId,
    );
    return completedTodo;
  }

  TodoModel undoComplete() {
    TodoModel completedTodo = TodoModel(
      id: this.id,
      userUid: this.userUid,
      task: this.task,
      createdDate: this.createdDate,
      modifiedDate: this.modifiedDate,
      completedDate: this.completedDate,
      isComplete: false,
      assignedSessionId: this.assignedSessionId,
    );
    return completedTodo;
  }

  TodoModel doAssign(String sessionId) {
    TodoModel completedTodo = TodoModel(
      id: this.id,
      userUid: this.userUid,
      task: this.task,
      createdDate: this.createdDate,
      modifiedDate: this.modifiedDate,
      completedDate: this.completedDate,
      isComplete: this.isComplete,
      assignedSessionId: sessionId,
    );
    return completedTodo;
  }

  TodoModel undoAssign() {
    TodoModel completedTodo = TodoModel(
      id: this.id,
      userUid: this.userUid,
      task: this.task,
      createdDate: this.createdDate,
      modifiedDate: this.modifiedDate,
      completedDate: this.completedDate,
      isComplete: this.isComplete,
      assignedSessionId: null,
    );
    return completedTodo;
  }

  TodoModel editTask(String newTask) {
    TodoModel editedTodo = TodoModel(
      id: this.id,
      userUid: this.userUid,
      task: newTask,
      createdDate: this.createdDate,
      modifiedDate: DateTime.now(),
      completedDate: this.completedDate,
      isComplete: this.isComplete,
      assignedSessionId: this.assignedSessionId,
    );
    return editedTodo;
  }

  Map<String, dynamic> toUpdateFirestore() {
    return {
      if (userUid != null) 'userUid': userUid,
      if (task != null) 'task': task,
      if (createdDate != null) 'createdDate': createdDate,
      if (modifiedDate != null) 'modifiedDate': modifiedDate,
      if (completedDate != null) 'completedDate': completedDate,
      if (isComplete != null) 'isComplete': isComplete,
      'assignedSessionId': assignedSessionId,
    };
  }
}

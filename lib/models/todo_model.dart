import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  String? pk;
  final String? userUid;
  final String? task;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final DateTime? completedDate;
  final bool? isComplete;
  final String? assignedSessionId;

//default Constructor
  TodoModel({
    this.userUid,
    this.task,
    this.createdDate,
    this.modifiedDate,
    this.completedDate,
    this.isComplete,
    this.assignedSessionId,
  });

  factory TodoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return TodoModel(
      userUid: data?['userUid'],
      task: data?['task'],
      createdDate: data?['createdDate']?.toDate(),
      modifiedDate: data?['modifiedDate']?.toDate(),
      completedDate: data?['completedDate']?.toDate(),
      isComplete: data?['isComplete'],
      assignedSessionId: data?['assignedSessionId'],
    );
  }
  Map<String, dynamic> toFirestore() {
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryModel {
  final String? uid;
  final DateTime? updatedDate;
  final Map<DateTime, int>? sessionHistory;

//default Constructor
  HistoryModel({
    this.uid,
    this.updatedDate,
    this.sessionHistory,
  });

  factory HistoryModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    String uid = data?['uid'];
    DateTime? updatedDate =
        data?['updatedDate'] != null ? data!['updatedDate'].toDate() : null;

    Map<DateTime, int>? sessionHistory = data?['sessionHistory'] != null
        ? data!["sessionHistory"].map<DateTime, int>(
            (key, value) => MapEntry(DateTime.parse(key), value as int))
        : null;

    return HistoryModel(
      uid: uid,
      updatedDate: updatedDate,
      sessionHistory: sessionHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (uid != null) 'uid': uid,
      if (updatedDate != null) 'updatedDate': updatedDate,
      if (sessionHistory != null)
        'sessionHistory': sessionHistory!.map((key, value) =>
            MapEntry(DateFormat('yyyy-MM-dd').format(key), value)),
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  String? id;
  final String? text;
  final String? url;
  final String? startColor;
  final String? endColor;
  final String? fontColor;

//default Constructor
  NoticeModel({
    this.id,
    this.text,
    this.url,
    this.startColor,
    this.endColor,
    this.fontColor,
  });

  factory NoticeModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return NoticeModel(
      id: snapshot.id,
      text: data?['text'],
      url: data?['url'],
      startColor: data?['startColor'],
      endColor: data?['endColor'],
      fontColor: data?['fontColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (text != null) 'text': text,
      if (url != null) 'url': url,
      if (startColor != null) 'startColor': startColor,
      if (endColor != null) 'endColor': endColor,
      if (fontColor != null) 'fontColor': fontColor,
    };
  }
}

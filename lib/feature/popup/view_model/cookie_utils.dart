import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

//* Ex) key: mainPop12193 value: close
//* 참조 - 4대 보험 제출

void setCookie(
  String key,
  String value,
  int expiredays,
) {
  final f = DateFormat('E, d MMM yyyy HH:mm:ss');
  final expDate = DateTime.now().add(Duration(days: expiredays));
  final date = f.format(expDate.toUtc()) + " GMT";
  html.document.cookie = '$key=$value; path=/; expires=$date';
  debugPrint("[DEBUG] $date");
}

Map<String, String> getCookie() {
  final cookie = html.document.cookie!;
  final entity = cookie.split("; ").map((item) {
    final split = item.split("=");
    return MapEntry(split[0], split[1]);
  });
  final cookieMap = Map.fromEntries(entity);
  return cookieMap;
}

import 'dart:html' as html;

import 'package:focus50/feature/popup/view_model/cookie_utils.dart';

//* Ex) 주소/MainPop.do?popType=1&popSeq=12193
//* 참조 - 4대 보험 제출

void launchNoticeWindow() {
  final popSeq = 1;
  final popName = "Focus50 - 알려드립니다";
  final Map<String, String> cookie = getCookie();
  if (cookie['mainPop${popSeq}'] == "close") {
    return;
  }
  html.window.open("mainPop.html?popSeq=${popSeq}", popName,
      'left=100,top=100,height=570,width=520');
}

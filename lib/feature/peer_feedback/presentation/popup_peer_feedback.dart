import 'package:flutter/material.dart';
import 'package:focus42/feature/peer_feedback/data/peer_feedback_model.dart';

void watchFeedbacks(dynamic database, List<PeerFeedbackModel> peerFeedbacks) {
  print("[DEBUG] watchFeedbacks");
  peerFeedbacks.forEach((element) {
    database.updateFeedback(element.doShow());
  });
}

Future<dynamic> popupPeerFeedbacks(
    dynamic database, BuildContext context) async {
  if (database.uid == 'none') return;

  List<PeerFeedbackModel> peerFeedbacks = await database.getPeerFeedbacks();
  if (peerFeedbacks.isEmpty) return;

  Map<String, List<PeerFeedbackModel>> peerFeedbackMap = new Map();
  peerFeedbacks.forEach((element) {
    final month = element.reservationDetail!.startTime!.month;
    final day = element.reservationDetail!.startTime!.day;
    final hour = element.reservationDetail!.startTime!.hour;
    final minute = element.reservationDetail!.startTime!.minute;
    final String dateString = "${month}월 ${day}일 ${hour}시 ${minute}분";
    if (peerFeedbackMap.containsKey(dateString)) {
      peerFeedbackMap[dateString]!.add(element);
    } else {
      peerFeedbackMap[dateString] = [element];
    }
  });
  final peerFeedbackKeys = peerFeedbackMap.keys.toList();
  watchFeedbacks(database, peerFeedbacks);
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          children: [
            Container(
              child: Text("당신의 열정을 응원합니다"),
            ),
            Container(
              width: 350,
              height: 400,
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: peerFeedbackKeys.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 0.5),
                itemBuilder: (context, i) {
                  return Column(
                    children: [
                      Container(
                        child: Text("${peerFeedbackKeys[i]} 에 받은 응원입니다"),
                      ),
                      Container(
                        width: 350,
                        height: 500,
                        child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          itemCount:
                              peerFeedbackMap[peerFeedbackKeys[i]]!.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 0.5),
                          itemBuilder: (context, j) {
                            final List<PeerFeedbackModel> peerFeedbacksInTime =
                                peerFeedbackMap[peerFeedbackKeys[i]]!;
                            return Row(
                              children: [
                                Image.network(
                                  peerFeedbacksInTime[j].fromPhotoUrl!,
                                  fit: BoxFit.cover,
                                  width: 30,
                                  height: 30,
                                ),
                                Text(
                                    "/ ${peerFeedbacksInTime[j].fromNickname}"),
                                Text(
                                    "/ ${peerFeedbacksInTime[j].contentText!}"),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

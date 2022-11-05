import 'package:flutter/material.dart';
import 'package:focus42/feature/peer_feedback/data/peer_feedback_model.dart';

void watchFeedbacks(dynamic database, List<PeerFeedbackModel> peerFeedbacks) {
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
  const double _dialogWidth = 350;
  final int dateKeyListLength = peerFeedbackKeys.length;
  const double dateItemHeight = 38;
  const double dateDividerHeight = 0.5;
  final int feedbackListLength = peerFeedbacks.length;
  const double feedbackItemHeight = 96;
  const double feedbackTextHeight = 40;
  const double feedbackDividerHeight = 0.5;
  watchFeedbacks(database, peerFeedbacks);
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: _dialogWidth,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Text("🔥 당신의 열정을 응원합니다 🔥",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              ),
              Container(
                width: 350,
                height: feedbackListLength *
                        (feedbackItemHeight + feedbackDividerHeight) +
                    dateKeyListLength * (dateItemHeight + dateDividerHeight),
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  itemCount: peerFeedbackKeys.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: dateDividerHeight,
                    color: Colors.transparent,
                  ),
                  itemBuilder: (context, i) {
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                            height: dateItemHeight,
                            child: Text(
                              "${peerFeedbackKeys[i]} 에 받은 응원이에요",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 350,
                          height: (feedbackItemHeight + feedbackDividerHeight) *
                              peerFeedbackMap[peerFeedbackKeys[i]]!.length,
                          child: ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemCount:
                                peerFeedbackMap[peerFeedbackKeys[i]]!.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: feedbackDividerHeight,
                              color: Colors.transparent,
                            ),
                            itemBuilder: (context, j) {
                              final List<PeerFeedbackModel>
                                  peerFeedbacksInTime =
                                  peerFeedbackMap[peerFeedbackKeys[i]]!;
                              return Container(
                                height: feedbackItemHeight,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Image.network(
                                            peerFeedbacksInTime[j]
                                                .fromPhotoUrl!,
                                            fit: BoxFit.cover,
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                        Text(
                                          "${peerFeedbacksInTime[j].fromNickname}",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          " 님의 응원",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 240,
                                          height: feedbackTextHeight,
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: Text(
                                                    "${peerFeedbacksInTime[j].contentText!}"),
                                              ),
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black38,
                                              width: 0.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
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
        ),
      );
    },
  );
}

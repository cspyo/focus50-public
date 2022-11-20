import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/feature/auth/data/user_model.dart';
import 'package:focus50/feature/auth/data/user_private_model.dart';
import 'package:focus50/feature/auth/data/user_public_model.dart';
import 'package:focus50/feature/peer_feedback/data/peer_feedback_model.dart';
import 'package:focus50/top_level_providers.dart';

void watchFeedbacks(dynamic database, List<PeerFeedbackModel> peerFeedbacks) {
  peerFeedbacks.forEach((element) {
    database.updateFeedback(element.doShow());
  });
}

Future<dynamic> popupPeerFeedbacks(
    WidgetRef ref, dynamic database, BuildContext context) async {
  final fToast = FToast();
  fToast.init(context);
  if (database.uid == 'none') return;

  List<PeerFeedbackModel> peerFeedbacks = await database.getPeerFeedbacks();
  final user = await database.getUserPublic();
  int? netPromoterScore = user.netPromoterScore;
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
  int? currentScore;
  watchFeedbacks(database, peerFeedbacks);
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: ((context, setState) {
        double _screenWidth = MediaQuery.of(context).size.width;
        bool isMobileSize = _screenWidth < 500 ? true : false;
        return AlertDialog(
          contentPadding: isMobileSize
              ? EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10)
              : EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                !peerFeedbacks.isEmpty
                    ? Center(
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
                      )
                    : SizedBox.shrink(),
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
                            height: (feedbackItemHeight +
                                    feedbackDividerHeight) *
                                peerFeedbackMap[peerFeedbackKeys[i]]!.length,
                            child: ListView.separated(
                              scrollDirection: Axis.vertical,
                              itemCount:
                                  peerFeedbackMap[peerFeedbackKeys[i]]!.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
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
                netPromoterScore == null
                    ? Column(
                        children: [
                          Center(
                            child: Container(
                              width: _dialogWidth,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  "Focus50을 친구/지인 등 주변에 얼마나 추천하고 싶으신가요?\n추천 정도를 0~10점 사이로 선택해주세요!",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: isMobileSize ? 284 : 348,
                              height: isMobileSize ? 24 : 28,
                              child: Center(
                                child: ListView.separated(
                                  itemCount: 11,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(
                                      width: isMobileSize ? 24 : 28,
                                      height: isMobileSize ? 24 : 28,
                                      child: TextButton(
                                        child: Text(
                                          '$index',
                                          style: TextStyle(
                                              color: currentScore == index
                                                  ? Colors.white
                                                  : MyColors.purple300,
                                              fontSize: 8),
                                          textAlign: TextAlign.center,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            currentScore = index;
                                            updateNetPromoterScore(ref, index);
                                            Navigator.pop(context);
                                            _showNpsCompleteToast(fToast);
                                          });
                                        },
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                                  EdgeInsetsGeometry>(
                                              EdgeInsets.zero),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  currentScore == index
                                                      ? MyColors.purple300
                                                      : Colors.white),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: MyColors.purple300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          SizedBox(width: isMobileSize ? 2 : 4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        );
      }));
    },
  );
}

void updateNetPromoterScore(ref, int score) async {
  final database = ref.read(databaseProvider);
  UserPublicModel userPublic = UserPublicModel(
    netPromoterScore: score,
  );
  UserPrivateModel userPrivate = UserPrivateModel();
  UserModel updateUser = UserModel(userPublic, userPrivate);
  await database.updateUser(updateUser);
}

void _showNpsCompleteToast(FToast fToast) {
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.black45,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check,
          color: Colors.white,
        ),
        SizedBox(
          width: 12.0,
        ),
        Text(
          "피드백 주셔서 감사합니다😊",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.CENTER,
    toastDuration: Duration(seconds: 1),
  );
}

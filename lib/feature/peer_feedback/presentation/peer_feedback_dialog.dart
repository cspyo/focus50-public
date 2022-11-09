import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/peer_feedback/data/feedback.dart';
import 'package:focus42/feature/peer_feedback/data/peer_feedback_model.dart';
import 'package:focus42/feature/peer_feedback/provider/provider.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/view_models.dart/users_notifier.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class PeerFeedbackDialog extends ConsumerStatefulWidget {
  const PeerFeedbackDialog({Key? key}) : super(key: key);

  @override
  _PeerFeedbackDialogState createState() => _PeerFeedbackDialogState();
}

class _PeerFeedbackDialogState extends ConsumerState<PeerFeedbackDialog> {
  late final FToast fToast;
  late final users;
  List<bool> isClickedList = List.generate(4, (index) => false);
  List<bool> isSubmittedList = List.generate(4, (index) => false);

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    users = ref.read(usersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);
    final runningReservation = ref.watch(runningSessionFutureProvider);
    final textStyle1 = TextStyle(
      color: Colors.black54,
      fontSize: 14,
    );
    const double _dialogWidth = 350;
    const double _participantItemHeight = 60;
    final int _clickedLength = isClickedList.where((x) => x == true).length;
    const double _feedbackItemHeight = 35;
    const double _feedbackDividerHeight = 4;
    final double _feedbackListLength = FeedbackType.values.length - 1;

    return SizedBox(
      width: _dialogWidth,
      child: PointerInterceptor(
        intercepting: true,
        child: AlertDialog(
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          content: SingleChildScrollView(
            child: runningReservation.when(
              loading: () => Text("로딩중입니다"),
              error: (_, __) => Text("에러가 발생하였습니다"),
              data: (reservation) {
                List<String> userIds = [...reservation.userIds!];
                userIds.removeWhere((element) => element == database.uid);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: _dialogWidth,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Text(
                              "포공 세션이 종료되었습니다",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          children: [
                            Text(
                              "이번 시간 함께한 다른분들께",
                              style: textStyle1,
                            ),
                            Text(
                              "응원의 한마디를 남겨주세요",
                              style: textStyle1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        width: _dialogWidth,
                        height: (_participantItemHeight * userIds.length)
                                .toDouble() +
                            (_clickedLength *
                                (_feedbackItemHeight + _feedbackDividerHeight) *
                                _feedbackListLength),
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: userIds.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 0.5,
                            color: Colors.transparent,
                          ),
                          itemBuilder: (context, i) {
                            final userId = userIds[i];
                            final userNickname = users[userId]!.nickname!;
                            final userPhotoUrl = users[userId]!.photoUrl!;
                            return Container(
                              child: Center(
                                child: Column(
                                  children: [
                                    Center(
                                      child: Container(
                                        height: _participantItemHeight,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: 200,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 6.0),
                                                      child: Image.network(
                                                        userPhotoUrl,
                                                        fit: BoxFit.cover,
                                                        width: 30,
                                                        height: 30,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 6.0),
                                                      child: Text(
                                                          "${userNickname} 님"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              (isSubmittedList[i] == true)
                                                  ? SizedBox(
                                                      width: 40,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.favorite,
                                                          color: Colors.pink,
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width: 40,
                                                      child: Center(
                                                        child: TextButton(
                                                          onPressed: () {
                                                            if (isClickedList[
                                                                    i] ==
                                                                true) {
                                                              setState(() {
                                                                isClickedList[
                                                                    i] = false;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                isClickedList[
                                                                    i] = true;
                                                              });
                                                            }
                                                          },
                                                          child: Icon(
                                                            Icons.favorite,
                                                            color:
                                                                Colors.black12,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: isClickedList[i],
                                      child: Container(
                                        width: _dialogWidth,
                                        height: (_feedbackItemHeight +
                                                _feedbackDividerHeight) *
                                            _feedbackListLength,
                                        child: ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              FeedbackType.values.length - 1,
                                          separatorBuilder: (context, j) =>
                                              const Divider(
                                            height: _feedbackDividerHeight,
                                            color: Colors.transparent,
                                          ),
                                          itemBuilder: (context, j) {
                                            return Center(
                                              child: Container(
                                                width: 280,
                                                height: _feedbackItemHeight,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16.0),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      _onPeerFeedback(
                                                        database: database,
                                                        feedbackType:
                                                            FeedbackType
                                                                .values[j],
                                                        index: i,
                                                        reservation:
                                                            reservation,
                                                        userId: userId,
                                                      );
                                                    },
                                                    style: ButtonStyle(
                                                      shape: MaterialStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          side: BorderSide(
                                                            width: 0.5,
                                                            color:
                                                                Colors.black38,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                    child: FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: Text(
                                                        FeedbackType
                                                            .values[j].content,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 160,
                        child: Center(
                          child: TextButton(
                            style: ButtonStyle(
                              alignment: Alignment.centerRight,
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent),
                            ),
                            onPressed: () {
                              Get.rootDelegate.offNamed(Routes.CALENDAR);
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Color.fromARGB(255, 255, 88, 76),
                                        size: 18,
                                      ),
                                    ),
                                    Text(
                                      "캘린더로 나가기",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 255, 88, 76),
                                        fontSize: 14,
                                        // fontWeight: FontWeight.bold,
                                        // color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onPeerFeedback({
    required dynamic database,
    required ReservationModel reservation,
    required FeedbackType feedbackType,
    required String userId,
    required int index,
  }) async {
    final UserModel? myAuth = await ref.read(userStreamProvider.future);
    final feedback = PeerFeedbackModel.newPeerFeedback(
      fromUid: myAuth!.userPrivateModel!.uid!,
      fromNickname: myAuth.userPublicModel!.nickname!,
      fromPhotoUrl: myAuth.userPublicModel!.photoUrl!,
      toUid: userId,
      contentCode: feedbackType.code,
      contentText: feedbackType.content,
      reservationDetail: reservation,
    );
    assert(isClickedList[index] == true);
    setState(() {
      isClickedList[index] = false;
      isSubmittedList[index] = true;
    });
    _showCompleteToast();
    database.setFeedback(feedback);
  }

  //* Reference: pub dev <fluttertoast> readme
  void _showCompleteToast() {
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
            "응원이 전달되었습니다 😊",
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
}

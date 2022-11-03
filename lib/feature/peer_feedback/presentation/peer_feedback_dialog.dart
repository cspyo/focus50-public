import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/peer_feedback/data/feedback.dart';
import 'package:focus42/feature/peer_feedback/data/peer_feedback_model.dart';
import 'package:focus42/feature/peer_feedback/provider/provider.dart';
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
  late final users;
  List<bool> isClickedList = List.generate(4, (index) => false);

  @override
  void initState() {
    users = ref.read(usersProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);
    final runningReservation = ref.watch(runningSessionFutureProvider);
    return SizedBox(
      width: 350,
      child: PointerInterceptor(
        intercepting: true,
        child: AlertDialog(
          content: runningReservation.when(
            loading: () => Text("로딩중입니다"),
            error: (_, __) => Text("에러가 발생하였습니다"),
            data: (reservation) {
              List<String> userIds = [...reservation.userIds!];
              userIds.removeWhere((element) => element == database.uid);
              return Column(
                children: [
                  Container(
                    child: Text("포공 세션이 종료되었습니다"),
                  ),
                  Container(
                    child: Text("이번 시간 함께한 다른분들에게 응원의 한마디를 남겨주세요"),
                  ),
                  Container(
                    width: 350,
                    height: 350,
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemCount: userIds.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 0.5),
                      itemBuilder: (context, i) {
                        final userId = userIds[i];
                        final userNickname = users[userId]!.nickname!;
                        final userPhotoUrl = users[userId]!.photoUrl!;
                        return Container(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.network(
                                    userPhotoUrl,
                                    fit: BoxFit.cover,
                                    width: 30,
                                    height: 30,
                                  ),
                                  Text("${userNickname} 님"),
                                  TextButton(
                                    onPressed: () {
                                      if (isClickedList[i] == false)
                                        setState(() {
                                          isClickedList[i] = true;
                                        });
                                      else if (isClickedList[i] == true) {
                                        setState(() {
                                          isClickedList[i] = false;
                                        });
                                      }
                                    },
                                    child: Icon(Icons.heart_broken),
                                  )
                                ],
                              ),
                              Visibility(
                                visible: isClickedList[i],
                                child: Container(
                                  width: 350,
                                  height: 100,
                                  child: ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    itemCount: FeedbackType.values.length - 1,
                                    separatorBuilder: (context, j) =>
                                        const Divider(height: 0.5),
                                    itemBuilder: (context, j) {
                                      final String contentCode =
                                          FeedbackType.values[j].code;
                                      final String contentText =
                                          FeedbackType.values[j].content;
                                      return TextButton(
                                          onPressed: () async {
                                            final UserModel? myAuth =
                                                await ref.read(
                                                    userStreamProvider.future);
                                            final feedback = PeerFeedbackModel
                                                .newPeerFeedback(
                                              fromUid: myAuth!
                                                  .userPrivateModel!.uid!,
                                              fromNickname: myAuth
                                                  .userPublicModel!.nickname!,
                                              fromPhotoUrl: myAuth
                                                  .userPublicModel!.photoUrl!,
                                              toUid: userId,
                                              contentCode: contentCode,
                                              contentText: contentText,
                                              reservationDetail: reservation,
                                            );
                                            assert(isClickedList[i] == true);
                                            setState(() {
                                              isClickedList[i] = false;
                                            });
                                            database.setFeedback(feedback);
                                          },
                                          child: Text(
                                              FeedbackType.values[j].content));
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    child: TextButton(
                      onPressed: () {
                        Get.rootDelegate.offNamed(Routes.CALENDAR);
                      },
                      child: Text("나가기"),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

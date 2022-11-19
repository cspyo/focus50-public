import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/feature/peer_feedback/provider/provider.dart';
import 'package:focus42/models/report_model.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/view_models.dart/users_notifier.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ReportUserDialog extends ConsumerStatefulWidget {
  final ReservationModel reservation;
  const ReportUserDialog({
    required this.reservation,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ReportUserDialogState();
}

class _ReportUserDialogState extends ConsumerState<ReportUserDialog> {
  late final ReservationModel reservation;
  late final FirestoreDatabase database;
  List<String> selectedUsers = [];
  final TextEditingController _reportReasonController = TextEditingController();
  late final FToast fToast;
  late final users;

  @override
  void initState() {
    database = ref.read(databaseProvider);
    users = ref.read(usersProvider);
    reservation = widget.reservation;
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _reportReasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runningReservation = ref.watch(runningSessionFutureProvider);
    return SizedBox(
      child: PointerInterceptor(
        intercepting: true,
        child: AlertDialog(
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          content: SingleChildScrollView(
              child: runningReservation.when(
            error: (_, __) => Text("에러가 발생하였습니다"),
            loading: () => Text("로딩중입니다"),
            data: (reservation) {
              List<String> userIds = [...reservation.userIds!];
              userIds.removeWhere(
                  (element) => element == database.uid); //TODO: 무조건 풀어서 넣기!!!!!
              List<String> userNicknames = [];
              List<String> userPhotoUrls = [];
              userIds.forEach((userId) {
                userNicknames.add(users[userId].nickname);
                userPhotoUrls.add(users[userId].photoUrl);
              });
              return userIds.length != 0
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '⚠️ 신고 ⚠️',
                          style: MyTextStyle.CbS18W600,
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          '신고할 유저를 선택해주세요',
                          style: MyTextStyle.CgS12W400,
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        for (int index = 0; index < userIds.length; index++)
                          Container(
                            width: 240,
                            height: 40,
                            child: Center(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 8,
                                  ),
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Center(
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            if (selectedUsers
                                                .contains(userIds[index])) {
                                              selectedUsers
                                                  .remove(userIds[index]);
                                            } else {
                                              selectedUsers.add(userIds[index]);
                                            }
                                          });
                                        },
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                                  EdgeInsetsGeometry>(
                                              EdgeInsets.zero),
                                        ),
                                        child: selectedUsers
                                                .contains(userIds[index])
                                            ? Icon(
                                                Icons.check_box_outlined,
                                                color: Colors.black,
                                                size: 20,
                                              )
                                            : Icon(
                                                Icons.check_box_outline_blank,
                                                color: Colors.black,
                                                size: 20,
                                              ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black38,
                                    backgroundImage:
                                        NetworkImage(userPhotoUrls[index]),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  FittedBox(
                                    fit: BoxFit.cover,
                                    child: Text(userNicknames[index]),
                                  ),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black38,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _reportReasonController,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          cursorColor: Colors.grey.shade600,
                          cursorHeight: 18,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                style: BorderStyle.solid,
                              ),
                            ),
                            hoverColor: purple300,
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: purple300)),
                            labelText: '신고 사유',
                            floatingLabelStyle: TextStyle(
                              color: purple300,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          maxLines: 1,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40,
                              child: TextButton(
                                onPressed: () {
                                  if (selectedUsers.isEmpty) {
                                    _showToast('신고할 사람이 선택되지 않았습니다!');
                                    return;
                                  }
                                  String reportReason =
                                      _reportReasonController.text;
                                  final newReport = ReportModel(
                                    createdDate: DateTime.now(),
                                    createdBy: database.uid,
                                    reportReason: reportReason,
                                    reservationId: reservation.id,
                                    reportMemebers: selectedUsers,
                                  );
                                  database.updateReport(newReport).onError(
                                    (error, stackTrace) {
                                      _showToast('신고가 접수되지 않았습니다 ❌');
                                      return;
                                    },
                                  );
                                  _showToast('신고가 정상적으로 접수되었습니다 😊');
                                  Get.rootDelegate.offNamed(Routes.CALENDAR);
                                },
                                child: Text(
                                  '신고하고 나가기',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          MyColors.purple300),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 40,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  '취소',
                                  style: TextStyle(color: MyColors.purple300),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                            color: MyColors.purple300)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '신고할 수 없습니다',
                          style: MyTextStyle.CbS18W600,
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          '신고할 유저가 없습니다 😭',
                          style: MyTextStyle.CgS12W400,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          height: 40,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              '취소',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  MyColors.purple300),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
            },
          )),
        ),
      ),
    );
  }

  void _showToast(String toastText) {
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
            toastText,
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/view_models.dart/users_notifier.dart';
import 'package:get/get.dart';

class GoToProfileDialog extends ConsumerWidget {
  String? invitedGroupId = Uri.base.queryParameters["g"];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.read(usersProvider)[FirebaseAuth.instance.currentUser!.uid];

    return AlertDialog(
      title: _buildDialogTitle(context),
      content: SingleChildScrollView(
        child: Container(
          width: 400,
          child: Container(
            width: 400,
            child: Column(
              children: [
                Text(
                  '집중이 가장 잘되는 공간',
                  style: MyTextStyle.CbS16W400,
                ),
                Text(
                  'Focus50 에 오신 것을 환영합니다.',
                  style: MyTextStyle.CbS16W400,
                ),
                SizedBox(height: 30),
                Container(
                  width: 200,
                  padding: EdgeInsets.fromLTRB(16, 10, 0, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black38,
                        backgroundImage: NetworkImage(
                          user!.photoUrl!,
                        ),
                      ),
                      SizedBox(width: 14),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "닉네임",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: MyColors.purple300,
                            ),
                          ),
                          Container(
                            child: Text(
                              user.nickname!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: 84,
                            height: 1,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '캘린더에 보여지는 프로필',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          invitedGroupId != null
                              ? Get.rootDelegate.offNamed(Routes.PROFILE,
                                  arguments: true,
                                  parameters: {'g': invitedGroupId!})
                              : Get.rootDelegate.offNamed(Routes.PROFILE);
                          Navigator.pop(context);
                        },
                        child: Text(
                          '프로필 수정하기',
                          style: TextStyle(color: MyColors.purple300),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1.5, color: MyColors.purple300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 30),
                    SizedBox(
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          invitedGroupId != null
                              ? Get.rootDelegate.offNamed(Routes.CALENDAR,
                                  arguments: true,
                                  parameters: {'g': invitedGroupId!})
                              : Get.rootDelegate.offNamed(Routes.CALENDAR);
                          Navigator.pop(context);
                        },
                        child: Text(
                          '  집중하러 가기  ',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              MyColors.purple300),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 다이얼로그 타이틀
  Widget _buildDialogTitle(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 36,
              height: 36,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  'Focus',
                  style: TextStyle(
                    fontFamily: 'Okddung',
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '50',
                  style: TextStyle(
                    fontFamily: 'Okddung',
                    fontSize: 25,
                    color: purple300,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  child: Icon(
                    Icons.clear,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          '가입이 완료됐습니다!',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

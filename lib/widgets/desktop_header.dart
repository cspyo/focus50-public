import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/auth/show_auth_dialog.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/widgets/header_logo.dart';
import 'package:focus42/widgets/profile_popup_menu_button_widget.dart';
import 'package:get/get.dart';

class DesktopHeader extends ConsumerStatefulWidget {
  @override
  DesktopHeaderState createState() => DesktopHeaderState();
}

class DesktopHeaderState extends ConsumerState<DesktopHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _authState = ref.watch(authStateChangesProvider).asData?.value;
    return // 데스크탑 헤더
        Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          HeaderLogo(),
          Row(
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    String? invitedGroupId = Uri.base.queryParameters["g"];
                    invitedGroupId != null
                        ? Get.rootDelegate.offNamed(Routes.ABOUT,
                            arguments: true, parameters: {'g': invitedGroupId})
                        : Get.rootDelegate.offNamed(Routes.ABOUT);
                  },
                  child: const Text('소개',
                      style: TextStyle(fontSize: 17, color: Colors.black))),
              SizedBox(width: 10),
              TextButton(
                  onPressed: () {
                    String? invitedGroupId = Uri.base.queryParameters["g"];
                    invitedGroupId != null
                        ? Get.rootDelegate.offNamed(Routes.CALENDAR,
                            arguments: true, parameters: {'g': invitedGroupId})
                        : Get.rootDelegate.offNamed(Routes.CALENDAR);
                  },
                  child: const Text('캘린더',
                      style: TextStyle(fontSize: 17, color: Colors.black))),
              (_authState != null) ? SizedBox(width: 20) : SizedBox(width: 10),
              // 마이페이지 숨기기
              (_authState != null)
                  ? ProfilePopupMenuButton()
                  : SizedBox.shrink(),
              // SizedBox(width: 10),
              // (_authState != null)
              //     ? ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //           primary: purple300,
              //         ),
              //         onPressed: () {
              //           ref.read(authViewModelProvider).signOut();
              //           AnalyticsMethod().logSignOut();
              //           Get.rootDelegate.toNamed(Routes.ABOUT);
              //         },
              //         child: const Text(
              //           '  로그아웃  ',
              //           style: TextStyle(
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       )
              // : OutlinedButton(
              //     style: OutlinedButton.styleFrom(
              //       primary: purple300,
              //     ),
              //     onPressed: () =>
              //         ShowAuthDialog().showSignUpDialog(context),
              //     child: const Text(
              //       '회원가입',
              //       style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //       ),
              //     )),
              (_authState != null)
                  ? SizedBox.shrink()
                  : OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        primary: purple300,
                      ),
                      onPressed: () =>
                          ShowAuthDialog().showSignUpDialog(context),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              (_authState != null) ? SizedBox.shrink() : SizedBox(width: 20),
              (_authState != null)
                  ? SizedBox.shrink()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: purple300,
                      ),
                      onPressed: () =>
                          ShowAuthDialog().showLoginDialog(context),
                      child: const Text(
                        '  로그인  ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              (_authState != null) ? SizedBox.shrink() : SizedBox(width: 10),
            ],
          ),
        ],
      ),
    ); //header
  }
}

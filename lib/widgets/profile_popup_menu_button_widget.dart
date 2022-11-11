import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/auth/auth_view_model.dart';
import 'package:focus42/feature/indicator/circular_progress_indicator.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePopupMenuButton extends ConsumerStatefulWidget {
  ProfilePopupMenuButton({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfilePopupMenuButtonState();
}

class _ProfilePopupMenuButtonState
    extends ConsumerState<ProfilePopupMenuButton> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStreamProvider);
    return user.when(
      data: (user) {
        if (user.userPublicModel!.createdDate != null) {
          return PopupMenuButton(
            padding: EdgeInsets.zero,
            tooltip: '',
            position: PopupMenuPosition.under,
            offset: Offset(0, 16),
            elevation: 10,
            constraints: BoxConstraints.tight(Size(120, 208)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
            child: SizedBox(
              child: Row(
                children: [
                  Row(
                    children: [
                      Text(
                        '반갑습니다, ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        '${user.userPublicModel!.nickname}',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '님!',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        NetworkImage(user.userPublicModel!.photoUrl!),
                  ),
                ],
              ),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                height: 36,
                onTap: (() {
                  String? invitedGroupId = Uri.base.queryParameters["g"];
                  invitedGroupId != null
                      ? Get.rootDelegate.offNamed(Routes.PROFILE,
                          arguments: true, parameters: {'g': invitedGroupId})
                      : Get.rootDelegate.offNamed(Routes.PROFILE);
                }),
                child: Center(
                  child: const Text(
                    '내 정보',
                    style: TextStyle(fontSize: 17, color: Colors.black),
                  ),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                height: 36,
                onTap: () => _launchURL('https://open.kakao.com/o/s1lFdjse'),
                child: Center(
                  child: const Text(
                    '1:1 문의',
                    style: TextStyle(fontSize: 17, color: Colors.black),
                  ),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                height: 36,
                onTap: () => _launchURL(
                    'https://cspyo.notion.site/Focus50-6c5a9c9bd11d48d7a4bf171cfe3c2a08'),
                child: Center(
                  child: const Text(
                    '공지사항',
                    style: TextStyle(fontSize: 17, color: Colors.black),
                  ),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                height: 36,
                padding: EdgeInsets.zero,
                child: Center(
                  child: SizedBox(
                    width: 90,
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: purple300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                      onPressed: () {
                        ref.read(authViewModelProvider).signOut();
                        AnalyticsMethod().logSignOut();
                        Navigator.pop(context);
                        Get.rootDelegate.toNamed(Routes.ABOUT);
                      },
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return CircularIndicator(
              size: 20, color: MyColors.purple300); //TODO: 무조건 바꾸기
        }
      },
      error: (_, __) => Text(""),
      loading: () => CircularIndicator(size: 20, color: MyColors.purple300),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      // AnalyticsMethod().logPressSessionLogo(); //TODO: analytics 꼭 달기
    } else {
      throw 'Could not launch $url';
    }
  }
}

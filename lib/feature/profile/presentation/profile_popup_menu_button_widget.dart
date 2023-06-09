import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/consts/routes.dart';
import 'package:focus50/feature/auth/view_model/auth_view_model.dart';
import 'package:focus50/top_level_providers.dart';
import 'package:focus50/utils/amplitude_analytics.dart';
import 'package:focus50/utils/circular_progress_indicator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePopupMenuButton extends ConsumerStatefulWidget {
  const ProfilePopupMenuButton({Key? key}) : super(key: key);

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
        if (user.userPublicModel!.nickname != null) {
          return PopupMenuButton(
            onSelected: (value) {
              AmplitudeAnalytics().logClickProfilePopUpButton();
            },
            padding: EdgeInsets.zero,
            tooltip: '',
            position: PopupMenuPosition.under,
            offset: const Offset(0, 16),
            elevation: 10,
            constraints: BoxConstraints.tight(const Size(120, 208)),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
            itemBuilder: _buildPopUpMenuEntry,
            child: SizedBox(
              child: Row(
                children: [
                  Row(
                    children: [
                      Text(
                        '${user.userPublicModel!.nickname}',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '님',
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
          );
        } else {
          return const CircularIndicator(
              size: 20, color: MyColors.purple300); //TODO: 무조건 바꾸기
        }
      },
      error: (_, __) => const Text(""),
      loading: () =>
          const CircularIndicator(size: 20, color: MyColors.purple300),
    );
  }

  List<PopupMenuEntry> _buildPopUpMenuEntry(BuildContext context) {
    return <PopupMenuEntry>[
      PopupMenuItem(
        height: 36,
        onTap: (() {
          String? invitedGroupId = Uri.base.queryParameters["g"];
          AmplitudeAnalytics().logClickProfileNavigator();
          invitedGroupId != null
              ? Get.rootDelegate.offNamed(Routes.PROFILE,
                  arguments: true, parameters: {'g': invitedGroupId})
              : Get.rootDelegate.offNamed(Routes.PROFILE);
        }),
        child: const Center(
          child: Text(
            '내 정보',
            style: TextStyle(fontSize: 17, color: Colors.black),
          ),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        height: 36,
        onTap: () {
          AmplitudeAnalytics().logClickInquiryNavigator();
          _launchURL('https://open.kakao.com/o/sGdPSAVe');
        },
        child: const Center(
          child: Text(
            '1:1 문의',
            style: TextStyle(fontSize: 17, color: Colors.black),
          ),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        height: 36,
        onTap: () {
          AmplitudeAnalytics().logClickNoticeNavigator();
          _launchURL(
              'https://cspyo.notion.site/Focus50-6c5a9c9bd11d48d7a4bf171cfe3c2a08');
        },
        child: const Center(
          child: Text(
            '공지사항',
            style: TextStyle(fontSize: 17, color: Colors.black),
          ),
        ),
      ),
      const PopupMenuDivider(),
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
    ];
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

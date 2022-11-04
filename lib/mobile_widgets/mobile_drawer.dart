import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/auth/auth_view_model.dart';
import 'package:focus42/feature/auth/show_auth_dialog.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileDrawer extends ConsumerStatefulWidget {
  const MobileDrawer({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends ConsumerState<MobileDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider).asData?.value;
    return _buildDrawer(authState != null);
  }

  Widget _buildDrawer(bool isLogin) {
    return Drawer(
      backgroundColor: purple300,
      child: isLogin ? _buildWhenLogin() : _buildWhenNotLogin(),
    );
  }

  Widget _buildWhenLogin() {
    final user = ref.watch(userStreamProvider);
    return user.when(
        data: (user) {
          if (user.userPublicModel!.createdDate != null) {
            return ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      height: 60,
                      child: _buildLoginProfile(user.userPublicModel!.photoUrl!,
                          user.userPublicModel!.nickname!)),
                  SizedBox(
                    height: 4,
                  ),
                  _buildMenuItem(
                      text: '캘린더',
                      icon: Icons.calendar_month,
                      route: Routes.CALENDAR),
                  SizedBox(
                    height: 4,
                  ),
                  _buildNoticeListTile(),
                  SizedBox(
                    height: 4,
                  ),
                  _buildContactListTile(),
                  SizedBox(
                    height: 4,
                  ),
                  _buildMenuItem(
                      text: '프로필', icon: Icons.person, route: Routes.PROFILE),
                  SizedBox(height: 4),
                  Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _buildLogoutButton(),
                ]);
          } else {
            return _buildWhenNotLogin();
          }
        },
        error: (_, __) => Text(""),
        loading: () => _buildWhenNotLogin());
  }

  Widget _buildWhenNotLogin() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      children: [
        SizedBox(
          height: 20,
        ),
        SizedBox(height: 60, child: _buildNotLoginProfile()),
        SizedBox(
          height: 4,
        ),
        _buildMenuItem(
            text: '소개', icon: Icons.waving_hand, route: Routes.ABOUT),
        SizedBox(
          height: 4,
        ),
        _buildMenuItem(
            text: '캘린더', icon: Icons.calendar_month, route: Routes.CALENDAR),
        SizedBox(
          height: 4,
        ),
        _buildNoticeListTile(),
        SizedBox(
          height: 4,
        ),
        _buildContactListTile(),
        Divider(
          color: Colors.white,
          thickness: 1,
        ),
        SizedBox(
          height: 4,
        ),
        _buildSignUpButton(),
        SizedBox(height: 10),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildLoginProfile(String photoUrl, String nickname) {
    return SizedBox(
        height: 60,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  photoUrl,
                ),
                backgroundColor: Colors.white,
              ),
              SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nickname,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.left),
                ],
              )
            ]));
  }

  Widget _buildNotLoginProfile() {
    return SizedBox(
        height: 60,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/default_profile.png'),
              SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.left),
                ],
              )
            ]));
  }

  Widget _buildMenuItem({
    required String text,
    required IconData icon,
    required String route,
  }) {
    final color = Colors.white;
    return ListTile(
        leading: Icon(icon, color: color),
        onTap: () {
          Get.rootDelegate.toNamed(route);
        },
        title: Text(
          text,
          style: TextStyle(color: color),
        ));
  }

  Widget _buildNoticeListTile() {
    return ListTile(
        leading: Icon(Icons.push_pin, color: Colors.white),
        onTap: () {
          launchUrl(Uri.parse(
              'https://cspyo.notion.site/Focus-50-88016be305f245f4b9b626db19a7c0f0'));
        },
        title: Text(
          '공지사항',
          style: TextStyle(color: Colors.white),
        ));
  }

  Widget _buildContactListTile() {
    return ListTile(
        leading: Icon(Icons.phone, color: Colors.white),
        onTap: () {
          launchUrl(Uri.parse('https://open.kakao.com/o/gJyG7Dse'));
        },
        title: Text(
          '문의하기',
          style: TextStyle(color: Colors.white),
        ));
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: purple300,
          elevation: 3,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Colors.white, width: 1, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          ShowAuthDialog().showLoginDialog(context);
        },
        child: const Text(
          '  로그인  ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          ShowAuthDialog().showSignUpDialog(context);
        },
        child: const Text(
          '  회원가입  ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: purple300,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          ref.read(authViewModelProvider).signOut();
          Get.rootDelegate.toNamed(Routes.ABOUT);
        },
        child: const Text(
          '  로그아웃  ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: purple300,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(
          "로딩중...",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        _buildCircularIndicator(),
      ],
    );
  }

  Widget _buildCircularIndicator() {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 5.0,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/jitsi/presentation/list_items_builder_2.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/mobile_widgets/mobile_calendar.dart';
import 'package:focus42/mobile_widgets/mobile_group_widget.dart';
import 'package:focus42/mobile_widgets/mobile_reservation.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/auth_method.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/view_models.dart/users_notifier.dart';
import 'package:focus42/widgets/group_setting_widget.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/line.dart';

class MobileCalendarScreen extends ConsumerStatefulWidget {
  MobileCalendarScreen({Key? key}) : super(key: key);
  @override
  _MobileCalendarScreenState createState() => _MobileCalendarScreenState();
}

class _MobileCalendarScreenState extends ConsumerState<MobileCalendarScreen> {
  bool getUserInfo = false;
  late final FirestoreDatabase database;
  String userPhotoUrl =
      'https://firebasestorage.googleapis.com/v0/b/focus-50.appspot.com/o/profilePics%2Fuser.png?alt=media&token=69e13fc9-b2ea-460c-98e0-92fe6613461e';
  String userNickname = '';
  String userJob = '';
  bool isNotificationOpen = true;
  final Uri toLaunch = Uri(
    scheme: 'https',
    host: 'forms.gle',
    path: '/3bGecKhsiAwtyk4k9',
  );
  CalendarController calendarController = CalendarController();

  Future<void> getUserData() async {
    final usersNotifier = ref.read(usersProvider.notifier);
    final database = ref.read(databaseProvider);
    final auth = ref.read(firebaseAuthProvider);
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      if (!usersNotifier.containsKey(uid)) {
        UserPublicModel user = await database.getUserPublic(othersUid: uid);
        usersNotifier.addAll({uid: user});
      }
      final users = ref.read(usersProvider);
      userPhotoUrl = users[uid]!.photoUrl!;
      userNickname = users[uid]!.nickname!;
      userJob = users[uid]!.job!;
      setState(() {
        getUserInfo = true;
      });
    }
  }

  @override
  void initState() {
    getUserData();
    database = ref.read(databaseProvider);
    super.initState();
  }

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final authState = ref.watch(authStateChangesProvider).asData?.value;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Focus',
                style: TextStyle(
                  fontFamily: 'Okddung',
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              Text(
                '50',
                style: TextStyle(
                  fontFamily: 'Okddung',
                  fontSize: 30,
                  color: purple300,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: purple300),
        ),
        drawer: Drawer(
          backgroundColor: purple300,
          child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                SizedBox(
                  height: 20,
                ),
                authState == null
                    ? Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Get.rootDelegate.toNamed(Routes.LOGIN);
                          },
                          child: const Text(
                            '로그인 해주세요',
                            style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 60,
                        child: getUserInfo
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                    Image.network(userPhotoUrl),
                                    SizedBox(width: 20),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(userNickname,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.left),
                                        Text(
                                          userJob,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.left,
                                        )
                                      ],
                                    )
                                  ])
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                    Image.asset(
                                        'assets/images/default_profile.png'),
                                    SizedBox(width: 20),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(userNickname,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.left),
                                        Text(
                                          userJob,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.left,
                                        )
                                      ],
                                    )
                                  ])
                        // : Container(
                        //     alignment: Alignment.center,
                        //     width: 20,
                        //     height: 20,
                        //     child:
                        //         CircularProgressIndicator(color: Colors.white)),
                        ),
                SizedBox(
                  height: 10,
                ),
                buildMenuItem(
                    text: 'About',
                    icon: Icons.waving_hand,
                    route: Routes.ABOUT),
                SizedBox(
                  height: 10,
                ),
                buildMenuItem(
                    text: 'Calendar',
                    icon: Icons.calendar_month,
                    route: Routes.CALENDAR),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.white,
                  thickness: 1,
                ),
                SizedBox(
                  height: 20,
                ),
                (authState != null)
                    ? SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            setState(() {
                              AuthMethods().signOut();
                            });
                            AnalyticsMethod().mobileLogSignOut();
                            Get.rootDelegate.toNamed(Routes.LOGIN);
                          },
                          child: const Text(
                            '  로그아웃  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: purple300,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Get.rootDelegate.toNamed(Routes.SIGNUP);
                          },
                          child: const Text(
                            '  회원가입  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: purple300,
                            ),
                          ),
                        ),
                      ),
                SizedBox(
                  height: 10,
                ),
                (authState != null)
                    ? Container()
                    : SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: purple300,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.white,
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Get.rootDelegate.toNamed(Routes.LOGIN);
                          },
                          child: const Text(
                            '  로그인  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ]),
        ),
        body: SingleChildScrollView(
          child: Column(//페이지 전체 구성
              children: <Widget>[
            const Line(),
            Column(children: <Widget>[
              Container(
                child: MobileReservation(),
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: border100)),
                  height: screenHeight - 165,
                  child: Stack(
                    children: [
                      MobileCalendar(
                        calendarController: calendarController,
                        isNotificationOpen: isNotificationOpen,
                      ),
                      Positioned(bottom: 10, right: 10, child: MobileGroup()),
                    ],
                  )),
            ])
          ]),
        ));
  }

  Widget buildMenuItem({
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

  Widget _buildColumnGroupToggleButton(BuildContext context) {
    final _myGroupStream = ref.watch(myGroupFutureProvider);
    final _myActivatedGroupId = ref.watch(activatedGroupIdProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth - 40,
      height: 50,
      child: ListItemsBuilder2<GroupModel>(
        data: _myGroupStream,
        itemBuilder: (context, model) => _buildToggleButtonUi(
          context,
          model,
          _myActivatedGroupId == model.id ? true : false,
        ),
        creator: () => new GroupModel(
          id: 'public',
          name: '전체',
        ),
        axis: Axis.horizontal,
      ),
    );
  }

  Widget _buildToggleButtonUi(
      BuildContext context, GroupModel group, bool isThisGroupActivated) {
    return Stack(
      children: [
        Container(
          height: 80,
          child: TextButton(
            onPressed: () {
              _changeActivatedGroup(group.id!);
            },
            style: isThisGroupActivated
                ? ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(MyColors.purple100),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: MyColors.purple300, width: 1),
                      ),
                    ),
                  )
                : ButtonStyle(),
            child: Container(
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  group.id != 'public'
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            group.imageUrl!,
                            fit: BoxFit.cover,
                            width: 24,
                            height: 24,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/earth.png',
                            fit: BoxFit.cover,
                            width: 24,
                            height: 24,
                          ),
                        ),
                  Text(
                    group.name!,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: group.name!.length > 5 ? 10 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  isThisGroupActivated
                      ? SizedBox(
                          height: 22,
                          width: 38,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  MyColors.purple300),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Uri uri = Uri.parse(Uri.base.toString());
                              String quote = group.id == 'public'
                                  ? '같이 집중해봅시다!! \n자꾸 미룰 때, 할 일이 많을 때, 혼자 공부하기 싫을 때 사용해보시면 많은 도움이 될 거예요. \n아래 링크를 눌러 입장해주세요! \nhttps://focus50.day'
                                  : group.password != ''
                                      ? '귀하는 ${group.name}그룹에 초대되었습니다.\n아래 링크를 눌러 입장해주세요!\n 비밀번호 : ${group.password} \n ${uri.origin}${uri.path}?g=${group.id}'
                                      : '귀하는 ${group.name}그룹에 초대되었습니다.\n아래 링크를 눌러 입장해주세요!\n ${uri.origin}${uri.path}?g=${group.id}';
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    bool isCopied = false;
                                    return StatefulBuilder(
                                        builder: (context, setState) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16.0))),
                                        content: SizedBox(
                                          height: 264,
                                          child: Column(
                                            children: [
                                              Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: SizedBox(
                                                  width: 36,
                                                  height: 36,
                                                  child: IconButton(
                                                    padding: EdgeInsets.all(0),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: Colors.black,
                                                      size: 30,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text('이제, 문구를 복사해 그룹원들을 모집해 봅시다!',
                                                  style: MyTextStyle.CbS18W400),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color: border300),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: SelectableText(quote),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              SizedBox(
                                                width: 80,
                                                height: 44,
                                                child: TextButton(
                                                  onPressed: () {
                                                    Clipboard.setData(
                                                        ClipboardData(
                                                            text: quote));
                                                    setState(
                                                        () => isCopied = true);
                                                  },
                                                  child: !isCopied
                                                      ? Text(
                                                          '복사하기',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      : Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                        ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(MyColors
                                                                .purple300),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                  });
                            },
                            child: Text(
                              '초대',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 22,
                          width: 38,
                        ),
                ],
              ),
            ),
          ),
        ),
        isThisGroupActivated && group.id != 'public'
            ? Positioned(
                top: 4,
                left: 4,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: IconButton(
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () {
                      _popupGroupSettingDialog(context, group);
                    },
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.settings,
                      size: 16,
                      color: MyColors.purple300,
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Future<dynamic> _popupGroupSettingDialog(
      BuildContext context, GroupModel group) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GroupSettingAlertDialog(database: database, group: group);
        });
  }

  void _changeActivatedGroup(String newGroupId) {
    ref.read(activatedGroupIdProvider.notifier).state = newGroupId;
  }
}

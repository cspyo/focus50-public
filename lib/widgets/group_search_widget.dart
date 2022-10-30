import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/auth/show_auth_dialog.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/widgets/group_widget.dart';
import 'package:get/get.dart';

final searchedGroupStreamProvider =
    StreamProvider.family<List<GroupModel>, String>(
  (ref, query) {
    final database = ref.watch(databaseProvider);
    return database.getGroupsOfName(query);
  },
);

class GroupSearchAlertDialog extends ConsumerStatefulWidget {
  @override
  _GroupSearchAlertDialogState createState() => _GroupSearchAlertDialogState();
}

class _GroupSearchAlertDialogState
    extends ConsumerState<GroupSearchAlertDialog> {
  String query = '';
  final _formKey = GlobalKey<FormState>();
  late FirestoreDatabase database;
  final TextEditingController _passwordController = TextEditingController();
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    database = ref.read(databaseProvider);
  }

  @override
  void dispose() {
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchedGroups = ref.watch(searchedGroupStreamProvider(query));
    database = ref.watch(databaseProvider);
    uid = FirebaseAuth.instance.currentUser?.uid;
    double widgetWidth = 300;
    return SizedBox(
        width: widgetWidth,
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          content: Container(
            padding: EdgeInsets.zero,
            width: widgetWidth,
            height: 560,
            child: Column(
              children: [
                Container(
                  width: widgetWidth,
                  height: 56,
                  padding: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(width: 1, color: MyColors.border300))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 36,
                      ),
                      Text('그룹 검색', style: MyTextStyle.CbS18W400),
                      SizedBox(
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
                    ],
                  ),
                ),
                Container(
                  height: 68,
                  width: widgetWidth,
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      hintText: '그룹 이름을 검색해보세요',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      focusColor: Colors.black,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: MyColors.border300,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        query = val;
                      });
                    },
                  ),
                ),
                Container(
                  width: widgetWidth,
                  padding: EdgeInsets.all(10),
                  height: 432,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(16)),
                  ),
                  child: searchedGroups.when(
                      loading: () => Center(child: Text("로딩중입니다")),
                      error: (_, __) => Center(child: Text("에러가 발생하였습니다")),
                      data: (groups) => groups.isNotEmpty
                          ? ListView.separated(
                              scrollDirection: Axis.vertical,
                              itemCount: groups.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                height: 10,
                                color: MyColors.border300,
                              ),
                              itemBuilder: (context, index) {
                                final GroupModel group = groups[index];
                                return _buildSearchedGroupItem(context, group);
                              },
                            )
                          : Center(child: Text("비었습니다"))),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildSearchedGroupItem(BuildContext context, GroupModel group) {
    String groupName = group.name!;
    return Container(
      height: 44,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: TextButton(
              onPressed: () {
                // Navigator.pop(context);
                if (uid != null) {
                  _popupRegisterDialog(context, group);
                } else {
                  ShowAuthDialog().showSignUpDialog(context);
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                  ),
                ),
              ),
              child: Container(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        group.imageUrl!,
                        fit: BoxFit.cover,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      groupName,
                      softWrap: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '현재 인원 : ${group.headcount} 명',
                      style: MyTextStyle.CgS12W400,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Divider(),
        ],
      ),
    );
  }

  Future<dynamic>? _popupRegisterDialog(
    BuildContext context,
    GroupModel group,
  ) async {
    String groupName = group.name!;
    String? password = group.password;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            // height: 260,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          Navigator.pop(context);
                          _passwordController.clear();
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  password != ''
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '비밀번호를 입력해주세요.',
                              style: MyTextStyle.CbS18W400,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _passwordController,
                                validator: (_) {
                                  if (_passwordController.text != password) {
                                    return '비밀번호가 올바르지 않습니다.';
                                  }
                                  return null;
                                },
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
                                  labelText: '비밀번호',
                                  floatingLabelStyle: TextStyle(
                                    color: purple300,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                maxLines: 1,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          '가입하시겠습니까?',
                          style: MyTextStyle.CbS18W400,
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 44,
                    width: 110,
                    child: TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await enterGroup(group);
                          _passwordController.clear();
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        '가입하기',
                        style: MyTextStyle.CwS20W600,
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
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
        );
      },
    );
  }

  Future<dynamic> enterGroup(
    GroupModel group,
  ) async {
    if (group.memberUids!.contains(database.uid)) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 160,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR());
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
                  Text(
                    '그룹 가입',
                    style: MyTextStyle.CbS20W600,
                  ),
                  Text(
                    '이미 가입한 그룹입니다!',
                    style: MyTextStyle.CbS18W400,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 100,
                    height: 46,
                    child: TextButton(
                      onPressed: () {
                        Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR());
                        Navigator.pop(context);
                      },
                      child: Text(
                        '확인',
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
                  )
                ],
              ),
            ),
          );
        },
      );
    } else {
      final UserModel? user = await ref.read(userStreamProvider.future);
      database.runTransaction((transaction) async {
        final GroupModel myGroup = await database.getGroupInTransaction(
            docId: group.id!, transaction: transaction);
        database.updateGroupInTransaction(
            myGroup.addMember(database.uid), transaction);
      });
      await database.updateUser(
          UserModel(user!.userPublicModel!.addGroup(group.id!), null));
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 160,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          _changeActivatedGroup(group.id!);
                          ref.refresh(myGroupIdFutureProvider);
                          Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR());
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
                  Text(
                    '환영합니다',
                    style: MyTextStyle.CbS20W600,
                  ),
                  Text(
                    '성공적으로 가입되었습니다',
                    style: MyTextStyle.CbS18W400,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 100,
                    height: 46,
                    child: TextButton(
                      onPressed: () {
                        _changeActivatedGroup(group.id!);
                        ref.refresh(myGroupIdFutureProvider);
                        Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR());
                        Navigator.pop(context);
                      },
                      child: Text(
                        '확인',
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
                  )
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _changeActivatedGroup(String newGroupId) {
    ref.read(activatedGroupIdProvider.notifier).state = newGroupId;
  }
}

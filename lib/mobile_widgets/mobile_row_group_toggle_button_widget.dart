import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/widgets/group_setting_widget.dart';

class MobilRowGroupToggleButtonWidget extends ConsumerStatefulWidget {
  final GroupModel group;
  final bool isThisGroupActivated;
  MobilRowGroupToggleButtonWidget(
      {Key? key, required this.group, required this.isThisGroupActivated})
      : super(key: key);

  @override
  _MobilRowGroupToggleButtonWidgetState createState() =>
      _MobilRowGroupToggleButtonWidgetState();
}

class _MobilRowGroupToggleButtonWidgetState
    extends ConsumerState<MobilRowGroupToggleButtonWidget> {
  late final FirestoreDatabase database;

  void initState() {
    super.initState();
    database = ref.read(databaseProvider);
  }

  @override
  Widget build(BuildContext context) {
    GroupModel group = widget.group;
    bool isThisGroupActivated = widget.isThisGroupActivated;
    return Stack(
      children: [
        Container(
          height: 80,
          width: 72,
          // decoration: BoxDecoration(border: Border.all(width: 1)),
          child: TextButton(
            onPressed: () {
              _changeActivatedGroup(group.id!);
            },
            // style: isThisGroupActivated
            //     ? ButtonStyle(
            //         backgroundColor:
            //             MaterialStateProperty.all<Color>(MyColors.purple100),
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //             side: BorderSide(color: MyColors.purple300, width: 1),
            //           ),
            //         ),
            //       )
            //     : ButtonStyle(
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //             side: BorderSide(color: Colors.grey, width: 1),
            //           ),
            //         ),
            //       ),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: isThisGroupActivated
                            ? Border.all(width: 3, color: MyColors.purple300)
                            : Border.all(width: 3, color: Colors.transparent)),
                    child: group.id != 'public'
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  group.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: 34,
                                  height: 34,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                left: 1,
                                child: isThisGroupActivated
                                    ? SizedBox(
                                        height: 24,
                                        width: 32,
                                        child: TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(MyColors.purple300),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Uri uri =
                                                Uri.parse(Uri.base.toString());
                                            String quote = group.password != ''
                                                ? '귀하는 ${group.name}그룹에 초대되었습니다.\n아래 링크를 눌러 입장해주세요!\n 비밀번호 : ${group.password} \n ${uri.origin}${uri.path}?g=${group.id}'
                                                : '귀하는 ${group.name}그룹에 초대되었습니다.\n아래 링크를 눌러 입장해주세요!\n ${uri.origin}${uri.path}?g=${group.id}';
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  bool isCopied = false;
                                                  return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                    return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(16.0),
                                                        ),
                                                      ),
                                                      content: SizedBox(
                                                        width: 200,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: SizedBox(
                                                                width: 36,
                                                                height: 36,
                                                                child:
                                                                    IconButton(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .black,
                                                                    size: 30,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                                '이제, 문구를 복사해 그룹원들을 모집해 봅시다!',
                                                                style: MyTextStyle
                                                                    .CbS18W400),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                        border300),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                              ),
                                                              child:
                                                                  SelectableText(
                                                                      quote),
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
                                                                          text:
                                                                              quote));
                                                                  setState(() =>
                                                                      isCopied =
                                                                          true);
                                                                },
                                                                child: !isCopied
                                                                    ? Text(
                                                                        '복사하기',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      )
                                                                    : Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                style:
                                                                    ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all<
                                                                              Color>(
                                                                          MyColors
                                                                              .purple300),
                                                                  shape: MaterialStateProperty
                                                                      .all<
                                                                          RoundedRectangleBorder>(
                                                                    RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16),
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
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        height: 16,
                                        width: 30,
                                      ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/earth.png',
                                  fit: BoxFit.cover,
                                  width: 34,
                                  height: 34,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                left: 1,
                                child: isThisGroupActivated
                                    ? Container(
                                        height: 24,
                                        width: 32,
                                        child: TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(MyColors.purple300),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Uri uri =
                                                Uri.parse(Uri.base.toString());
                                            String quote =
                                                '같이 집중해봅시다!! \n자꾸 미룰 때, 할 일이 많을 때, 혼자 공부하기 싫을 때 사용해보시면 많은 도움이 될 거예요. \n아래 링크를 눌러 입장해주세요! \nhttps://focus50.day';
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  bool isCopied = false;
                                                  return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      16.0))),
                                                      content: SizedBox(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: SizedBox(
                                                                width: 36,
                                                                height: 36,
                                                                child:
                                                                    IconButton(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .black,
                                                                    size: 30,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                                '이제, 문구를 복사해 그룹원들을 모집해 봅시다!',
                                                                style: MyTextStyle
                                                                    .CbS18W400),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                        border300),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                              ),
                                                              child:
                                                                  SelectableText(
                                                                      quote),
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
                                                                          text:
                                                                              quote));
                                                                  setState(() =>
                                                                      isCopied =
                                                                          true);
                                                                },
                                                                child: !isCopied
                                                                    ? Text(
                                                                        '복사하기',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      )
                                                                    : Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                style:
                                                                    ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all<
                                                                              Color>(
                                                                          MyColors
                                                                              .purple300),
                                                                  shape: MaterialStateProperty
                                                                      .all<
                                                                          RoundedRectangleBorder>(
                                                                    RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16),
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
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        height: 16,
                                        width: 30,
                                      ),
                              ),
                            ],
                          ),
                  ),
                  Text(
                    group.name!,
                    softWrap: true,
                    style: TextStyle(
                      color: isThisGroupActivated
                          ? MyColors.purple300
                          : Colors.black,
                      fontSize: group.name!.length > 5 ? 10 : 12,
                      fontWeight: FontWeight.w600,
                    ),
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

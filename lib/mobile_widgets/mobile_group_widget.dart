import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/auth/presentation/sign_up_dialog.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/resources/storage_method.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/utils/utils.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/widgets/group_search_widget.dart';
import 'package:focus42/widgets/group_title_and_textfield_widget.dart';
import 'package:focus42/widgets/group_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MobileGroup extends ConsumerStatefulWidget {
  @override
  _MobileGroupState createState() => _MobileGroupState();
}

class _MobileGroupState extends ConsumerState<MobileGroup>
    with TickerProviderStateMixin {
  late final FirestoreDatabase database;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();
  final TextEditingController _invitePwController = TextEditingController();
  final _createGroupFormKey = GlobalKey<FormState>();
  final _invitementFormKey = GlobalKey<FormState>();
  Uint8List? _image;
  late String groupId;
  bool isCreateGroupLoading = false;
  bool isGroupNameOverlap = false; //null이면 아직 체크 안한거.
  String? invitedGroupId = Uri.base.queryParameters["g"];
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _showSignUpDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SignUpDialog();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    groupId = ref.read(activatedGroupIdProvider); //public이면 null return
    database = ref.read(databaseProvider);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _popupInvitedByOthersDialog(context, invitedGroupId));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _introductionController.dispose();
    _invitePwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    groupId = ref.read(activatedGroupIdProvider);
    return Container(
      // decoration: BoxDecoration(border: Border.all(width: 1)),
      width: 68,
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: TextButton(
              child: Icon(
                Icons.search,
                color: MyColors.purple300,
                size: 18,
              ),
              onPressed: () => _popupSearchGroupDialog(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(width: 1, color: MyColors.purple300),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: TextButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                if (uid != null) {
                  AnalyticsMethod().logPressGroupCreateButton();
                  _popupCreateGroupDialog(context);
                } else {
                  AnalyticsMethod().logPressGroupCreateButtonWithoutSignIn();
                  _showSignUpDialog();
                }
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(MyColors.purple300),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _popupSearchGroupDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GroupSearchAlertDialog();
        });
  }

  Widget _buildCreateGroupSuccess(BuildContext context, String groupName,
      String groupPassword, String groupDocId) {
    Uri uri = Uri.parse(Uri.base.toString());
    String quote = groupPassword != ''
        ? '귀하는 $groupName그룹에 초대되었습니다.\n아래 링크를 눌러 입장해주세요!\n 비밀번호: ${groupPassword} \n ${uri.origin}${uri.path}?g=$groupDocId'
        : '귀하는 $groupName그룹에 초대되었습니다.\n아래 링크를 눌러 입장해주세요!\n ${uri.origin}${uri.path}?g=$groupDocId';
    bool isCopied = false;
    return StatefulBuilder(
      builder: ((context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '멋있는 그룹이에요!',
              style: MyTextStyle.CbS26W600,
            ),
            Text('이제, 문구를 복사해 그룹원들을 모집해 봅시다!', style: MyTextStyle.CbS18W400),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: border300),
                borderRadius: BorderRadius.circular(16),
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
                  Clipboard.setData(ClipboardData(text: quote));
                  setState(() => isCopied = true);
                },
                child: !isCopied
                    ? Text(
                        '복사하기',
                        style: TextStyle(color: Colors.white),
                      )
                    : Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(MyColors.purple300),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  Future<dynamic> _popupCreateGroupDialog(BuildContext context) {
    bool isCreateGroupFinished = false;
    String groupName = '';
    String groupPassword = '';
    String groupDocId = '';

    List<String> hintTexts = ['그룹 명', '비밀번호(선택)', '그룹 소개(선택)'];
    List<TextEditingController> controllers = [
      _nameController,
      _passwordController,
      _introductionController,
    ];
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                width: 626,
                child: !isCreateGroupFinished
                    ? Form(
                        key: _createGroupFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 36,
                                height: 36,
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    _nameController.clear();
                                    _passwordController.clear();
                                    _introductionController.clear();
                                    setState(() {
                                      _image = null;
                                    });
                                    if (groupDocId != '') {
                                      _changeActivatedGroup(groupDocId);
                                      ref.refresh(myGroupIdFutureProvider);
                                    } else {
                                      Navigator.pop(context);
                                    }
                                    setState(() {});
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
                              '그룹 만들기',
                              style: MyTextStyle.CbS26W600,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Stack(
                              children: [
                                _image != null
                                    ? CircleAvatar(
                                        radius: 64,
                                        backgroundColor: Colors.black38,
                                        backgroundImage: MemoryImage(_image!),
                                      )
                                    : CircleAvatar(
                                        radius: 64,
                                        backgroundColor: Colors.black38,
                                        backgroundImage: NetworkImage(
                                            StorageMethods.defaultImageUrl),
                                      ),
                                Positioned(
                                  bottom: -10,
                                  left: 80,
                                  child: IconButton(
                                    onPressed: () async {
                                      Uint8List im =
                                          await pickImage(ImageSource.gallery);
                                      setState(() {
                                        _image = im;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add_a_photo,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            for (int i = 0; i < hintTexts.length; i++)
                              BuildTitleAndTextField(
                                  hintText: hintTexts[i],
                                  controller: controllers[i],
                                  index: i,
                                  isGroupNameOverlap:
                                      isGroupNameOverlap), //for 문 안쓰고 어케 하지??
                            SizedBox(
                              width: 140,
                              height: 45,
                              child: TextButton(
                                onPressed: () async {
                                  if (await database.findIfGroupNameOverlap(
                                      _nameController.text)) {
                                    setState(() {
                                      isGroupNameOverlap = true;
                                    });
                                  } else {
                                    setState(() {
                                      isGroupNameOverlap = false;
                                    });
                                  }
                                  if (_createGroupFormKey.currentState!
                                          .validate() &&
                                      isGroupNameOverlap == false) {
                                    setState(() {
                                      isCreateGroupLoading = true;
                                    });
                                    groupDocId = await createGroup(
                                      _nameController.text,
                                      _passwordController.text,
                                      _introductionController.text,
                                    );
                                    setState(() {
                                      isCreateGroupLoading = false;
                                      isCreateGroupFinished = true;
                                      groupName = _nameController.text;
                                      groupPassword = _passwordController.text;
                                    });
                                    _nameController.clear();
                                    _passwordController.clear();
                                    _introductionController.clear();
                                    setState(() {
                                      _image = null;
                                    });
                                  }
                                },
                                child: !isCreateGroupLoading
                                    ? Text(
                                        '그룹 만들기',
                                        style: MyTextStyle.CwS20W600,
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          MyColors.purple300),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  _changeActivatedGroup(groupDocId);
                                  ref.refresh(myGroupIdFutureProvider);
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
                          _buildCreateGroupSuccess(
                              context, groupName, groupPassword, groupDocId),
                        ],
                      ),
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
          );
        });
      },
    );
  }

  // Widget _buildSelectableMyGroupButton(BuildContext context, GroupModel group) {
  //   String groupName = group.name ?? '전체';
  //   int groupNameLength = groupName.length;
  //   return Container(
  //     width: groupNameLength * 10 + 68,
  //     height: 34,
  //     padding: EdgeInsets.all(0),
  //     child: TextButton(
  //       onPressed: () {
  //         _changeActivatedGroup(group.id!);
  //         Navigator.pop(context);
  //       },
  //       child: Row(
  //         children: [
  //           group.imageUrl != null
  //               ? ClipRRect(
  //                   borderRadius: BorderRadius.circular(10),
  //                   child: Image.network(
  //                     group.imageUrl!,
  //                     fit: BoxFit.cover,
  //                     width: 20,
  //                     height: 20,
  //                   ),
  //                 )
  //               : SizedBox.shrink(),
  //           Text(
  //             groupName,
  //             style: MyTextStyle.CwS16W400,
  //           ),
  //         ],
  //       ),
  //       style: ButtonStyle(
  //         backgroundColor: MaterialStateProperty.all<Color>(MyColors.purple300),
  //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
  //           RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<GroupModel?> checkGroupIdAndPw(String id, String? pw) async {
    GroupModel? group = await database.getGroup(id);
    pw ?? '';
    return pw != group.password ? null : group;
  }

  Future<dynamic>? _popupInvitedByOthersDialog(
    BuildContext context,
    String? groupId,
  ) async {
    if (groupId != null) {
      GroupModel? group = await database.getGroup(groupId);
      String? groupName = group.name;
      String? password = group.password;
      if (uid != null) {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: groupName != null
                  ? Container(
                      // width: 360,
                      child: Form(
                        key: _invitementFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Text(
                                    '초대장',
                                    style: MyTextStyle.CbS26W600,
                                  ),
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      onPressed: () {
                                        _invitePwController.clear();
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
                            password != ''
                                ? SizedBox.shrink()
                                : SizedBox(
                                    height: 40,
                                  ),
                            Text('귀하께서 $groupName그룹에 초대되었습니다.',
                                style: MyTextStyle.CbS14W400),
                            password != ''
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '비밀번호를 입력해주세요.',
                                        style: MyTextStyle.CbS14W400,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 300,
                                        child: TextFormField(
                                          controller: _invitePwController,
                                          cursorColor: Colors.black,
                                          validator: (value) {
                                            if (value != password) {
                                              return '비밀번호가 올바르지 않습니다.';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintStyle: MyTextStyle.CgS18W500,
                                            border: UnderlineInputBorder(
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
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.black,
                                                width: 1,
                                              ),
                                            ),
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            hintText: '비밀번호',
                                            errorStyle: TextStyle(
                                              fontSize: 10,
                                              height: 0.4,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    '가입하시겠습니까?',
                                    style: MyTextStyle.CbS14W400,
                                  ),
                            SizedBox(
                              height: password != '' ? 20 : 45,
                            ),
                            SizedBox(
                              height: 44,
                              width: 110,
                              child: TextButton(
                                onPressed: () {
                                  _invitePwController.clear();
                                  if (uid != null) {
                                    if (_invitementFormKey.currentState!
                                        .validate()) {
                                      Navigator.pop(context);
                                      enterGroup(group);
                                    }
                                  } else {
                                    _showSignUpDialog();
                                  }
                                },
                                child: Text(
                                  '가입하기',
                                  style: MyTextStyle.CwS20W600,
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          MyColors.purple300),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
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
                    )
                  : Container(
                      child: Text('잘못된 링크입니다!'),
                    ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
            );
          },
        );
      } else {
        _showSignUpDialog();
      }
    } else {
      return null;
    }
  }

  Future<String> createGroup(
    String name,
    String password,
    String introduction,
  ) async {
    final createdGroup = GroupModel.newGroup(
      uid: database.uid,
      name: name,
      imageUrl: StorageMethods.defaultImageUrl,
      introduction: introduction,
      password: password,
    );
    final UserModel? user = await ref.read(userStreamProvider.future);
    final String groupDocId = await database.setGroup(createdGroup);

    if (_image != null) {
      final String dateString =
          DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      final String newImageUrl = await StorageMethods().uploadImageToStorage(
          'groupPics/${groupDocId}/${dateString}', _image!);
      await database.setGroup(createdGroup.changeImageAndPutId(
          docId: groupDocId,
          newImageUrl: newImageUrl,
          newUpdatedBy: database.uid));
    }
    database.setUserPublic(user!.userPublicModel!.addGroup(groupDocId));
    return groupDocId;
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
              height: 125,
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 36,
                        ),
                        Text(
                          '그룹 가입',
                          style: MyTextStyle.CbS20W600,
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              Get.rootDelegate
                                  .toNamed(DynamicRoutes.CALENDAR());
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
                  Text(
                    '이미 가입한 그룹입니다!',
                    style: MyTextStyle.CbS18W400,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 40,
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
      database.setGroup(group.addMember(database.uid));
      database.setUserPublic(user!.userPublicModel!.addGroup(group.id!));
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
                    '수고하셨습니다',
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

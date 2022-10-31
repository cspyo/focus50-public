import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/auth/show_auth_dialog.dart';
import 'package:focus42/feature/indicator/circular_progress_indicator.dart';
import 'package:focus42/feature/jitsi/presentation/list_items_builder_2.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/storage_method.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/utils/utils.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/widgets/group_search_widget.dart';
import 'package:focus42/widgets/group_select_dialog_widget.dart';
import 'package:focus42/widgets/group_setting_widget.dart';
import 'package:focus42/widgets/group_title_and_textfield_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

final myGroupIdFutureProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final database = ref.watch(databaseProvider);
  final UserPublicModel userPublic = await database.getUserPublic();
  List<String> groups = [];
  if (userPublic.groups != null) groups = userPublic.groups!;
  return groups;
});

final myGroupFutureProvider =
    FutureProvider.autoDispose<List<GroupModel>>((ref) async {
  final database = ref.watch(databaseProvider);
  final List<String> myGroupIds =
      await ref.watch(myGroupIdFutureProvider.future);
  final List<GroupModel> result = [];
  await Future.forEach(myGroupIds, (String groupId) async {
    result.add(await database.getGroup(groupId));
  });
  return result;
});

class Group extends ConsumerStatefulWidget {
  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends ConsumerState<Group> {
  late FirestoreDatabase database;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();
  final TextEditingController _invitePwController = TextEditingController();
  final _createGroupFormKey = GlobalKey<FormState>();
  final _invitementFormKey = GlobalKey<FormState>();
  Uint8List? _image;
  late String groupId;
  bool isCreateGroupLoading = false;
  bool isGroupNameOverlap = false;
  String? invitedGroupId = Uri.base.queryParameters["g"];
  String? uid = FirebaseAuth.instance.currentUser?.uid;

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
    database = ref.watch(databaseProvider);
    uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      // padding: EdgeInsets.only(left: 8, right: 8),
      // decoration: BoxDecoration(
      //     border: Border(right: BorderSide(color: border100, width: 1))),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 40,
                  child: Text(
                    '그룹',
                    style: MyTextStyle.CbS20W600,
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 30,
                  child: TextButton(
                    onPressed: () {
                      _popupSearchGroupDialog(context); //TODO: GA 달기
                    },
                    child: Icon(
                      Icons.search,
                      color: MyColors.purple300,
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.zero),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(width: 1, color: MyColors.purple300),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildColumnGroupToggleButton(context),
          SizedBox(
            width: 80,
            height: 30,
            child: TextButton(
              onPressed: () {
                if (uid != null) {
                  AnalyticsMethod().logPressGroupCreateButton();
                  _popupCreateGroupDialog(context);
                } else {
                  AnalyticsMethod().logPressGroupCreateButtonWithoutSignIn();
                  ShowAuthDialog().showSignUpDialog(context);
                }
              },
              child: Icon(
                Icons.add,
                size: 24,
                color: Colors.white,
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(MyColors.purple300),
                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          // Spacer(),
        ],
      ),
    );
  }

  Widget _buildColumnGroupToggleButton(BuildContext context) {
    final _myGroupStream = ref.watch(myGroupFutureProvider);
    final _myActivatedGroupId = ref.watch(activatedGroupIdProvider);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletSize = screenWidth < 1200 ? true : false;
    return SizedBox(
      width: 80,
      height: isTabletSize ? screenHeight - 362 : screenHeight - 267,
      child: ListItemsBuilder2<GroupModel>(
        data: _myGroupStream,
        itemBuilder: (context, model) => _buildToggleButtonUi(
          context,
          model,
          _myActivatedGroupId == model.id ? true : false,
        ),
        // itemBuilder: (context, model) => Text('${model.id}}'),
        creator: () => new GroupModel(
          id: 'public',
          name: '전체',
        ),
        axis: Axis.vertical,
      ),
      // child: Text('없어열'),
    );
  }

  // Widget _buildMyGroupIndicator(BuildContext context, String groupId) {
  //   final _myGroupStream = ref.watch(myActivatedGroupFutureProvider);
  //   return _myGroupStream.when(
  //     data: (data) => _buildToggleButtonUi(context, data),
  //     loading: () => const Center(
  //         child: CircularProgressIndicator(
  //       color: MyColors.purple300,
  //     )),
  //     error: (_, __) => EmptyContent(
  //       title: '오류가 발생하였습니다',
  //     ),
  //   );
  // }

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
          mainAxisSize: MainAxisSize.min,
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
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
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

  Widget _buildToggleButtonUi(
      BuildContext context, GroupModel group, bool isThisGroupActivated) {
    return Stack(
      children: [
        Container(
          child: TextButton(
            onPressed: () {
              _changeActivatedGroup(group.id!);
            },
            style: isThisGroupActivated
                ? ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(MyColors.purple100),
                    padding:
                        MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
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
                  SizedBox(
                    height: 5,
                  ),
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
                  SizedBox(
                    height: 5,
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
                  SizedBox(
                    height: 5,
                  ),
                  isThisGroupActivated && group.id != 'public'
                      ? SizedBox(
                          height: 22,
                          width: 38,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  MyColors.purple300),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.zero),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Uri uri = Uri.parse(Uri.base.toString());
                              String quote = group.password != ''
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
                                                    padding:
                                                        MaterialStateProperty
                                                            .all<EdgeInsets>(
                                                                EdgeInsets
                                                                    .zero),
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
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 5,
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

  Future<dynamic> _popupCreateGroupDialog(BuildContext context) {
    bool isCreateGroupFinished = false;
    String groupName = '';
    String groupPassword = '';
    String groupDocId = '';

    List<String> hintTexts = ['그룹 명', '비밀번호(선택)', '그룹 소개(선택)'];
    List<TextEditingController> controllers = [
      _nameController,
      _passwordController,
      _introductionController
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
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                    ),
                                    child: TextButton(
                                      onPressed: () async {
                                        Uint8List im = await pickImage(
                                            ImageSource.gallery);
                                        setState(() {
                                          _image = im;
                                        });
                                      },
                                      child: Center(
                                        child: const Icon(
                                          Icons.add_a_photo,
                                          color: Colors.black,
                                          size: 16,
                                        ),
                                      ),
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
                                isGroupNameOverlap: isGroupNameOverlap,
                                isAbleToModify: true,
                              ),
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
                                    : CircularIndicator(
                                        size: 22, color: Colors.white),
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
                                  _changeActivatedGroup(groupDocId);
                                  ref.refresh(myGroupIdFutureProvider);
                                  debugPrint("[DEBUG] onPressed / $groupDocId");
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

  Future<dynamic> _popupInviteOthersDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GroupSelectAlertDialog();
        });
  }

  Future<dynamic> _popupSearchGroupDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GroupSearchAlertDialog();
        });
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
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: groupName != null
                ? Container(
                    child: Form(
                      key: _invitementFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      Get.rootDelegate
                                          .offNamed(Routes.CALENDAR);
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
                          SizedBox(
                            height: 10,
                          ),
                          Text('귀하께서 $groupName그룹에 초대되었습니다.',
                              style: MyTextStyle.CbS14W400),
                          password != ''
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _invitePwController,
                                    validator: (_) {
                                      if (_invitePwController.text !=
                                          password) {
                                        return '비밀번호가 올바르지 않습니다.';
                                      }
                                      return null;
                                    },
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
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
                                          borderSide:
                                              BorderSide(color: purple300)),
                                      labelText: '비밀번호',
                                      floatingLabelStyle: TextStyle(
                                        color: purple300,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    maxLines: 1,
                                  ),
                                )
                              : Text(
                                  '가입하시겠습니까?',
                                  style: MyTextStyle.CbS14W400,
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 44,
                            width: 110,
                            child: TextButton(
                              onPressed: () {
                                if (uid != null) {
                                  if (_invitementFormKey.currentState!
                                      .validate()) {
                                    enterGroup(group);
                                  }
                                  _invitePwController.clear();
                                } else {
                                  ShowAuthDialog().showSignUpDialog(context);
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
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.zero),
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
    await database.updateUser(
        UserModel(user!.userPublicModel!.addGroup(groupDocId), null));
    return groupDocId;
  }

  Future<dynamic> enterGroup(
    GroupModel group,
  ) async {
    if (group.memberUids!.contains(database.uid)) {
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
                    height: 40,
                    child: TextButton(
                      onPressed: () {
                        Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR());
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        '확인',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            MyColors.purple300),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.zero),
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
                    height: 46,
                    child: TextButton(
                      onPressed: () {
                        _changeActivatedGroup(group.id!);
                        ref.refresh(myGroupIdFutureProvider);
                        Get.rootDelegate.toNamed(DynamicRoutes.CALENDAR());
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        '확인',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            MyColors.purple300),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.zero),
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

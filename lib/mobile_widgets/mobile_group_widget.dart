import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/feature/jitsi/presentation/empty_content.dart';
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
import 'package:focus42/widgets/group_select_dialog_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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

class MobileGroup extends ConsumerStatefulWidget {
  @override
  _MobileGroupState createState() => _MobileGroupState();
}

class _MobileGroupState extends ConsumerState<MobileGroup> {
  late final FirestoreDatabase database;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _maxHeadcountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();
  final TextEditingController _invitePwController = TextEditingController();
  final _createGroupFormKey = GlobalKey<FormState>();
  final _invitementFormKey = GlobalKey<FormState>();
  Uint8List? _image;
  late String groupId;
  bool isCreateGroupLoading = false;
  bool? isGroupNameOverlap; //null이면 아직 체크 안한거.
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
    _categoryController.dispose();
    _maxHeadcountController.dispose();
    _passwordController.dispose();
    _introductionController.dispose();
    _invitePwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    groupId = ref.read(activatedGroupIdProvider);
    return Container(
      width: 46,
      height: 46,
      child: TextButton(
        onPressed: () {
          if (uid != null) {
            AnalyticsMethod().logPressGroupSelectButton();
            _popupInviteOthersDialog(context);
          } else {
            AnalyticsMethod().logPressGroupSelectButtonWithoutSignIn();
            Get.rootDelegate.toNamed(Routes.SIGNUP);
          }
        },
        child: Text(
          '그룹',
          style: MyTextStyle.CwS12W600,
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(MyColors.purple300),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(23),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildGroupToggleButton(BuildContext context) {
  //   // TODO: 1. ListItemBuilder empty 케이스 일반화하기 / 2. itemBuilder 수정하기
  //   final _myGroupStream = ref.watch(myGroupFutureProvider);
  //   return ListItemsBuilder<GroupModel>(
  //     data: _myGroupStream,
  //     itemBuilder: (context, model) => _buildToggleButtonUi(context, model),
  //     axis: Axis.horizontal,
  //   );
  // }

  Widget _buildMyGroupIndicator(BuildContext context, String groupId) {
    final _myGroupStream = ref.watch(myActivatedGroupFutureProvider);
    return _myGroupStream.when(
      data: (data) => _buildToggleButtonUi(context, data),
      loading: () => const Center(
          child: CircularProgressIndicator(
        color: MyColors.purple300,
      )),
      error: (_, __) => EmptyContent(
        title: '오류가 발생하였습니다',
      ),
    );
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

  Widget _buildToggleButtonUi(BuildContext context, GroupModel group) {
    String groupName = group.name ?? '전체';
    return Container(
      width: group.id == 'public' ? 46 : 84 + groupName.length * 11,
      height: 34,
      child: TextButton(
        onPressed: () {
          _changeActivatedGroup(group.id!);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(MyColors.purple100),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: MyColors.purple300, width: 1),
            ),
          ),
        ),
        child: Container(
          child: Row(
            children: [
              group.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        group.imageUrl!,
                        fit: BoxFit.cover,
                        width: 20,
                        height: 20,
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                width: 4,
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
                width: 4,
              ),
              groupName != '전체'
                  ? SizedBox(
                      height: 22,
                      width: 38,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              MyColors.purple300),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        onPressed: () {
                          String quote = group.password != ''
                              ? '귀하는 ${groupName}그룹에 초대되었습니다.\n아래 링크를 눌러 입장해주세요!\n 비밀번호 : ${group.password} \n ${Uri.base}?g=${group.id}' //TODO: 여기 필요하면 바꿔야 함!!
                              : '귀하는 ${groupName}그룹에 초대되었습니다.\n아래 링크를 눌러 입장해주세요!\n ${Uri.base}?g=${group.id}';
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
                                            alignment: Alignment.centerRight,
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
                                                  width: 1, color: border300),
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
                                                    ClipboardData(text: quote));
                                                setState(() => isCopied = true);
                                              },
                                              child: !isCopied
                                                  ? Text(
                                                      '복사하기',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )
                                                  : Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                    ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                            Color>(
                                                        MyColors.purple300),
                                                shape:
                                                    MaterialStateProperty.all<
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndTextField(
    BuildContext context,
    String title,
    String hintText,
    TextEditingController _controller,
    int index,
  ) {
    return Container(
      width: 410,
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MyColors.border300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: MyTextStyle.CbS18W400,
            ),
          ),
          Container(
            width: 244,
            height: 36,
            padding: EdgeInsets.only(left: 8, right: 8),
            child: TextFormField(
              inputFormatters: <TextInputFormatter>[
                index == 2
                    ? FilteringTextInputFormatter.digitsOnly
                    : FilteringTextInputFormatter.singleLineFormatter,
              ],
              validator: (value) {
                return (value == null || value.isEmpty) && index != 3
                    ? '$title를 입력해주세요'
                    : index == 0 && isGroupNameOverlap!
                        ? '이미 있는 그룹명입니다. 다른 이름을 적어주세요'
                        : index == 0 && value!.length > 12
                            ? '12자 이내의 이름을 적어주세요'
                            : null;
              },
              controller: _controller,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintStyle: MyTextStyle.CgS18W500,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: hintText,
                errorStyle: TextStyle(
                  fontSize: 10,
                  height: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _popupCreateGroupDialog(BuildContext context) {
    bool isCreateGroupFinished = false;
    String groupName = '';
    String groupPassword = '';
    String groupDocId = '';
    List<String> titles = [
      '그룹 명',
      '카테고리',
      '최대 구성원 수',
      '비밀번호',
    ];
    List<String> hintTexts = [
      '그룹 명을 적어주세요',
      '카테고리를 입력해주세요',
      '10(숫자만 입력해주세요)',
      '비밀번호(선택)',
    ];
    List<TextEditingController> controllers = [
      _nameController,
      _categoryController,
      _maxHeadcountController,
      _passwordController,
    ];
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Container(
              width: 626,
              height: !isCreateGroupFinished ? 800 : 300,
              child: !isCreateGroupFinished
                  ? Form(
                      key: _createGroupFormKey,
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
                                  if (groupDocId != '') {
                                    _changeActivatedGroup(groupDocId);
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
                                          'https://firebasestorage.googleapis.com/v0/b/focus-50.appspot.com/o/profilePics%2Fuser.png?alt=media&token=69e13fc9-b2ea-460c-98e0-92fe6613461e'),
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
                          for (int i = 0; i < titles.length; i++)
                            _buildTitleAndTextField(
                                context,
                                titles[i],
                                hintTexts[i],
                                controllers[i],
                                i), //for 문 안쓰고 어케 하지??
                          // _buildCategoryField(context),
                          Container(
                            width: 410,
                            height: 50,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '그룹 소개 및 공지',
                              style: MyTextStyle.CbS18W400,
                            ),
                          ),
                          Container(
                            width: 410,
                            height: 86,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: MyColors.border300,
                                ),
                                borderRadius: BorderRadius.circular(16)),
                            padding: EdgeInsets.only(left: 8, right: 8),
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              cursorColor: Colors.black,
                              controller: _introductionController,
                              decoration: InputDecoration(
                                  hintStyle: MyTextStyle.CgS18W500,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: "그룹에 대해 소개해 주세요!"),
                            ),
                          ),
                          SizedBox(
                            height: 30,
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
                                    _categoryController.text,
                                    int.parse(_maxHeadcountController.text),
                                    _passwordController.text,
                                    _introductionController.text,
                                  );
                                  setState(() {
                                    isCreateGroupLoading = false;
                                    isCreateGroupFinished = true;
                                    groupName = _nameController.text;
                                    groupPassword = _passwordController.text;
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
                      height: 216,
                      child: Form(
                        key: _invitementFormKey,
                        child: Column(
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
                            Text(' 귀하께서 $groupName그룹에 초대되었습니다.',
                                style: MyTextStyle.CbS14W400),
                            password != ''
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                  if (uid != null) {
                                    if (_invitementFormKey.currentState!
                                        .validate()) {
                                      Navigator.pop(context);
                                      enterGroup(group);
                                    }
                                  } else {
                                    Get.rootDelegate.toNamed(Routes.SIGNUP,
                                        arguments: true,
                                        parameters: {'g': group.id!});
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
        Get.rootDelegate.toNamed(Routes.SIGNUP,
            arguments: true, parameters: {'g': group.id!});
      }
    } else {
      return null;
    }
  }

  Future<String> createGroup(
    String name,
    String category,
    int maxHeadcount,
    String password,
    String introduction,
  ) async {
    late final String groupDocId;
    final String imageUrl = (_image == null)
        ? 'https://firebasestorage.googleapis.com/v0/b/focus50-8b405.appspot.com/o/profilePics%2Fuser.png?alt=media&token=f3d3b60c-55f8-4576-bfab-e219d9c225b3'
        : await StorageMethods().uploadImageToStorage('profilePics', _image!);

    final createdGroup = GroupModel.newGroup(
      uid: database.uid,
      name: name,
      category: category,
      imageUrl: imageUrl,
      maxHeadcount: maxHeadcount,
      introduction: introduction,
      password: password,
    );
    final UserModel? user = await ref.read(userStreamProvider.future);
    groupDocId = await database.setGroup(createdGroup);
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
      if (group.headcount! < group.maxHeadcount!) {
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
                      '정원이 모두 찼습니다.',
                      style: MyTextStyle.CbS18W400,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
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
      }
    }
  }

  void _changeActivatedGroup(String newGroupId) {
    ref.read(activatedGroupIdProvider.notifier).state = newGroupId;
  }
}

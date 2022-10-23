import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/storage_method.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/utils.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:image_picker/image_picker.dart';

Future<void> leaveGroup(FirestoreDatabase database, String docId) async {
  database.runTransaction((transaction) async {
    final GroupModel myGroup = await database.getGroupInTransaction(
        docId: docId, transaction: transaction);
    database.updateGroupInTransaction(
        myGroup.removeMember(database.uid), transaction);
    final UserPublicModel myUser = await database.getUserPublic();
    database.setUserPublic(myUser.leaveGroup(docId));
  });
}

Future<void> modifyGroup({
  required FirestoreDatabase database,
  required GroupModel group,
  required String newName,
  required String newImageUrl,
  required int newMaxHeadcount,
  required String newPassword,
  required String newIntroduction,
}) async {
  final String groupId = group.id!;
  database.runTransaction((transaction) async {
    final GroupModel myGroup = await database.getGroupInTransaction(
        docId: groupId, transaction: transaction);
    database.updateGroupInTransaction(
        myGroup.modifyInfo(
          newName: newName,
          newImageUrl: newImageUrl,
          newMaxHeadcount: newMaxHeadcount,
          newPassword: newPassword,
          newIntroduction: newIntroduction,
          newUpdatedBy: database.uid,
        ),
        transaction);
  });
}

class GroupSettingAlertDialog extends ConsumerStatefulWidget {
  final FirestoreDatabase database;
  final GroupModel group;

  const GroupSettingAlertDialog(
      {Key? key, required this.database, required this.group})
      : super(key: key);
  @override
  _GroupSettingAlertDialogState createState() =>
      _GroupSettingAlertDialogState();
}

class _GroupSettingAlertDialogState
    extends ConsumerState<GroupSettingAlertDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _maxHeadcountController;
  late final TextEditingController _passwordController;
  late final TextEditingController _introductionController;
  late final database;
  Uint8List? _image;
  late String currentGroupImageUrl;
  bool? isGroupNameOverlap; //null이면 아직 체크 안한거.
  bool isUserCreator = false;

  @override
  void initState() {
    super.initState();

    currentGroupImageUrl = widget.group.imageUrl!;
    _nameController = TextEditingController(text: widget.group.name);
    _maxHeadcountController =
        TextEditingController(text: widget.group.maxHeadcount.toString());
    _passwordController = TextEditingController(text: widget.group.password);
    _introductionController =
        TextEditingController(text: widget.group.introduction);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    database = ref.watch(databaseProvider);
    isUserCreator = widget.group.createdBy == database.uid ? true : false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxHeadcountController.dispose();
    _passwordController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> titles = [
      '그룹 명',
      '최대 구성원 수',
      '비밀번호',
    ];
    List<String> hintTexts = [
      '그룹 명을 적어주세요',
      '10(숫자만 입력해주세요)',
      '비밀번호(선택)',
    ];
    List<TextEditingController> controllers = [
      _nameController,
      _maxHeadcountController,
      _passwordController,
    ];
    return StatefulBuilder(builder: (parentContext, setState) {
      return SizedBox(
          width: 250,
          child: AlertDialog(
              content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 36,
                ),
                Text('그룹 설정', style: MyTextStyle.CbS20W600),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      Navigator.pop(parentContext);
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
            SizedBox(
              height: 10,
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
                        backgroundImage: NetworkImage(currentGroupImageUrl),
                      ),
                Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: () async {
                      if (isUserCreator) {
                        Uint8List im = await pickImage(ImageSource.gallery);
                        setState(() {
                          _image = im;
                        });
                      } else {
                        showDialog(
                            context: parentContext,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: SizedBox(
                                  width: 240,
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 36,
                                            ),
                                            Text('권한이 없습니다',
                                                style: MyTextStyle.CbS20W600),
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
                                        Text(
                                          '그룹 관리자만 정보를 수정할 수 있습니다.',
                                          style: MyTextStyle.CbS14W400,
                                        ),
                                      ]),
                                ),
                              );
                            });
                      }
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
              _buildTitleAndTextField(parentContext, titles[i], hintTexts[i],
                  controllers[i], i), //for 문 안쓰고 어케 하지??
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
                enabled: isUserCreator,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isUserCreator
                    ? SizedBox(
                        width: 120,
                        height: 40,
                        child: TextButton(
                          onPressed: () async {
                            final String imageUrl = (_image == null)
                                ? widget.group.imageUrl!
                                : await StorageMethods().uploadImageToStorage(
                                    'profilePics', _image!);
                            modifyGroup(
                              database: widget.database,
                              group: widget.group,
                              newName: _nameController.text,
                              newImageUrl: imageUrl,
                              newMaxHeadcount:
                                  int.parse(_maxHeadcountController.text),
                              newIntroduction: _introductionController.text,
                              newPassword: _passwordController.text,
                            );
                            Navigator.pop(parentContext);
                            setState(() {});
                          },
                          child: Text(
                            '그룹 정보 수정',
                            style: MyTextStyle.CpS12W600,
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                side: BorderSide(
                                    color: MyColors.purple300, width: 1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 100,
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                          context: parentContext,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: SizedBox(
                                width: 260,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '정말 ${widget.group.name} 그룹을 나가시겠습니까?',
                                        style: MyTextStyle.CbS16W400,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 36,
                                            child: TextButton(
                                              onPressed: () {
                                                leaveGroup(
                                                    database, widget.group.id!);
                                                Navigator.pop(context);
                                                Navigator.pop(parentContext);
                                              },
                                              child: Text(
                                                '나가기',
                                                style: MyTextStyle.CwS16W400,
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
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            height: 36,
                                            child: TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                '나가지 않기',
                                                style: MyTextStyle.CpS16W400,
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.white),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        color:
                                                            MyColors.purple300),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                            );
                          });
                    },
                    child: Text(
                      '그룹 나가기',
                      style: MyTextStyle.CwS12W600,
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ])));
    });
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
              enabled: isUserCreator,
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

  void _changeActivatedGroup(String newGroupId) {
    ref.read(activatedGroupIdProvider.notifier).state = newGroupId;
  }
}

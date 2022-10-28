import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/indicator/circular_progress_indicator.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/storage_method.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/utils.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/widgets/group_title_and_textfield_widget.dart';
import 'package:focus42/widgets/group_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

Future<void> leaveGroup(
    FirestoreDatabase database, UserModel user, String docId) async {
  database.runTransaction((transaction) async {
    final GroupModel myGroup = await database.getGroupInTransaction(
        docId: docId, transaction: transaction);
    database.updateGroupInTransaction(
        myGroup.removeMember(database.uid), transaction);
    final UserPublicModel myUser = await database.getUserPublic();
  });
  await database
      .updateUser(UserModel(user.userPublicModel!.leaveGroup(docId), null));
}

Future<void> modifyGroup({
  required FirestoreDatabase database,
  required GroupModel group,
  required String newName,
  required String newImageUrl,
  required String newPassword,
  required String newIntroduction,
}) async {
  final String groupId = group.id!;
  await database.runTransaction((transaction) async {
    final GroupModel myGroup = await database.getGroupInTransaction(
        docId: groupId, transaction: transaction);
    database.updateGroupInTransaction(
        myGroup.modifyInfo(
          newName: newName,
          newImageUrl: newImageUrl,
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
  late final TextEditingController _passwordController;
  late final TextEditingController _introductionController;
  late final database;
  Uint8List? _image;
  final _modifyGroupFormKey = GlobalKey<FormState>();
  late String currentGroupImageUrl;
  bool isGroupNameOverlap = false;
  bool isUserCreator = false;
  bool isModifyLoading = false;
  bool isLeaveLoading = false;

  @override
  void initState() {
    super.initState();

    currentGroupImageUrl = widget.group.imageUrl!;
    _nameController = TextEditingController(text: widget.group.name);
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
    _passwordController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> hintTexts = ['그룹 명', '비밀번호(선택)', '그룹 소개(선택)'];
    List<TextEditingController> controllers = [
      _nameController,
      _passwordController,
      _introductionController,
    ];
    return StatefulBuilder(builder: (parentContext, setState) {
      return SizedBox(
          width: 250,
          child: AlertDialog(
              content: SingleChildScrollView(
            child: Form(
              key: _modifyGroupFormKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            Uint8List im = await pickImage(ImageSource.gallery);
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
                      isGroupNameOverlap: isGroupNameOverlap),
                StatefulBuilder(
                  builder: ((context, setState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isUserCreator
                            ? SizedBox(
                                width: 120,
                                height: 40,
                                child: TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      isModifyLoading = true;
                                    });
                                    if (_nameController.text !=
                                            widget.group.name &&
                                        await database.findIfGroupNameOverlap(
                                            _nameController.text)) {
                                      setState(() {
                                        isGroupNameOverlap = true;
                                      });
                                    } else {
                                      setState(() {
                                        isGroupNameOverlap = false;
                                      });
                                    }
                                    final String dateString =
                                        DateFormat('yyyyMMddHHmmss')
                                            .format(DateTime.now());
                                    final String imageUrl = (_image == null)
                                        ? widget.group.imageUrl!
                                        : await StorageMethods()
                                            .uploadImageToStorage(
                                                'groupPics/${widget.group.id}/${dateString}',
                                                _image!);
                                    if (_modifyGroupFormKey.currentState!
                                            .validate() &&
                                        isGroupNameOverlap == false) {
                                      await modifyGroup(
                                        database: widget.database,
                                        group: widget.group,
                                        newName: _nameController.text,
                                        newImageUrl: imageUrl,
                                        newIntroduction:
                                            _introductionController.text,
                                        newPassword: _passwordController.text,
                                      );
                                      ref.refresh(myGroupFutureProvider);
                                      Navigator.pop(parentContext);
                                    }
                                    setState(() {
                                      isModifyLoading = false;
                                    });
                                  },
                                  child: isModifyLoading
                                      ? CircularIndicator(
                                          size: 22, color: MyColors.purple300)
                                      : Text(
                                          '그룹 정보 수정',
                                          style: MyTextStyle.CpS12W600,
                                        ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: MyColors.purple300,
                                            width: 1),
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
                                        child: StatefulBuilder(
                                          builder: ((context, setState) {
                                            return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '정말 ${widget.group.name} 그룹을 나가시겠습니까?',
                                                    style:
                                                        MyTextStyle.CbS16W400,
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        height: 36,
                                                        child: TextButton(
                                                          onPressed: () async {
                                                            setState(() {
                                                              isLeaveLoading =
                                                                  true;
                                                            });
                                                            final UserModel?
                                                                user =
                                                                await ref.read(
                                                                    userStreamProvider
                                                                        .future);
                                                            await leaveGroup(
                                                                database,
                                                                user!,
                                                                widget
                                                                    .group.id!);
                                                            _changeActivatedGroup(
                                                                'public');
                                                            ref.refresh(
                                                                myGroupIdFutureProvider);
                                                            setState(() {
                                                              isLeaveLoading =
                                                                  false;
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                parentContext);
                                                          },
                                                          child: isLeaveLoading
                                                              ? CircularIndicator(
                                                                  size: 22,
                                                                  color: MyColors
                                                                      .purple300)
                                                              : Text(
                                                                  '나가기',
                                                                  style: MyTextStyle
                                                                      .CwS16W400,
                                                                ),
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                                        MyColors
                                                                            .purple300),
                                                            shape: MaterialStateProperty
                                                                .all<
                                                                    RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
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
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text(
                                                            '나가지 않기',
                                                            style: MyTextStyle
                                                                .CpS16W400,
                                                          ),
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                                        Colors
                                                                            .white),
                                                            shape: MaterialStateProperty
                                                                .all<
                                                                    RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                side: BorderSide(
                                                                    width: 1,
                                                                    color: MyColors
                                                                        .purple300),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]);
                                          }),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Text(
                              '그룹 나가기',
                              style: MyTextStyle.CwS12W600,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  MyColors.purple300),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                )
              ]),
            ),
          )));
    });
  }

  void _changeActivatedGroup(String newGroupId) {
    ref.read(activatedGroupIdProvider.notifier).state = newGroupId;
  }
}

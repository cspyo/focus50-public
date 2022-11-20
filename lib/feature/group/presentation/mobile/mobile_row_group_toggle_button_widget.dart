import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/feature/calendar/view_model/reservation_view_model.dart';
import 'package:focus50/feature/group/data/group_model.dart';
import 'package:focus50/feature/group/presentation/mobile/mobile_group_setting_widget.dart';
import 'package:focus50/services/firestore_database.dart';
import 'package:focus50/top_level_providers.dart';

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
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              group.imageUrl!,
                              fit: BoxFit.cover,
                              width: 38,
                              height: 38,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/earth.png',
                              fit: BoxFit.cover,
                              width: 38,
                              height: 38,
                            ),
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
                top: 1,
                left: 1,
                child: SizedBox(
                  width: 18,
                  height: 18,
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
                      size: 18,
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
          return MobileGroupSettingAlertDialog(
              database: database, group: group);
        });
  }

  void _changeActivatedGroup(String newGroupId) {
    ref.read(activatedGroupIdProvider.notifier).state = newGroupId;
  }
}

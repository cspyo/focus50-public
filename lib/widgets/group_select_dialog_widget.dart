import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/jitsi/presentation/list_items_builder_2.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/widgets/group_widget.dart';

class GroupSelectAlertDialog extends ConsumerWidget {
  const GroupSelectAlertDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _myGroupStream = ref.watch(myGroupFutureProvider);
    return SizedBox(
      width: 250,
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        content: Container(
          padding: EdgeInsets.zero,
          width: 250,
          height: 560,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 300,
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
                      Text('그룹을 선택해주세요!', style: MyTextStyle.CbS18W400),
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
                  width: 250,
                  padding: EdgeInsets.all(10),
                  height: 500,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(16)),
                  ),
                  child: ListItemsBuilder2<GroupModel>(
                    data: _myGroupStream,
                    itemBuilder: (context, model) => Align(
                        alignment: Alignment.topLeft,
                        child: _buildToggleButtonUi(context, model, ref)),
                    creator: () => new GroupModel(),
                    axis: Axis.vertical,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtonUi(
      BuildContext context, GroupModel group, WidgetRef ref) {
    String _activatedGroupId = ref.read(activatedGroupIdProvider);
    String groupName = group.name ?? '전체';
    String groupId = group.id ?? 'public';
    bool isThisGroupSelected = groupId == _activatedGroupId ? true : false;
    return Container(
      // width: group.id == 'public'
      //     ? 18 + groupNameLength * 11
      //     : 86 + groupNameLength * 11,
      height: 44,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: TextButton(
              onPressed: () {
                _changeActivatedGroup(group.id ?? 'public', ref);
                group.id == null
                    ? AnalyticsMethod().logPressPublicGroupButton()
                    : AnalyticsMethod().logPressPrivateGroupButton();
                Navigator.pop(context);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    isThisGroupSelected ? MyColors.purple100 : Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isThisGroupSelected
                          ? MyColors.purple300
                          : Colors.transparent,
                      width: 1,
                    ),
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
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/earth.png',
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
                      group.headcount != null
                          ? '${group.headcount} / ${group.maxHeadcount}'
                          : '모든 유저와 함께',
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

  void _changeActivatedGroup(String newGroupId, WidgetRef ref) {
    ref.read(activatedGroupIdProvider.notifier).state = newGroupId;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/utils/circular_progress_indicator.dart';
import 'package:focus50/feature/jitsi/presentation/empty_content.dart';
import 'package:focus50/feature/group/data/group_model.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);
typedef ItemCreator<T> = T Function();

class ListItemsBuilder2<T> extends ConsumerWidget {
  const ListItemsBuilder2(
      {Key? key,
      required this.data,
      required this.itemBuilder,
      required this.creator,
      required this.axis})
      : super(key: key);
  final AsyncValue<List<T>> data;
  final ItemWidgetBuilder<T> itemBuilder;
  final ItemCreator<T> creator;
  final Axis axis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return data.when(
      data: (items) => _buildList(items),
      loading: () => CircularIndicator(size: 22, color: MyColors.purple300),
      error: (_, __) => EmptyContent(
        title: '오류가 발생하였습니다',
        message: T == GroupModel ? '' : '전체 미션을 받아올 수 없습니다',
      ),
    );
  }

  Widget _buildList(List<T> items) {
    T t = creator();
    return ListView.separated(
      scrollDirection: axis,
      itemCount: items.length + 1,
      separatorBuilder: (context, index) => const Divider(
        height: 10,
        color: MyColors.border300,
      ),
      itemBuilder: (context, index) {
        if (index == 0) return itemBuilder(context, t);
        return itemBuilder(context, items[index - 1]);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/consts/colors.dart';
import 'package:focus50/utils/circular_progress_indicator.dart';
import 'package:focus50/feature/jitsi/presentation/empty_content.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemsBuilder1<T> extends ConsumerWidget {
  const ListItemsBuilder1({
    Key? key,
    required this.data,
    required this.itemBuilder,
  }) : super(key: key);
  final AsyncValue<List<T>> data;
  final ItemWidgetBuilder<T> itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return data.when(
      data: (items) =>
          items.isNotEmpty ? _buildList(items) : const EmptyContent(),
      loading: () => CircularIndicator(size: 20, color: MyColors.purple300),
      error: (_, __) => const EmptyContent(
        title: '오류가 발생하였습니다',
        message: '전체 미션을 받아올 수 없습니다',
      ),
    );
  }

  Widget _buildList(List<T> items) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(
        height: 10,
        color: Colors.transparent,
      ),
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index]);
      },
    );
  }
}

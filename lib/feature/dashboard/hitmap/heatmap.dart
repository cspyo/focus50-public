import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/dashboard/data/history_model.dart';
import 'package:focus42/feature/dashboard/hitmap/view_model/provider.dart';

class Heatmap extends ConsumerStatefulWidget {
  const Heatmap({Key? key}) : super(key: key);

  @override
  _HeatmapState createState() => _HeatmapState();
}

class _HeatmapState extends ConsumerState<Heatmap> {
  late DateTime startDate;
  late DateTime endDate;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _makeHeatmapDate();
  }

  void _makeHeatmapDate() {
    DateTime now = DateTime.now();
    startDate = DateTime(now.year, now.month - 5, now.day);
    endDate = now;
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<HistoryModel> history = ref.watch(historyStreamProvider);
    Map<DateTime, int>? heatMapDatasets = history.when(
        data: (data) => data.sessionHistory,
        error: (_, __) => null,
        loading: () => null);

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(20),
          elevation: 20,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: HeatMap(
              startDate: startDate,
              endDate: endDate,
              scrollable: true,
              colorMode: ColorMode.opacity,
              datasets: heatMapDatasets,
              colorsets: const {
                1: MyColors.purple300,
              },
              onClick: (value) {},
            ),
          ),
        ),
      ],
    );
  }
}

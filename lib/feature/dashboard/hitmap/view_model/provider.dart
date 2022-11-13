import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/feature/dashboard/data/history_model.dart';
import 'package:focus42/top_level_providers.dart';

final historyStreamProvider = StreamProvider<HistoryModel>(
  (ref) {
    final database = ref.watch(databaseProvider);
    return database.historyStream();
  },
);

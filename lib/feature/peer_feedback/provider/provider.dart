import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/feature/calendar/data/reservation_model.dart';
import 'package:focus50/top_level_providers.dart';

final runningSessionIdProvider = StateProvider<String>((ref) {
  final String _ret = '';
  return _ret;
});

final runningSessionFutureProvider =
    FutureProvider.autoDispose<ReservationModel>((ref) async {
  final database = ref.watch(databaseProvider);
  final String runningSessionId = ref.watch(runningSessionIdProvider);
  final ReservationModel reservation =
      await database.getReservation(runningSessionId);
  return reservation;
});

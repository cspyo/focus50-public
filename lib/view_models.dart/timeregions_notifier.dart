import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final timeRegionsProvider =
    StateNotifierProvider<TimeRegionsNotifier, List<TimeRegion>>(
        (ref) => TimeRegionsNotifier());

class TimeRegionsNotifier extends StateNotifier<List<TimeRegion>> {
  TimeRegionsNotifier() : super([]);

  List<TimeRegion> reservationRegions = <TimeRegion>[];
  List<TimeRegion> cantReserveRegions = <TimeRegion>[];

  void clearAll() {
    reservationRegions.clear();
    cantReserveRegions.clear();
    state.clear();
  }

  void clearReservationRegions() {
    reservationRegions.clear();
    _mergeTimeRegions();
  }

  void clearCantReserveRegions() {
    cantReserveRegions.clear();
    _mergeTimeRegions();
  }

  void addCantReserveRegions(TimeRegion timeRegion) {
    cantReserveRegions.add(timeRegion);
    _mergeTimeRegions();
  }

  void deleteCantReserveRegions(DateTime startTime) {
    cantReserveRegions.removeWhere((element) => element.startTime == startTime);
    _mergeTimeRegions();
  }

  void addReservationRegions(TimeRegion timeRegion) {
    reservationRegions.add(timeRegion);
    _mergeTimeRegions();
  }

  void _mergeTimeRegions() {
    state = [...reservationRegions, ...cantReserveRegions];
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, List<Appointment>>(
        (ref) => AppointmentsNotifier());

class AppointmentsNotifier extends StateNotifier<List<Appointment>> {
  AppointmentsNotifier() : super([]);

  void addAppointment(Appointment appointment) {
    state = [...state, appointment];
  }

  void deleteAppointment(DateTime startTime) {
    state.removeWhere((element) => element.startTime == startTime);
  }

  void clear() {
    state.clear();
  }
}

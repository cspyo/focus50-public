import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/feature/todo/data/todo_model.dart';
import 'package:focus50/top_level_providers.dart';

final partnerTodoToggleStateProvider = StateProvider.autoDispose<bool>((ref) {
  final _ret = false;
  return _ret;
});

final timerToggleStateProvider = StateProvider.autoDispose<bool>((ref) {
  final _ret = false;
  return _ret;
});

final entireTodoFocusStateProvider = StateProvider.autoDispose<bool>((ref) {
  final _ret = false;
  return _ret;
});

final mySessionTodoStreamProvider = StreamProvider.autoDispose
    .family<List<TodoModel>, String>((ref, sessionId) {
  final database = ref.watch(databaseProvider);
  return database.mySessionTodoStream(sessionId: sessionId);
});

final myEntireTodoStreamProvider =
    StreamProvider.autoDispose<List<TodoModel>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.myEntireTodoStream();
});

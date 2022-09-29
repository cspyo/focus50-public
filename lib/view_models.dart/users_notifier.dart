import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/models/user_public_model.dart';

final usersProvider =
    StateNotifierProvider<UsersNotifier, Map<String, UserPublicModel>>(
        (ref) => UsersNotifier());

class UsersNotifier extends StateNotifier<Map<String, UserPublicModel>> {
  UsersNotifier() : super({});

  void addAll(Map<String, UserPublicModel> user) {
    state.addAll(user);
  }

  bool containsKey(key) {
    return state.containsKey(key);
  }
}

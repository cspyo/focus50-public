import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:logger/logger.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final databaseProvider = Provider<FirestoreDatabase>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  if (auth.asData?.value?.uid != null) {
    return FirestoreDatabase(uid: auth.asData!.value!.uid);
  } else {
    return FirestoreDatabase(uid: "none");
  }
});

final userProvider = FutureProvider<UserModel>((ref) async {
  final database = ref.watch(databaseProvider);
  return await database.getUser();
});

final userStreamProvider = StreamProvider<UserModel>(
  (ref) {
    final database = ref.watch(databaseProvider);
    return database.userStream();
  },
);

final loggerProvider = Provider<Logger>((ref) => Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        printEmojis: false,
      ),
    ));

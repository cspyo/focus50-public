import 'package:focus42/services/firestore_database.dart';

void historyUpdate(FirestoreDatabase database) {
  database.updateHistory(DateTime.now());
}

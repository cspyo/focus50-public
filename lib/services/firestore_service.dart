import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool isAdd = false,
    bool merge = false,
  }) async {
    final reference = isAdd
        ? FirebaseFirestore.instance.collection(path).doc()
        : FirebaseFirestore.instance.doc(path);
    await reference.set(data, SetOptions(merge: merge));
  }

  Future<void> deleteData({required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.delete();
  }

  Future<void> updateData(
      {required String path, required Map<String, dynamic> data}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.update(data);
  }

  Future<T> getData<T>(
      {required String path,
      required T Function(DocumentSnapshot<Map<String, dynamic>> snapshot,
              SnapshotOptions? options)
          builder}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    final snapshot = await reference.get();
    final data = builder(snapshot, null);
    return data;
  }

  Future<List<T>> getDataWithQuery<T>({
    required String path,
    required T Function(DocumentSnapshot<Map<String, dynamic>> snapshot,
            SnapshotOptions? options)
        builder,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>> query)?
        queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) async {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query)!;
    }
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
    return querySnapshot.docs
        .map((snapshot) => builder(snapshot, null))
        .toList();
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(DocumentSnapshot<Map<String, dynamic>> snapshot,
            SnapshotOptions? options)
        builder,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>> query)?
        queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query)!;
    }
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
        query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot, null))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Stream<T> documentStream<T>({
    required String path,
    required T Function(DocumentSnapshot<Map<String, dynamic>> snapshot,
            SnapshotOptions? options)
        builder,
  }) {
    final DocumentReference<Map<String, dynamic>> reference =
        FirebaseFirestore.instance.doc(path);
    final Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
        reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot, null));
  }
}

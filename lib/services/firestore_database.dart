import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/models/todo_model.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/models/user_private_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/services/firestore_path.dart';
import 'package:focus42/services/firestore_service.dart';
import 'package:rxdart/rxdart.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase {
  FirestoreDatabase({required this.uid});
  final String uid;
  final _service = FirestoreService.instance;

  //----------------------user----------------------//

  // 유저 저장 및 업데이트
  Future<void> setUser(UserModel user) async {
    if (user.userPublicModel != null)
      _service.setData(
          path: FirestorePath.userPublic(uid),
          data: user.userPublicModel!.toMap());
    if (user.userPrivateModel != null)
      _service.setData(
          path: FirestorePath.userPrivate(uid),
          data: user.userPrivateModel!.toMap());
  }

  Future<UserPublicModel> getUserPublic({String? othersUid}) async {
    String uid = this.uid;
    if (othersUid != null) {
      uid = othersUid;
    }
    return await _service.getData<UserPublicModel>(
        path: FirestorePath.userPublic(uid),
        builder: (snapshot, options) =>
            UserPublicModel.fromMap(snapshot, options));
  }

  Future<UserPrivateModel?> getUserPrivate() async {
    return await _service.getData<UserPrivateModel>(
        path: FirestorePath.userPrivate(uid),
        builder: (snapshot, options) =>
            UserPrivateModel.fromMap(snapshot, options));
  }

  // userPublic 스트림이랑 userPrivate 스트림이랑 combine
  Stream<UserModel> userStream() => CombineLatestStream.combine2(
        _userPublicStream(),
        _userPrivateStream(),
        (UserPublicModel public, UserPrivateModel private) =>
            UserModel(public, private),
      );
  Stream<UserPublicModel> _userPublicStream() => _service.documentStream(
        path: FirestorePath.userPublic(uid),
        builder: (snapshot, options) =>
            UserPublicModel.fromMap(snapshot, options),
      );
  Stream<UserPrivateModel> _userPrivateStream() => _service.documentStream(
        path: FirestorePath.userPrivate(uid),
        builder: (snapshot, options) =>
            UserPrivateModel.fromMap(snapshot, options),
      );

  // users 의 스트림
  Stream<List<UserPublicModel>> usersStream() => _service.collectionStream(
        path: FirestorePath.reservations(),
        queryBuilder: (query) => query,
        builder: (snapshot, options) =>
            UserPublicModel.fromMap(snapshot, options),
      );

  //----------------------reservation----------------------//

  // 예약 저장 및 업데이트
  // [reservation 모델에 docId(id)가 있으면 업데이트(set), 없으면 추가(add)]
  Future<void> setReservation(
    ReservationModel reservation,
  ) =>
      _service.setData(
        path: reservation.id != null
            ? FirestorePath.reservation(reservation.id!)
            : FirestorePath.reservations(),
        data: reservation.toMap(),
        isAdd: reservation.id == null,
      );

  Future<ReservationModel> getReservation(String docId) async {
    return await _service.getData(
        path: FirestorePath.reservation(docId),
        builder: (snapshot, options) =>
            ReservationModel.fromMap(snapshot, options));
  }

  // reservation 삭제 [예약한 사람 수(headcount)가 0이 되면]
  Future<void> deleteReservation(ReservationModel reservation) =>
      _service.deleteData(path: FirestorePath.reservation(reservation.id!));

  Future<ReservationModel?> findReservationForMatch(
      {required DateTime startTime}) async {
    List<ReservationModel?> findNotFullReservation =
        await _service.getDataWithQuery(
            path: FirestorePath.reservations(),
            queryBuilder: (query) => query
                .where("startTime", isEqualTo: Timestamp.fromDate(startTime))
                .where("isFull", isEqualTo: false)
                .limit(1),
            builder: (snapshot, options) =>
                ReservationModel.fromMap(snapshot, options));
    if (findNotFullReservation.isEmpty) {
      return null;
    } else {
      return findNotFullReservation.first;
    }
  }

  // reservation 하나(docId 지정) 의 스트림
  Stream<ReservationModel> reservationStream({required String reservationId}) =>
      _service.documentStream(
        path: FirestorePath.reservation(reservationId),
        builder: (snapshot, options) =>
            ReservationModel.fromMap(snapshot, options),
      );

  // 내 reservation (현재시간-10분 이후) 의 스트림
  Stream<List<ReservationModel>> myReservationsStream() =>
      _service.collectionStream(
        path: FirestorePath.reservations(),
        queryBuilder: (query) => query
            .where("userIds", arrayContains: uid)
            .where("startTime",
                isGreaterThanOrEqualTo:
                    DateTime.now().subtract(Duration(minutes: 10)))
            .orderBy("startTime"),
        builder: (snapshot, options) =>
            ReservationModel.fromMap(snapshot, options),
      );

  // 내 가장 가까운 reservation 의 스트림
  Stream<List<ReservationModel?>> myNextReservationStream() =>
      _service.collectionStream(
        path: FirestorePath.reservations(),
        queryBuilder: (query) => query
            .where("userIds", arrayContains: uid)
            .where("startTime",
                isGreaterThanOrEqualTo:
                    DateTime.now().subtract(Duration(minutes: 10)))
            .orderBy("startTime")
            .limit(1),
        builder: (snapshot, options) =>
            ReservationModel.fromMap(snapshot, options),
      );

  // 내가 포함되지 않은 예약들
  Future<List<ReservationModel>> othersReservations() =>
      _service.getDataWithQuery(
        path: FirestorePath.reservations(),
        // 복합쿼리에서 not-in과 > 쿼리는 같이 사용을 못함
        queryBuilder: (query) => query
            .where("isFull", isEqualTo: false)
            .where("startTime", isGreaterThan: DateTime.now()),
        builder: (snapshot, options) =>
            ReservationModel.fromMap(snapshot, options),
      );

  // 내 전체 투두
  Stream<List<TodoModel>> myEntireTodoStream() => _service.collectionStream(
        path: FirestorePath.todos(),
        queryBuilder: (query) => query.where("userUid", isEqualTo: uid),
        builder: (snapshot, options) => TodoModel.fromMap(snapshot, options),
      );

  // 내 전체 투두
  Stream<List<TodoModel>> mySessionTodoStream({required String sessionId}) =>
      _service.collectionStream(
        path: FirestorePath.todos(),
        queryBuilder: (query) => query
            .where("userUid", isEqualTo: uid)
            .where("assignedSessionId", isEqualTo: sessionId),
        builder: (snapshot, options) => TodoModel.fromMap(snapshot, options),
      );

  Future<void> setTodo(TodoModel todo) => _service.setData(
        path: todo.id != null
            ? FirestorePath.todo(todo.id!)
            : FirestorePath.todos(),
        data: todo.toMap(),
        isAdd: todo.id == null,
      );

  Future<void> deleteTodo(TodoModel todo) =>
      _service.deleteData(path: FirestorePath.todo(todo.id!));
}

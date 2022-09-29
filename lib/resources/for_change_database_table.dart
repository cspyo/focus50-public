import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/models/reservation_user_info.dart';
import 'package:focus42/services/firestore_service.dart';

class ForChangeDatabaseTable {
  setMapInMapExample() async {
    final db = FirebaseFirestore.instance;
    final cities = db.collection("ex");

    Map<String, dynamic> userInfos = {};
    List<String> userIds = [];

    String uid1 = "rcRWuR1IsjdYXR40KN2Ls2941s83";
    final user1Info = <String, dynamic>{
      "uid": "rcRWuR1IsjdYXR40KN2Ls2941s83",
      "nickname": "aaa",
      "enterDTTM": DateTime.now().add(Duration(minutes: 20)),
      "leaveDTTM": DateTime.now(),
    };
    userIds.add(uid1);
    userInfos.addAll({uid1: user1Info});

    String uid2 = "agGyQHDOggQd6so6pgqwPcjE3463";
    final user2Info = <String, dynamic>{
      "uid": "agGyQHDOggQd6so6pgqwPcjE3463",
      "nickname": "bbb",
      "enterDTTM": DateTime.now(),
      "leaveDTTM": DateTime.now(),
    };
    userIds.add(uid2);
    userInfos.addAll({uid2: user2Info});

    final reservation1 = <String, dynamic>{
      "id": null,
      "startTime": DateTime.now().add(Duration(minutes: 20)),
      "endTime": DateTime.now().add(Duration(minutes: 70)),
      "isFull": true,
      "maxHeadcount": 2,
      "roomId": "exroomid",
      "userIds": userIds,
      "userInfos": userInfos,
    };

    await cities.doc("example").set(reservation1);
  }

  getMapInMapExample() async {
    await FirebaseFirestore.instance
        .collection("example")
        .doc("example")
        .get()
        .then((value) {
      final data = value.data() as Map<String, dynamic>;
      List<dynamic> userIds = data["userIds"] as List<dynamic>;
      List<dynamic> userInfos = data["userInfos"] as List<dynamic>;

      userInfos.forEach((element) {
        String name = element["name"];
        String state = element["state"];
        bool capital = element["capital"];
        int population = element["population"];
        List<dynamic> regions = element["regions"];
      });
    });
  }

  testAddUser() async {
    var snapshots = await FirebaseFirestore.instance
        .collection("ex")
        .where("userIds", arrayContains: "111111")
        .get();
    ReservationModel data =
        ReservationModel.fromMap(snapshots.docs.first, null);

    ReservationUserInfo user3 = ReservationUserInfo(
      uid: "333333",
      nickname: "user3",
    );

    data.addUser("333333", user3);
    await FirestoreService.instance
        .setData(path: "ex/${data.id}", data: data.toMap());
  }

  testUpdateEnterDTTM() async {
    String uid = "333333";
    Map<String, dynamic> data = {"userInfos.${uid}.enterDTTM": DateTime.now()};
    await FirebaseFirestore.instance
        .doc("ex/ISBefyZGstEG7ik4ghXf")
        .update(data);
  }

  testNewReservationModel_userInfosMap() async {
    List<String> userIds = ["111111", "222222"];
    Map<String, ReservationUserInfo> userInfos = {};
    ReservationUserInfo user1 = ReservationUserInfo(
      uid: "111111",
      nickname: "user1",
      enterDTTM: DateTime.now(),
      leaveDTTM: DateTime.now(),
    );
    userInfos.addAll({"111111": user1});
    ReservationUserInfo user2 = ReservationUserInfo(
      uid: "222222",
      nickname: "user2",
      enterDTTM: DateTime.now(),
      leaveDTTM: DateTime.now(),
    );
    userInfos.addAll({"222222": user2});

    ReservationModel newReservationModel = new ReservationModel(
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      isFull: false,
      headcount: 2,
      maxHeadcount: 2,
      roomId: null,
      id: null,
      userIds: userIds,
      userInfos: userInfos,
    );
    // await FirestoreService.instance.addData(
    //     collectionPath: 'ex/', data: newReservationModel.toFirestore());
  }

  changeReservationTable() async {
    final _firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore.collection('reservation').get();

    querySnapshot.docs
        .forEach((DocumentSnapshot<Map<String, dynamic>> docSnap) async {
      Map<String, dynamic> data = docSnap.data()!;
      String docId = docSnap.id;

      List<String> userIds = [];
      Map<String, ReservationUserInfo> userInfos = {};

      String? user1Uid = data["user1Uid"];
      if (user1Uid != null) {
        ReservationUserInfo userInfo1 = ReservationUserInfo(
          enterDTTM: data["user1EnterDTTM"] != null
              ? data["user1EnterDTTM"].toDate() as DateTime
              : null,
          leaveDTTM: null,
          nickname: data["user1Name"],
          uid: user1Uid,
        );
        userInfos.addAll({user1Uid: userInfo1});
        userIds.add(user1Uid);
      }

      String? user2Uid = data["user2Uid"];
      if (user2Uid != null) {
        ReservationUserInfo userInfo2 = ReservationUserInfo(
          enterDTTM: data["user2EnterDTTM"] != null
              ? data["user2EnterDTTM"].toDate() as DateTime
              : null,
          leaveDTTM: null,
          nickname: data["user2Name"],
          uid: user2Uid,
        );
        userInfos.addAll({user2Uid: userInfo2});
        userIds.add(user2Uid);
      }

      ReservationModel updatedReservation = ReservationModel(
          startTime: data["startTime"] != null
              ? data["startTime"].toDate() as DateTime
              : null,
          endTime: data["endTime"] != null
              ? data["endTime"].toDate() as DateTime
              : null,
          isFull: data["isFull"] as bool,
          id: docId,
          roomId: data["room"],
          headcount: userIds.length,
          maxHeadcount: 2,
          userIds: userIds,
          userInfos: userInfos);

      await _firestore
          .collection('reservation')
          .doc(docId)
          .update(updatedReservation.toMap());

      Map<String, dynamic> updates = {
        "room": FieldValue.delete(),
        "user1EnterDTTM": FieldValue.delete(),
        "user2EnterDTTM": FieldValue.delete(),
        "user1Name": FieldValue.delete(),
        "user2Name": FieldValue.delete(),
        "user1Uid": FieldValue.delete(),
        "user2Uid": FieldValue.delete(),
      };
      await _firestore.collection('reservation').doc(docId).update(updates);
    });
  }

  changeReservationTableByDocId(String docId) async {
    final _firestore = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _firestore.collection('reservation').doc(docId).get();

    Map<String, dynamic> data = documentSnapshot.data()!;

    List<String> userIds = [];
    Map<String, ReservationUserInfo> userInfos = {};

    String? user1Uid = data["user1Uid"];
    if (user1Uid != null) {
      ReservationUserInfo userInfo1 = ReservationUserInfo(
        enterDTTM: data["user1EnterDTTM"] != null
            ? data["user1EnterDTTM"].toDate() as DateTime
            : null,
        leaveDTTM: null,
        nickname: data["user1Name"],
        uid: user1Uid,
      );
      userInfos.addAll({user1Uid: userInfo1});
      userIds.add(user1Uid);
    }

    String? user2Uid = data["user2Uid"];
    if (user2Uid != null) {
      ReservationUserInfo userInfo2 = ReservationUserInfo(
        enterDTTM: data["user2EnterDTTM"] != null
            ? data["user2EnterDTTM"].toDate() as DateTime
            : null,
        leaveDTTM: null,
        nickname: data["user2Name"],
        uid: user2Uid,
      );
      userInfos.addAll({user2Uid: userInfo2});
      userIds.add(user2Uid);
    }

    ReservationModel updatedReservation = ReservationModel(
        startTime: data["startTime"] != null
            ? data["startTime"].toDate() as DateTime
            : null,
        endTime: data["endTime"] != null
            ? data["endTime"].toDate() as DateTime
            : null,
        isFull: data["isFull"] as bool,
        id: docId,
        roomId: data["room"],
        headcount: userIds.length,
        maxHeadcount: 2,
        userIds: userIds,
        userInfos: userInfos);

    await _firestore
        .collection('reservation')
        .doc(docId)
        .update(updatedReservation.toMap());

    Map<String, dynamic> updates = {
      "room": FieldValue.delete(),
      "user1EnterDTTM": FieldValue.delete(),
      "user2EnterDTTM": FieldValue.delete(),
      "user1Name": FieldValue.delete(),
      "user2Name": FieldValue.delete(),
      "user1Uid": FieldValue.delete(),
      "user2Uid": FieldValue.delete(),
    };
    await _firestore.collection('reservation').doc(docId).update(updates);
  }
}

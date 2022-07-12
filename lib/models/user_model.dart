import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String nickname;
  final String job;

  const UserModel({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.nickname,
    required this.job,
  });

  // static UserModel fromFirestore(DocumentSnapshot snap) {
  //   var data = snap.data() as Map<String, dynamic>;

  //   return UserModel(
  //     username: data["username"],
  //     uid: data["uid"],
  //     email: data["email"],
  //     photoUrl: data["photoUrl"],
  //     nickname: data["nickname"],
  //     job: data["job"],
  //   );
  // }

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return UserModel(
      username: data?["username"],
      uid: data?["uid"],
      email: data?["email"],
      photoUrl: data?["photoUrl"],
      nickname: data?["nickname"],
      job: data?["job"],
    );
  }

  Map<String, dynamic> toFirestore() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "nickname": nickname,
        "job": job,
      };
}

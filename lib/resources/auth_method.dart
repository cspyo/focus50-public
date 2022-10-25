import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus42/consts/error_message.dart';
import 'package:focus42/models/user_private_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/storage_method.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Public 유저 정보 가져오기
  Future<UserPublicModel> getUserPublic(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> publicDocSnapshot =
        await _firestore.collection('users').doc(uid).get();

    return UserPublicModel.fromMap(publicDocSnapshot, null);
  }

  // Private 유저 정보 가져오기
  Future<UserPrivateModel> getUserPrivate() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot<Map<String, dynamic>> privateDocSnapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('private')
        .doc(currentUser.uid)
        .get();

    return UserPrivateModel.fromMap(privateDocSnapshot, null);
  }

  // UserPublicModel Collection Reference 가져오기
  CollectionReference getUserPublicColRef() {
    final userPublicColRef =
        _firestore.collection('users').withConverter<UserPublicModel>(
              fromFirestore: UserPublicModel.fromMap,
              toFirestore: (UserPublicModel userPublicModel, _) =>
                  userPublicModel.toMap(),
            );
    return userPublicColRef;
  }

  // UserPrivateModel Collection Reference 가져오기
  CollectionReference getUserPrivateColRef() {
    final userPrivateColRef = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('private')
        .withConverter<UserPrivateModel>(
          fromFirestore: UserPrivateModel.fromMap,
          toFirestore: (UserPrivateModel userPrivateModel, _) =>
              userPrivateModel.toMap(),
        );
    return userPrivateColRef;
  }

  // 회원가입 (email and password)
  Future<String> signUpWithEmail(
      {required String email, required String password}) async {
    String res = ERROR;
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        res = SUCCESS;
      }
    } on FirebaseAuthException catch (err) {
      res = err.code;
    }
    return res;
  }

  // 기존 유저 테이블을 업데이트된 유저 테이블로 바꿔주는 메소드 (focus42에서 실험해보고 신중하게 사용하기)
  changeUserTable() async {
    var querySnapshot = await _firestore.collection('users').get();
    querySnapshot.docs.forEach((element) async {
      var existingData = element.data();
      var uid = element.id;

      // private 컬렉션이 있는지 확인 (최신 구조로 업데이트 되었는지 확인)
      final docPrivate = await _firestore
          .collection('users')
          .doc(uid)
          .collection('private')
          .doc(uid)
          .get();

      if (!docPrivate.exists) {
        // public
        // uid, username, email 필드 제거
        // createdDate, updatedDate, lastLogin 필드 생성
        final updates = <String, dynamic>{
          "uid": FieldValue.delete(),
          "username": FieldValue.delete(),
          "email": FieldValue.delete(),
          "createdDate": null,
          "updatedDate": DateTime.now(),
          "lastLogin": null,
        };
        await _firestore.collection('users').doc(uid).update(updates);

        // private
        // 기존 테이블에 있던 데이터 가져와서 private 컬렉션에 새로 생성
        UserPrivateModel userPrivateModel = new UserPrivateModel(
          uid: uid,
          username: existingData["username"],
          email: existingData["email"],
          phoneNumber: null,
        );
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('private')
            .doc(uid)
            .set(userPrivateModel.toMap());
      }
    });
  }

  changeUserTableByUid(String uid) async {
    final userPrivateColRef =
        _firestore.collection('users').doc(uid).collection('private');

    var existingDoc = await _firestore.collection('users').doc(uid).get();
    var existingData = existingDoc.data();
    // private 컬렉션이 있는지 확인 (최신 구조로 업데이트 되었는지 확인)
    final docPrivate = await userPrivateColRef.doc(uid).get();

    if (!docPrivate.exists) {
      // public
      // uid, username, email 필드 제거
      // createdDate, updatedDate, lastLogin 필드 생성
      final updates = <String, dynamic>{
        "uid": FieldValue.delete(),
        "username": FieldValue.delete(),
        "email": FieldValue.delete(),
        "createdDate": null,
        "updatedDate": DateTime.now(),
        "lastLogin": null,
      };
      await _firestore.collection('users').doc(uid).update(updates);

      // private
      // 기존 테이블에 있던 데이터 가져와서 private 컬렉션에 새로 생성
      UserPrivateModel userPrivateModel = new UserPrivateModel(
        uid: uid,
        username: existingData?["username"],
        email: existingData?["email"],
        phoneNumber: null,
      );
      await userPrivateColRef.doc(uid).set(userPrivateModel.toMap());
    }
  }

  // 마지막 로그인 날짜 업데이트
  updateLastLogin() async {
    UserPublicModel userPublicModel = new UserPublicModel(
      lastLogin: DateTime.now(),
    );

    var userPublicColRef = getUserPublicColRef();
    await userPublicColRef
        .doc(_auth.currentUser!.uid)
        .update(userPublicModel.toMap());
  }

  // 로그인 (email and password)
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = ERROR;
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        if (await isSignedUp(uid: _auth.currentUser!.uid)) {
          res = SIGNED_UP;
        } else {
          res = NOT_CREATED_PROFILE;
        }
      } else {
        res = "모든 필드를 작성해주세요";
      }
    } on FirebaseAuthException catch (err) {
      res = err.code;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // 회원가입 and 로그인 (google)
  Future<UserCredential> signInWithGoogle() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    UserCredential cred = await _auth.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    // await FirebaseAuth.instance.signInWithRedirect(googleProvider);

    return cred;
  }

  // firestore에 유저가 저장되어있는지 확인 (회원가입이 되어있는지 확인)
  Future<bool> isSignedUp({required String uid}) async {
    var check = await _firestore.collection('users').doc(uid).get();
    return check.exists;
  }

  // 유저의 uid(auth)와 profile을 엮어서 firestore에 저장
  Future<String> saveUserProfile({
    required String username,
    required String nickname,
    required String job,
    required Uint8List? file,
  }) async {
    String res = ERROR;
    try {
      if (username.isNotEmpty || job.isNotEmpty || nickname.isNotEmpty) {
        String uid = _auth.currentUser!.uid;
        String? email = _auth.currentUser!.email;
        String photoUrl;
        String? phoneNumber;

        if (file == null) {
          photoUrl = StorageMethods.defaultImageUrl;
        } else {
          photoUrl = await StorageMethods().uploadImageToStorage(
              'profilePics/${_auth.currentUser!.uid}', file);
        }
        CollectionReference userPublicColRef = getUserPublicColRef();
        CollectionReference userPrivateColRef = getUserPrivateColRef();

        UserPublicModel userPublic = new UserPublicModel(
          nickname: nickname,
          photoUrl: photoUrl,
          job: job,
          createdDate: DateTime.now(),
          updatedDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await userPublicColRef.doc(uid).set(userPublic);

        UserPrivateModel userPrivate = new UserPrivateModel(
          uid: uid,
          username: username,
          email: email,
          phoneNumber: phoneNumber,
        );

        await userPrivateColRef.doc(uid).set(userPrivate);

        res = SUCCESS;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<bool> isOverlapNickname(String? value) async {
    var snap = await _firestore
        .collection('users')
        .where('nickname', isEqualTo: value)
        .get();
    if (snap.size == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

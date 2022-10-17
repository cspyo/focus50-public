import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/error_message.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/models/user_private_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/storage_method.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';

final authViewModelProvider = Provider<AuthViewModel>(
  (ref) {
    final database = ref.watch(databaseProvider);
    return AuthViewModel(database: database);
  },
);

class AuthViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreDatabase database;
  // final Ref ref;
  final String defaultPhotoUrl =
      'https://firebasestorage.googleapis.com/v0/b/focus-50.appspot.com/o/profilePics%2Fuser.png?alt=media&token=69e13fc9-b2ea-460c-98e0-92fe6613461e';

  AuthViewModel({required this.database});

  // 회원가입 (email and password)
  Future<String> signUpWithEmail(
      {required String nickname,
      required String email,
      required String password}) async {
    String res = ERROR;

    // 파베 회원가입
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

  // 로그인 (email and password)
  Future<String> loginWithEmail(
      {required String email, required String password}) async {
    String res = ERROR;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      res = SUCCESS;
    } on FirebaseAuthException catch (err) {
      res = err.code;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // 로그인 (구글)
  Future<String> loginWithGoogle() async {
    String res = ERROR;
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    // googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
    try {
      UserCredential cred = await _auth.signInWithPopup(googleProvider);

      // await FirebaseAuth.instance.signInWithRedirect(googleProvider);
      res = SUCCESS;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // 유저의 uid(auth)와 profile을 엮어서 firestore에 저장
  Future<String> saveUserProfile({
    required String? nickname,
    required Uint8List? file,
  }) async {
    String res = ERROR;
    try {
      String uid = _auth.currentUser!.uid;
      String? email = _auth.currentUser!.email;
      String? photoUrl;

      if (nickname == null) {
        nickname = _auth.currentUser!.displayName;
      }

      if (file == null) {
        if (_auth.currentUser?.photoURL == null) {
          photoUrl = defaultPhotoUrl;
        } else {
          photoUrl = _auth.currentUser!.photoURL;
        }
      } else {
        photoUrl =
            await StorageMethods().uploadImageToStorage('profilePics', file);
      }

      UserPublicModel userPublic = UserPublicModel(
        nickname: nickname,
        photoUrl: photoUrl,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      UserPrivateModel userPrivate = UserPrivateModel(
        uid: uid,
        email: email,
      );

      UserModel userModel = UserModel(userPublic, userPrivate);

      await database.setUser(userModel);
      // ref.read(usersProvider).addAll({uid: userPublic});
      res = SUCCESS;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<bool> isSignedUp() async {
    final user = await database.getUserPublic();
    return user.createdDate != null;
  }

  Future<bool> possibleNickname(String nickname) async {
    return await database.possibleNickname(nickname);
  }

  Future<void> signOut() async {
    // if (_auth.currentUser!.uid.contains('kakao')) {
    //   await kakao.UserApi.instance.unlink();
    // }
    await _auth.signOut();
  }
}

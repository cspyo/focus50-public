import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus42/consts/error_message.dart';
import 'package:focus42/resources/storage_method.dart';

import '../models/user_model.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 유저 정보 가져오기
  Future<UserModel> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return UserModel.fromFirestore(documentSnapshot, null);
  }

  // UserModel Collection Reference 가져오기
  CollectionReference getUserColRef() {
    final userColRef = _firestore.collection('users').withConverter<UserModel>(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel userModel, _) => userModel.toFirestore(),
        );
    return userColRef;
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
          res = NOT_SIGNED_UP;
        }
      } else {
        res = "Pleas enter all the fields";
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

        if (file == null) {
          photoUrl =
              'https://firebasestorage.googleapis.com/v0/b/focus50-8b405.appspot.com/o/profilePics%2Fuser.png?alt=media&token=f3d3b60c-55f8-4576-bfab-e219d9c225b3';
        } else {
          photoUrl =
              await StorageMethods().uploadImageToStorage('profilePics', file);
        }

        CollectionReference userColRef = getUserColRef();

        UserModel user = new UserModel(
          username: username,
          uid: uid,
          photoUrl: photoUrl,
          email: email!,
          nickname: nickname,
          job: job,
        );

        await _firestore.collection('users').doc(uid).set(user.toFirestore());

        //_firestore.collection('users').doc(uid).set(data)

        res = SUCCESS;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}

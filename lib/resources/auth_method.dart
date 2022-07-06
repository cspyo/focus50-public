import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 회원가입 (email and password)
  Future<String> signUpWithEmail(
      {required String email, required String password}) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      res = err.code;
    }
    return res;
  }

  // 로그인 (email and password)
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
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

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
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
  }) async {
    String res = "Some error occurred";
    try {
      if (username.isNotEmpty || job.isNotEmpty || nickname.isNotEmpty) {
        String uid = _auth.currentUser!.uid;
        String? email = _auth.currentUser!.email;

        _firestore.collection('users').doc(uid).set({
          'username': username,
          'uid': uid,
          'email': email,
          'job': job,
          'nickname': nickname
        });
        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}

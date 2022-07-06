import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await _auth.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  Future<bool> isSignedUp({required String uid}) async {
    //String uid = _auth.currentUser!.uid;
    var check = await _firestore.collection('users').doc(uid).get();
    print(check.exists);

    return check.exists;
  }

  Future<String> saveUserProfile({
    required String username,
    required String nickname,
    required String job,
  }) async {
    String res = "Some error occurred";
    try {
      if (username.isNotEmpty || job.isNotEmpty || nickname.isNotEmpty) {
        // add user to firestore
        String uid = _auth.currentUser!.uid;
        String? email = _auth.currentUser!.email;

        _firestore.collection('users').doc(uid).set({
          'username': username,
          'uid': uid,
          'email': email,
          'job': job,
          'nickname': nickname
        });
        //
        // await _firestore.collection('users').add({
        //   'username': username,
        //   'uid': cred.user!.uid,
        //   'email': email,
        //   'bio': bio,
        //   'followers': [],
        //   'following': [],
        // });

        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

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
      if (err.code == 'user-not-found') {
        res = 'user-not-found';
      } else {
        res = err.code;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}

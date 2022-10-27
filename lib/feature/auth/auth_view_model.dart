import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/error_message.dart';
import 'package:focus42/feature/auth/firebase_auth_remote_data_source.dart';
import 'package:focus42/models/user_model.dart';
import 'package:focus42/models/user_private_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/resources/storage_method.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/view_models.dart/users_notifier.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:universal_html/html.dart' as html;

final authViewModelProvider = Provider<AuthViewModel>(
  (ref) {
    final database = ref.watch(databaseProvider);
    return AuthViewModel(database: database, ref: ref);
  },
);

class AuthViewModel {
  final FirebaseAuthRemoteDataSource _firebaseAuthRemoteDataSource =
      FirebaseAuthRemoteDataSource();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreDatabase database;
  final Ref ref;
  // final Ref ref;
  final String defaultPhotoUrl = StorageMethods.defaultImageUrl;

  AuthViewModel({required this.database, required this.ref});

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

  String? _substringPhoneNumber(String? phoneNumber) {
    if (phoneNumber != null) {
      String first = phoneNumber.substring(0, 3);
      String second = phoneNumber.substring(4, 6);
      String third = phoneNumber.substring(7, 11);
      String fourth = phoneNumber.substring(12);
      return first + second + third + fourth;
    }
    return null;
  }

  // 로그인 (카카오)
  Future<String> loginWithKakao() async {
    String res = ERROR;
    if (await kakaoLoginProcess()) {
      kakao.User user = await kakao.UserApi.instance.me();

      String uid = user.id.toString();
      String? nickname = user.kakaoAccount?.profile?.nickname;
      String? email = user.kakaoAccount?.email;
      String? photoURL = user.kakaoAccount?.profile?.profileImageUrl;
      // String? phoneNumber = user.kakaoAccount?.phoneNumber;

      final token = await _firebaseAuthRemoteDataSource.createCustomToken({
        "uid": uid,
        "displayName": nickname,
        "email": email,
        "photoURL": photoURL,
        // "phoneNumber": _substringPhoneNumber(phoneNumber),
      });

      if (token == EMAIL_ALREADY_EXISTS) {
        res = token;
      } else {
        try {
          await _auth.signInWithCustomToken(token);
          res = SUCCESS;
        } catch (e) {
          res = e.toString();
        }
      }
    } else {
      res = ERROR;
    }
    return res;
  }

  // 로그인 (카카오)
  Future<bool> kakaoLoginProcess() async {
    try {
      bool talkInstalled = await kakao.isKakaoTalkInstalled();
      //   카카오톡이 설치되어 있으면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
      kakao.OAuthToken token = talkInstalled
          ? await kakao.UserApi.instance.loginWithKakaoTalk()
          : await kakao.UserApi.instance.loginWithKakaoAccount();

      return true;
    } catch (e) {
      return false;
    }
  }

  // 유저의 uid(auth)와 profile을 엮어서 firestore에 저장
  Future<String> saveUserProfile({
    required String? nickname,
    required String signUpMethod,
  }) async {
    String res = ERROR;

    try {
      String uid = _auth.currentUser!.uid;
      String? kakaoNickname = null;
      String? googleNickname = null;
      String? photoUrl = _auth.currentUser?.photoURL;
      bool kakaoSynced = false;
      bool emailNoticeAllowed = true;
      bool kakaoNoticeAllowed = false;
      bool? talkMessageAgreed = false;
      List<String> noticeMethods = ["email"];

      String? email = _auth.currentUser!.email;
      String? kakaoAccount = null;
      String? phoneNumber = _auth.currentUser?.phoneNumber;

      // 카카오로 회원가입했으면
      if (signUpMethod == "kakao") {
        kakaoSynced = true;
        kakaoAccount = email;
        kakaoNickname = _auth.currentUser!.displayName;
        nickname = kakaoNickname;

        final user = await kakao.UserApi.instance.me();
        if (user.kakaoAccount!.profile!.isDefaultImage!) {
          photoUrl = defaultPhotoUrl;
        }
        talkMessageAgreed = await getTalkMessageAgreed();
        kakaoNoticeAllowed = talkMessageAgreed!;
        if (kakaoNoticeAllowed) noticeMethods.add("kakao");
      } else if (signUpMethod == "google") {
        googleNickname = _auth.currentUser!.displayName;
        nickname = googleNickname;
      } else if (signUpMethod == "email") {}

      if (photoUrl == null) {
        photoUrl = defaultPhotoUrl;
      } else {
        try {
          photoUrl = await _firebaseAuthRemoteDataSource
              .saveNetworkImageToStorage(photoUrl, uid);
        } catch (e) {
          photoUrl = defaultPhotoUrl;
        }
      }

      UserPublicModel userPublic = UserPublicModel(
        nickname: nickname,
        kakaoNickname: kakaoNickname,
        googleNickname: googleNickname,
        photoUrl: photoUrl,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
        lastLogin: DateTime.now(),
        kakaoSynced: kakaoSynced,
        talkMessageAgreed: talkMessageAgreed,
        emailNoticeAllowed: emailNoticeAllowed,
        kakaoNoticeAllowed: kakaoNoticeAllowed,
        noticeMethods: noticeMethods,
      );

      UserPrivateModel userPrivate = UserPrivateModel(
        uid: uid,
        email: email,
        kakaoAccount: kakaoAccount,
        phoneNumber: phoneNumber,
      );

      UserModel userModel = UserModel(userPublic, userPrivate);

      await database.setUser(userModel);

      ref.read(usersProvider.notifier).addAll({uid: userPublic});
      res = SUCCESS;

      String userAgent =
          html.window.navigator.userAgent.toString().toLowerCase();
      if (userAgent.contains("iphone") || userAgent.contains("android")) {
        AnalyticsMethod().mobileLogSignUp(signUpMethod);
      } else {
        AnalyticsMethod().logSignUp(signUpMethod);
      }
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

  Future<bool?> getTalkMessageAgreed() async {
    kakao.ScopeInfo scopeInfo = await kakao.UserApi.instance.scopes();
    final talk_message_scope =
        scopeInfo.scopes?.where((scope) => scope.id == "talk_message");
    return talk_message_scope?.first.agreed;
  }

  Future<void> signOut() async {
    // if (_auth.currentUser!.uid.contains('kakao')) {
    //   await kakao.UserApi.instance.unlink();
    // }
    AnalyticsMethod().logSignOut();
    await _auth.signOut();
  }

  Future<void> deleteUser() async {}
}

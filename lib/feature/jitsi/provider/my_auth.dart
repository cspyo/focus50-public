import 'package:focus42/models/user_model.dart';

class MyAuth {
  MyAuth._();
  static final instance = MyAuth._();

  String? _uid;
  String? _username;
  String? _email;
  String? _phoneNumber;
  String? _nickname;
  String? _photoUrl;
  String? _job;

  String? get uid => _uid;
  String? get username => _username;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get nickname => _nickname;
  String? get photoUrl => _photoUrl;
  String? get job => _job;

  void login(UserModel user) {
    _uid = user.userPrivateModel!.uid;
    _username = user.userPrivateModel!.username;
    _email = user.userPrivateModel!.email;
    _phoneNumber = user.userPrivateModel!.phoneNumber;
    _nickname = user.userPublicModel!.nickname;
    _photoUrl = user.userPublicModel!.photoUrl;
    _job = user.userPublicModel!.job;
  }

  void logout() {
    _uid = null;
    _username = null;
    _email = null;
    _phoneNumber = null;
    _nickname = null;
    _photoUrl = null;
    _job = null;
  }
}

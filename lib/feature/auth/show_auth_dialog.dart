import 'package:flutter/material.dart';
import 'package:focus42/feature/auth/presentation/email_sign_up_dialog.dart';
import 'package:focus42/feature/auth/presentation/go_to_profile_dialog.dart';
import 'package:focus42/feature/auth/presentation/login_dialog.dart';
import 'package:focus42/feature/auth/presentation/sign_up_dialog.dart';

class ShowAuthDialog {
  ShowAuthDialog._();
  static final _instance = ShowAuthDialog._();

  factory ShowAuthDialog() {
    return _instance;
  }

  // 로그인 다이얼로그
  Future<void> showLoginDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return LoginDialog();
      },
    );
  }

  //회원가입 다이얼로그
  Future<void> showSignUpDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SignUpDialog();
      },
    );
  }

  // 이메일 회원가입 다이얼로그
  Future<void> showEmailSignUpDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return EmailSignUpDialog();
      },
    );
  }

  // 프로필 확인하시겠습니까? 다이얼로그
  Future<void> showGoToProfileDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return GoToProfileDialog();
      },
    );
  }
}

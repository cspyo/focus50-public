import 'package:flutter/material.dart';
import 'package:focus42/feature/auth/presentation/email_login_dialog.dart';
import 'package:focus42/feature/auth/presentation/email_sign_up_dialog.dart';
import 'package:focus42/feature/auth/presentation/login_dialog.dart';
import 'package:focus42/feature/auth/presentation/sign_up_complete_dialog.dart';
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
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return LoginDialog();
      },
    );
  }

  // 회원가입 다이얼로그
  Future<void> showSignUpDialog(BuildContext context) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SignUpDialog();
      },
    );
  }

  // 이메일 로그인 폼 다이얼로그
  Future<void> showEmailLoginDialog(BuildContext context) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return EmailLoginDialog();
      },
    );
  }

  // 이메일 회원가입 폼 다이얼로그
  Future<void> showEmailSignUpDialog(BuildContext context) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return EmailSignUpDialog();
      },
    );
  }

  // 프로필 확인하시겠습니까? 다이얼로그
  Future<void> showSignUpCompleteDialog(BuildContext context) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SignUpCompleteDialog();
      },
    );
  }
}

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/error_message.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/widgets/header_logo.dart';
import 'package:get/get.dart';

import '../consts/colors.dart';
import '../consts/routes.dart';
import '../resources/auth_method.dart';
import '../utils/utils.dart';
import '../widgets/line.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading_email = false;
  bool _isLoading_google = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // 이메일로 로그인
  void loginUser() async {
    setState(() {
      _isLoading_email = true;
    });

    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res == USER_NOT_FOUND) {
      showSnackBar("회원으로 등록되어있지 않습니다.", context);
    } else if (res == WRONG_PASSWORD) {
      showSnackBar("비밀번호가 틀렸습니다.", context);
    } else if (res == NOT_CREATED_PROFILE) {
      AnalyticsMethod().logLogin("Email");
      Get.rootDelegate.offNamed(Routes.ADD_PROFILE);
    } else {
      AnalyticsMethod().logLogin("Email");
      Get.rootDelegate.offNamed(Routes.CALENDAR);
    }

    setState(() {
      _isLoading_email = false;
    });
  }

  // 구글로 로그인
  void signInWithGoogle() async {
    setState(() {
      _isLoading_google = true;
    });

    UserCredential cred = await AuthMethods().signInWithGoogle();

    if (await AuthMethods().isSignedUp(uid: cred.user!.uid)) {
      Get.rootDelegate.offNamed(Routes.CALENDAR);
    } else {
      Get.rootDelegate.offNamed(Routes.ADD_PROFILE);
    }
    AnalyticsMethod().logLogin("Google");
    setState(() {
      _isLoading_google = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 25, right: 25),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    HeaderLogo(),
                    Row(children: <Widget>[
                      Text(
                        "계정이 없나요?",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: purple300,
                        ),
                        onPressed: () {
                          Get.rootDelegate.toNamed(Routes.SIGNUP);
                        },
                        child: const Text(
                          '   회원가입   ',
                          style: TextStyle(),
                        ),
                      )
                    ])
                  ])),
          const Line(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 80,
                  ),
                  // 로그인 텍스트
                  Text(
                    '로 그 인',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: purple300,
                    ),
                  ),
                  // 구글로 로그인하기
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: 450,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        signInWithGoogle();
                      },
                      style: ElevatedButton.styleFrom(),
                      child: _isLoading_google
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 100,
                                ),
                                Image.asset(
                                  "assets/images/google_icon.png",
                                  width: 30,
                                  height: 30,
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                const Text(
                                  '구글 계정으로 로그인',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                    ),
                  ),
                  // 줄 그리기
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 2.0,
                    width: 440.0,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 이메일 텍스트 필드
                        SizedBox(
                          width: 450,
                          child: TextFormField(
                            controller: _emailController,
                            validator: (value) =>
                                EmailValidator.validate(value!)
                                    ? null
                                    : "이메일을 입력해주세요",
                            onSaved: (val) {},
                            onFieldSubmitted: (text) {
                              if (_formKey.currentState!.validate()) {
                                loginUser();
                              }
                            },
                            maxLines: 1,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: '이메일',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // 비밀번호 텍스트 필드
                        SizedBox(
                          width: 450,
                          child: TextFormField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '비밀번호를 입력해주세요';
                              }
                              return null;
                            },
                            onSaved: (val) {},
                            onFieldSubmitted: (text) {
                              if (_formKey.currentState!.validate()) {
                                loginUser();
                              }
                            },
                            maxLines: 1,
                            obscureText: true,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: '비밀번호',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        // 로그인 버튼
                        SizedBox(
                          width: 450,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                loginUser();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: purple300,
                            ),
                            child: _isLoading_email
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '이메일로 로그인',
                                    style: TextStyle(),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("계정이 아직 없나요?"),
                              SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  Get.rootDelegate.toNamed(Routes.SIGNUP);
                                },
                                child: Text(
                                  "회원가입",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

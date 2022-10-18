import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/consts/error_message.dart';
import 'package:focus42/utils/analytics_method.dart';
import 'package:focus42/widgets/header_logo.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

import '../consts/colors.dart';
import '../consts/routes.dart';
import '../resources/auth_method.dart';
import '../utils/utils.dart';
import '../widgets/line.dart';

class MobileLoginScreen extends StatefulWidget {
  MobileLoginScreen({Key? key}) : super(key: key);

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading_email = false;
  bool _isLoading_google = false;
  String userAgent = html.window.navigator.userAgent.toString();
  String? invitedGroupId = Uri.base.queryParameters["g"];
  @override
  void initState() {
    // _scrollController.animateTo(1000,
    //     duration: Duration(milliseconds: 300), curve: Curves.ease);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();

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
      AnalyticsMethod().mobileLogLogin("Email");
      invitedGroupId != null
          ? Get.rootDelegate.offNamed(Routes.ADD_PROFILE,
              arguments: true, parameters: {'g': invitedGroupId!})
          : Get.rootDelegate.offNamed(Routes.ADD_PROFILE);
    } else {
      AnalyticsMethod().mobileLogLogin("Email");
      AuthMethods().updateLastLogin();
      invitedGroupId != null
          ? Get.rootDelegate.offNamed(Routes.CALENDAR,
              arguments: true, parameters: {'g': invitedGroupId!})
          : Get.rootDelegate.offNamed(Routes.CALENDAR);
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
      invitedGroupId != null
          ? Get.rootDelegate.offNamed(Routes.CALENDAR,
              arguments: true, parameters: {'g': invitedGroupId!})
          : Get.rootDelegate.offNamed(Routes.CALENDAR);
    } else {
      invitedGroupId != null
          ? Get.rootDelegate.offNamed(Routes.ADD_PROFILE,
              arguments: true, parameters: {'g': invitedGroupId!})
          : Get.rootDelegate.offNamed(Routes.ADD_PROFILE);
    }

    setState(() {
      _isLoading_google = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isKakao = userAgent.contains('KAKAOTALK') ? true : false;
    bool isInsta = userAgent.contains('Instagram') ? true : false;
    bool isIphone = userAgent.contains('iphone') ? true : false;
    // ScrollPosition? scrollPosition;
    // if (_scrollController.hasClients) {
    //   scrollPosition = _scrollController.position;

    // }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        reverse: true,
        controller: _scrollController,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 15, left: 25, right: 25),
                child: HeaderLogo(),
              ),
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
                        '로그인',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: purple300,
                          letterSpacing: 3,
                        ),
                      ),
                      // 구글로 로그인하기
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
                                autofocus: false,
                                controller: _emailController,
                                validator: (value) =>
                                    EmailValidator.validate(value!)
                                        ? null
                                        : "이메일을 입력해주세요",
                                // onSaved: (val) {},
                                textInputAction: TextInputAction.next,
                                onTap: () {
                                  // _scrollController.animateTo(0,
                                  //     duration: Duration(milliseconds: 500),
                                  //     curve: Curves.ease);
                                },
                                onFieldSubmitted: (text) {
                                  // _scrollController.animateTo(viewInsets.bottom,
                                  //     duration: Duration(milliseconds: 500),
                                  //     curve: Curves.ease);
                                },

                                maxLines: 1,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: '이메일',
                                  hintStyle: TextStyle(
                                    color: border200,
                                  ),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(0.0),
                                    child: Icon(
                                      Icons.email,
                                      color: Colors.grey,
                                    ), // icon is 48px widget.
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 0.5),
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
                                onTap: () {
                                  // _scrollController.animateTo(viewInsets.bottom,
                                  //     duration: Duration(milliseconds: 500),
                                  //     curve: Curves.ease);
                                },
                                onEditingComplete: () {
                                  // _scrollController.animateTo(0,
                                  //     duration: Duration(milliseconds: 500),
                                  //     curve: Curves.ease);
                                },
                                maxLines: 1,
                                obscureText: true,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: '비밀번호',
                                  hintStyle: TextStyle(
                                    color: border200,
                                  ),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(0.0),
                                    child: Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                    ), // icon is 48px widget.
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 0.5),
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
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    loginUser();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: purple300,
                                  fixedSize: Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
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
                            SizedBox(
                              width: 450,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (isKakao || isInsta) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                              '구글로 로그인해보세요!',
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  isKakao
                                                      ? '1. 우측 하단의 더보기 버튼을 눌러주세요'
                                                      : '1. 우측 상단의 더보기 버튼을 눌러주세요',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                Text(
                                                  isIphone
                                                      ? '2. "사파리로 열기" 버튼을 눌러주세요'
                                                      : '2. "다른 브라우저로 열기" 버튼을 눌러주세요',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text('Ok'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  } else {
                                    signInWithGoogle();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  fixedSize: Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading_google
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: purple200,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // SizedBox(
                                          //   width: 100,
                                          // ),
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
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
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
                                      invitedGroupId != null
                                          ? Get.rootDelegate.toNamed(
                                              Routes.SIGNUP,
                                              arguments: true,
                                              parameters: {
                                                  'g': invitedGroupId!
                                                })
                                          : Get.rootDelegate
                                              .toNamed(Routes.SIGNUP);
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
        ),
      ),
    );
  }
}

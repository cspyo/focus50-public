import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/utils/utils.dart';

import '../consts/colors.dart';
import '../resources/auth_method.dart';
import '../widgets/line.dart';

class SignupEmailScreen extends StatefulWidget {
  SignupEmailScreen({Key? key}) : super(key: key);

  @override
  State<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends State<SignupEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading_email = false;
  bool _isLoading_google = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signUpWithEmail() async {
    setState(() {
      _isLoading_email = true;
    });

    String res = await AuthMethods().signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res == 'email-already-in-use') {
      showSnackBar("이미 존재하는 이메일입니다.", context);
    } else if (res == 'success') {
      Navigator.pushNamed(context, '/addProfile');
    } else {}

    setState(() {
      _isLoading_email = false;
    });
  }

  // 구글로 로그인
  void signUpWithGoogle() async {
    setState(() {
      _isLoading_google = true;
    });

    UserCredential cred = await AuthMethods().signInWithGoogle();

    if (await AuthMethods().isSignedUp(uid: cred.user!.uid)) {
      Navigator.pushNamed(context, '/calendar');
    } else {
      Navigator.pushNamed(context, '/addProfile');
    }
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
                    Row(
                      children: const <Widget>[
                        Text('Focus',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 30,
                                color: Colors.black)),
                        Text('50',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w900,
                                fontSize: 30,
                                color: purple300)),
                      ],
                    ),
                    Row(children: <Widget>[
                      Text(
                        "Already have an account?",
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
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          '    Log In    ',
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
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: purple300,
                    ),
                  ),
                  SizedBox(
                    height: 30,
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
                                    : "Please enter a valid email",
                            onSaved: (val) {},
                            maxLines: 1,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email',
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
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            onSaved: (val) {},
                            maxLines: 1,
                            obscureText: true,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // 로그인 버튼
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 300,
                              height: 40,
                            ),
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    signUpWithEmail();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: purple300,
                                ),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 줄 그리기
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 2.0,
                          width: 440.0,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 450,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              signUpWithGoogle();
                            },
                            style: ElevatedButton.styleFrom(),
                            child: _isLoading_google
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sign up with Google',
                                    style: TextStyle(
                                      fontFamily: 'poppins',
                                    ),
                                  ),
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

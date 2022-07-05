import 'package:flutter/material.dart';

import '../consts/colors.dart';
import '../widgets/line.dart';

class SignupScreenDemo extends StatefulWidget {
  SignupScreenDemo({Key? key}) : super(key: key);

  @override
  State<SignupScreenDemo> createState() => _SignupScreenDemoState();
}

class _SignupScreenDemoState extends State<SignupScreenDemo> {
  final _formKey = GlobalKey<FormState>();

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
                        "Do you have an account?",
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
                          '    Login    ',
                          style: TextStyle(),
                        ),
                      )
                    ])
                  ])),
          const Line(),
          Container(
            // padding: MediaQuery.of(context).size.width > webScreenSize
            //     ? EdgeInsets.symmetric(
            //         horizontal: MediaQuery.of(context).size.width / 3)
            //     : const EdgeInsets.symmetric(horizontal: 32),
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
                    'Sign up',
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
                        // 이름 텍스트 필드
                        SizedBox(
                          width: 450,
                          child: TextFormField(
                            onSaved: (val) {
                              setState(() {
                                //this.name = val;
                              });
                            },
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // 닉네임 텍스트 필드
                        SizedBox(
                          width: 450,
                          child: TextFormField(
                            onSaved: (val) {
                              setState(() {
                                //this.nickname = val;
                              });
                            },
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Nickname',
                              prefixIcon: const Icon(Icons.article),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // job 텍스트 필드
                        SizedBox(
                          width: 450,
                          child: TextFormField(
                            onSaved: (val) {
                              setState(() {
                                //this.nickname = val;
                              });
                            },
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Job',
                              prefixIcon: const Icon(Icons.person),
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
                        SizedBox(
                          width: 450,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {}
                              this._formKey.currentState?.save();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: purple300,
                            ),
                            child: const Text(
                              'Get started',
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

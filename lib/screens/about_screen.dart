import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus42/widgets/desktop_header.dart';
import 'package:webviewx/webviewx.dart';

import '../widgets/line.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late WebViewXController webviewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      DesktopHeader(),
      const Line(),
      Expanded(
        child: WebViewX(
          initialContent: Uri.base.origin + "/about",
          initialSourceType: SourceType.url,
          onWebViewCreated: (controller) {
            webviewController = controller;
            // webviewController.loadContent(
            //   '/about/index.html',
            //   SourceType.url,
            // );
          },
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    ]));
  }
}

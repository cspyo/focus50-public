import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';

class KakaoSyncDialog extends ConsumerStatefulWidget {
  final Function() notifyParent;
  const KakaoSyncDialog({Key? key, required this.notifyParent})
      : super(key: key);

  @override
  _KakaoSyncDialogState createState() => _KakaoSyncDialogState();
}

class _KakaoSyncDialogState extends ConsumerState<KakaoSyncDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // <-- SEE HERE
      title: _buildDialogTitle(),
      content: _buildKakaoSync(context),
    );
  }

  // 다이얼로그 타이틀
  Widget _buildDialogTitle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Focus',
              style: TextStyle(
                fontFamily: 'Okddung',
                fontSize: 25,
                color: Colors.black,
              ),
            ),
            Text(
              '50',
              style: TextStyle(
                fontFamily: 'Okddung',
                fontSize: 25,
                color: purple300,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          '카카오 연동하기',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // 카카오 연동
  Widget _buildKakaoSync(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 400,
        child: ListBody(
          children: <Widget>[
            _buildExplainText(),
            SizedBox(height: 20),
            _buildKakaoSyncButton(),
            SizedBox(height: 20),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExplainText() {
    return Text("");
  }

  // 카카오 회원가입 버튼
  Widget _buildKakaoSyncButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(200, 48),
          primary: Color(0xFFFEE500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          ),
          elevation: 4,
        ),
        onPressed: widget.notifyParent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              color: Colors.black,
              size: 20,
            ),
            SizedBox(width: 10),
            const Text(
              '  카카오로 회원가입  ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(220, 0, 0, 0),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Text("");
  }
}

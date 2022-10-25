import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';

// * Provider 를 이용해 이번 미팅 상대방들의 투두를 List 타입으로 관리할 수 있어야 한다. : List< Map< String, List<TodoModel> > >
// * MeetingScreen 으로부터 provider 를 이용하여 추척할 reservation docId 를 매개변수로 넘겨 받는다.

class SessionPartnerTodoList extends ConsumerStatefulWidget {
  SessionPartnerTodoList();

  @override
  _SessionPartnerTodoListState createState() => _SessionPartnerTodoListState();
}

class _SessionPartnerTodoListState
    extends ConsumerState<SessionPartnerTodoList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.black.withOpacity(0.2),
        padding: EdgeInsets.all(20.0),
        // child: Container(
        //   width: 40,
        //   child: TextButton(
        //     onPressed: _onLike,
        //     child: Icon(
        //       Icons.favorite,
        //       color: Colors.black45,
        //     ),
        //   ),
        // ),
        child: Align(
          alignment: Alignment.topLeft,
          child: _buildPartnerTodoList(),
        ),
      ),
    );
  }

  Widget _buildPartnerTodoList() {
    return Container(
      width: 300,
      height: 120,
      margin: EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 15),
            child: Text(
              'A 님의 할 일',
              style: MyTextStyle.CbS20W600,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            // Todo: 수정하기
            child: _buildTodoItem(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          width: 1.0,
          color: Colors.black,
        ),
      ),
      height: 40,
      child: Row(
        children: [
          TextButton(
            onPressed: null,
            child: Icon(Icons.arrow_forward_ios, color: Colors.black),
          ),
          Expanded(
            child: Container(
              child: Text(
                "Temp Todo1",
                style: MyTextStyle.CbS18W400,
              ),
            ),
          ),
          Container(
            width: 40,
            child: TextButton(
              onPressed: _onLike,
              child: Icon(
                Icons.favorite,
                color: Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onLike() {}
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/jitsi/presentation/session_todo_item_widget.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/feature/jitsi/provider/provider.dart';
import 'package:focus42/models/todo_model.dart';

class SessionTodoList extends ConsumerStatefulWidget {
  const SessionTodoList();

  @override
  _SessionTodoListState createState() => _SessionTodoListState();
}

class _SessionTodoListState extends ConsumerState<SessionTodoList> {
  _SessionTodoListState() : super();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(top: 15),
          child: Text(
            '이번 세션 할 일',
            style: MyTextStyle.CbS20W600,
          ),
        ),
        Container(
          width: 350,
          height: 60,
          padding: EdgeInsets.only(top: 15),
          child: _buildButtonEntireTodo(context),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(
              maxWidth: 380,
              maxHeight: 180,
            ),
            // Todo: 수정하기
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildTodoItem(),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          width: 350,
          height: 60,
          // Todo: 수정하기
          child: Align(
            alignment: Alignment.centerRight,
            child: _buildPartnerTodoToggle(),
          ),
        ),
      ]),
    );
  }

  Widget _buildButtonEntireTodo(BuildContext context) {
    return TextButton(
        onPressed: () => {_popupTodoDialog(context)},
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(color: Colors.transparent))),
          backgroundColor:
              MaterialStateProperty.all<Color>(MyColors.blackSession),
        ),
        child: Text(
          '전체목록',
          style: MyTextStyle.CwS20W400,
        ));
  }

  Widget _buildPartnerTodoToggle() {
    final _state = ref.watch(partnerTodoToggleStateProvider);
    return TextButton(
      onPressed: _togglePartnerTodo,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Colors.transparent))),
        backgroundColor:
            MaterialStateProperty.all<Color>(MyColors.blackSession),
      ),
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: (_state == false)
            ? Text(
                '상대 투두 보기',
                style: MyTextStyle.CwS16W400,
              )
            : Text(
                '상대 투두 접기',
                style: MyTextStyle.CwS16W400,
              ),
      ),
    );
  }

  void _togglePartnerTodo() {
    if (ref.read(partnerTodoToggleStateProvider.notifier).state == true) {
      // print("[DEBUG] toggle state->false");
      ref.read(partnerTodoToggleStateProvider.notifier).state = false;
    } else {
      // print("[DEBUG] toggle state->true");
      ref.read(partnerTodoToggleStateProvider.notifier).state = true;
    }
  }

  Future<dynamic> _popupTodoDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Stack(
            // ?: clipBehavior: Clip.none
            clipBehavior: Clip.none,
            children: <Widget>[
              // Todo: 투두 리스트 빌더 넣기
              Text("TODO")
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodoItem() {
    // return Align(
    //   alignment: Alignment.topCenter,
    //   child: Container(
    //     margin: EdgeInsets.only(top: 9),
    //     width: 350,
    //     height: 60,
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.circular(16),
    //       border: Border.all(
    //         width: 1.5,
    //         color: MyColors.border100,
    //       ),
    //     ),
    //     child: Row(
    //       children: [
    //         TextButton(
    //           onPressed: null,
    //           child: Icon(Icons.radio_button_unchecked, color: Colors.black),
    //         ),
    //         Container(
    //             width: 235,
    //             child: Text(
    //               task,
    //               style: MyTextStyle.CbS18W400,
    //             )),
    //       ],
    //     ),
    //   ),
    // );

    // return ListView.builder(
    //   scrollDirection: Axis.vertical,
    //   itemCount: myTodo.length,
    //   itemBuilder: (BuildContext context, int index) {
    //     return SessionTodoItem();
    //   },
    // );
    final TodoModel _todo = TodoModel(
      task: "할 일 1",
      isComplete: false,
    );
    return SessionTodoItem(todoItem: _todo);
  }
}

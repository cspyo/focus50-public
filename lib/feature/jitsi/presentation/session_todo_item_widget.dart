import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/models/todo_model.dart';

// * Todo Check / Update / Delete 시나리오
// * 1) 매개변수 : TodoModel
// *    SessionTodo 에서 Listbuilder 로 SessionTodoItem 을 빌드한다
// *    이 때, SessionTodoItem 에서 데이터베이스를 업데이트 하면 SessionTodo 에서 List 정보가 업데이트 되고
// *    SessionTodo 가 재렌더링 된다. 그러면서 SessionTodoItem 을 재렌더링 한다.
// *    단점: 매 업데이트마다 리스티빌더가 새로운 SessionTodoItem 을 만드는 까닭에 오버헤드가 발생할 수 있다.
// * 2) 매개변수 : Todo docId
// *    SessionTodo 에서 SessionTodoItem 을 빌드할 때 docId 를 넘긴다.
// *    SessionTodoItem 에서 provider 를 이용하여 docId 에 해당하는 todo document 를 추적한다.
// *    이 때, SessionTodoItem 에서 데이터베이스를 업데이트 하면 SessionTodoItem 이 재렌더링 된다.
// *    단점: todo 정보 업데이트 시 -> SessionTodo & SessionTodoItem 모두 렌더링이 다시 될 수 있다.

class SessionTodoItem extends ConsumerStatefulWidget {
  final TodoModel todoItem;

  const SessionTodoItem({required this.todoItem});

  @override
  _SessionTodoItemState createState() => _SessionTodoItemState();
}

class _SessionTodoItemState extends ConsumerState<SessionTodoItem> {
  bool isHover = false;
  bool isEdit = false;
  late final TodoModel todoItem;

  @override
  void initState() {
    todoItem = widget.todoItem;
    super.initState();
  }

  void _onHover(PointerEvent details) {
    setState(() {
      isHover = true;
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      isHover = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 9),
      width: 350,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          width: 1.5,
          // color: border100,
        ),
      ),
      child: MouseRegion(
        onEnter: _onHover,
        onExit: _onExit,
        child: Container(
          width: 350,
          height: 60,
          child: Row(
            children: [
              _buildCheckedButton(),
              _buildTaskText(),
              _buildEditButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckedButton() {
    return TextButton(
      onPressed: _onCheck,
      child: todoItem.isComplete!
          ? Icon(Icons.radio_button_checked, color: Colors.black)
          : Icon(Icons.radio_button_unchecked, color: Colors.black),
    );
  }

  Widget _buildTaskText() {
    return Expanded(
      child: todoItem.isComplete!
          ? Container(
              child: Text(
                todoItem.task!,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            )
          : isEdit
              ? Container(
                  child: TextFormField(
                    autofocus: true,
                    initialValue: todoItem.task!,
                    onFieldSubmitted: (value) {
                      _onSubmitEdited(value);
                    },
                  ),
                )
              : Container(
                  child: Text(
                    todoItem.task!,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
    );
  }

  Widget _buildEditButton() {
    return Container(
      alignment: Alignment.centerRight,
      child: isHover && !todoItem.isComplete!
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 40,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        isEdit = true;
                      });
                    },
                    child: Container(
                      width: 30,
                      child: Icon(
                        Icons.edit,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  child: TextButton(
                    onPressed: _onDelete,
                    child: Container(
                      width: 30,
                      child: Icon(
                        Icons.delete,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 40,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red[200],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Text(
                    "4",
                    style: MyTextStyle.CbS18W400,
                  ),
                )
              ],
            ),
    );
    // return Align(
    //   alignment: Alignment.centerRight,
    //   child:
  }

  void _onCheck() {
    // setState(() {
    //   TodoModel newTodo;
    //   if (!isCompleted) {
    //     newTodo = TodoModel(
    //       completedDate: DateTime.now(),
    //       isCompleted: !isCompleted,
    //       assignedSessionId: assignedSessionId,
    //     );
    //   } else {
    //     newTodo = TodoModel(
    //       completedDate: DateTime.fromMicrosecondsSinceEpoch(0),
    //       isCompleted: !isCompleted,
    //       assignedSessionId: assignedSessionId,
    //     );
    //   }
    //   _todoColRef.doc(widget.docId).update(newTodo.toUpdateFirestore());
    // });
  }

  void _onSubmitEdited(value) {
    // setState(() async {
    //   TodoModel newTodo = TodoModel(
    //       task: value,
    //       modifiedDate: DateTime.now(),
    //       assignedSessionId: assignedSessionId);
    //   _todoColRef.doc(widget.docId).update(newTodo.toUpdateFirestore());
    //   isEdit = false;
    // });
  }

  void _onDelete() {
    // _todoColRef.doc(widget.docId).delete();
  }
}

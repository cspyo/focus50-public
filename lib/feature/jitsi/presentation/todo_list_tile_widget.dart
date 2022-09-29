import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/feature/jitsi/provider/provider.dart';
import 'package:focus42/models/todo_model.dart';
import 'package:focus42/top_level_providers.dart';

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

class TodoListTile extends ConsumerWidget {
  const TodoListTile({
    required this.model,
    required this.contentWidth,
    required this.reservationId,
  });
  final TodoModel model;
  final String? reservationId;
  final double contentWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    final _entireTodoFocusState = ref.watch(entireTodoFocusStateProvider);
    return Center(
      child: Container(
        width: contentWidth,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            _buildHeadButton(database, _entireTodoFocusState),
            _buildTaskText(context),
            _buildDeleteButton(database),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadButton(database, _entireTodoFocusState) {
    return (_entireTodoFocusState)
        ? _buildAssignButton(database)
        : _buildCompleteButton(database);
  }

  Widget _buildCompleteButton(database) {
    return TextButton(
      onPressed: () {
        _onComplete(database);
      },
      child: model.isComplete!
          ? Icon(Icons.radio_button_checked, color: Colors.black)
          : Icon(Icons.radio_button_unchecked, color: Colors.black),
    );
  }

  Widget _buildAssignButton(database) {
    return TextButton(
      onPressed: () {
        _onAssign(database);
      },
      child: model.assignedSessionId != reservationId
          ? Icon(Icons.check_box_outline_blank, color: Colors.black)
          : Icon(Icons.check, color: Colors.black),
    );
  }

  Widget _buildTaskText(BuildContext context) {
    return Expanded(
      child: model.isComplete!
          ? Container(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                model.task!,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                model.task!,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
    );
  }

  Widget _buildDeleteButton(database) {
    return Container(
      width: 40,
      child: TextButton(
        onPressed: () {
          _onDelete(database);
        },
        child: Container(
          width: 30,
          child: Icon(
            Icons.delete,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _onComplete(database) {
    if (model.isComplete == false) {
      database.setTodo(model.doComplete());
    } else {
      database.setTodo(model.undoComplete());
    }
  }

  void _onAssign(database) {
    if (model.assignedSessionId != reservationId) {
      database.setTodo(model.doAssign(reservationId!));
    } else {
      database.setTodo(model.undoAssign());
    }
  }

  void _onSubmit(text, database) {
    database.setTodo(model.editTask(text));
  }

  void _onDelete(database) {
    database.deleteTodo(model);
  }
}

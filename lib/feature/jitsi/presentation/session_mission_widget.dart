import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/feature/jitsi/provider/provider.dart';
// import 'package:focus42/widgets/mirai_dropdown_item_widget.dart';
// import 'package:focus42/widgets/dropdown_button_widget.dart';

class SessionMission extends ConsumerStatefulWidget {
  const SessionMission();

  @override
  _SessionMissionState createState() => _SessionMissionState();
}

class _SessionMissionState extends ConsumerState<SessionMission> {
  _SessionMissionState() : super();

  final TextEditingController _controller =
      TextEditingController(text: "임시 할 일 1");
  bool _isTextEditEnable = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildMissiontext(_screenWidth),
          // _buildCheckedButton(),
          _buildTaskText(),
          _buildEntireButton(),
        ],
      ),
    );
  }

  Widget _buildMissiontext(_screenWidth) {
    final double _missionHeight = 40.0;
    return _screenWidth > 560
        ? Container(
            width: 20.0,
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: _missionHeight,
            child: Icon(Icons.assignment_rounded, color: Colors.white))
        : SizedBox.shrink();
    ;
  }

  // Widget _buildCheckedButton() {
  //   final double _missionHeight = 40.0;
  //   return Container(
  //       width: 20.0,
  //       margin: EdgeInsets.symmetric(horizontal: 10),
  //       height: _missionHeight,
  //       child:
  //           Icon(Icons.check_box_outline_blank_rounded, color: Colors.white));
  // }

  Widget _buildTaskText() {
    // Todo: 클릭하였을 때 바로 수정할 수 있게 하기
    final double _missionHeight = 36.0;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTextEditEnable = true;
        });
      },
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(
          //   width: 1.5,
          // ),
        ),
        padding: EdgeInsets.only(
          right: 10,
        ),
        // child: ListItemsBuilder
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 20.0,
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: _missionHeight,
              child: Icon(Icons.check_box_outline_blank_rounded,
                  color: Colors.black),
            ),
            Container(
              width: 210.0,
              height: _missionHeight,
              child: TextField(
                controller: _controller,
                enabled: _isTextEditEnable,
                style: MyTextStyle.CbS18W400,
                mouseCursor: (_isTextEditEnable)
                    ? SystemMouseCursors.text
                    : SystemMouseCursors.click,
                decoration: InputDecoration(
                  hintText: '미션을 작성해주세요',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                  border: InputBorder.none,
                ),
                onSubmitted: (text) {
                  _onTextSubmit(text);
                },
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.edit,
                color: Colors.black,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntireButton() {
    final _entireTodoTogglestate = ref.watch(entireTodoFocusStateProvider);
    return SizedBox(
      width: 40,
      child: IconButton(
        onPressed: _toggleEntireButton,
        icon: _entireTodoTogglestate
            ? Icon(
                Icons.arrow_drop_up,
                size: 32,
                color: Colors.white,
              )
            : Icon(
                Icons.arrow_drop_down,
                size: 32,
                color: Colors.white,
              ),
      ),
    );
  }

  void _toggleEntireButton() {
    if (ref.read(entireTodoFocusStateProvider.notifier).state == true) {
      ref.read(entireTodoFocusStateProvider.notifier).state = false;
    } else {
      ref.read(entireTodoFocusStateProvider.notifier).state = true;
    }
  }

  void _onTextSubmit(text) {
    setState(() {
      _isTextEditEnable = false;
    });
  }
}

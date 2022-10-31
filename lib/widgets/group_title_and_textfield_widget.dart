import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';

class BuildTitleAndTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final int index;
  final bool isGroupNameOverlap;
  final bool isAbleToModify;
  BuildTitleAndTextField(
      {Key? key,
      required this.hintText,
      required this.controller,
      required this.index,
      required this.isGroupNameOverlap,
      required this.isAbleToModify})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: [
          TextFormField(
            validator: (value) {
              return index == 0
                  ? (value == null || value.isEmpty)
                      ? '$hintText를 입력해주세요'
                      : isGroupNameOverlap
                          ? '이미 있는 그룹 명입니다. 다른 이름을 적어주세요'
                          : value.length > 12
                              ? '12자 이내의 이름을 적어주세요'
                              : null
                  : null;
            },
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            controller: controller,
            cursorColor: Colors.black,
            cursorHeight: 18,
            maxLines: index == 2 ? null : 1,
            enabled: isAbleToModify,
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  style: BorderStyle.solid,
                ),
              ),
              contentPadding: EdgeInsets.all(4),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: purple300)),
              labelText: hintText,
              labelStyle: TextStyle(
                  color: Color.fromARGB(255, 75, 75, 75),
                  fontSize: 14,
                  fontWeight: FontWeight.w300),
              floatingLabelStyle: TextStyle(
                color: purple300,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}

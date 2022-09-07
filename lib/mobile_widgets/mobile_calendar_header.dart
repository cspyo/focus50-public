import 'package:flutter/material.dart';
import 'package:focus42/consts/colors.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MobileCalendarHeader extends StatelessWidget {
  MobileCalendarHeader({
    Key? key,
    required this.calendarController,
    // required this.visibleDates,
  }) : super(key: key);
  CalendarController calendarController;
  // List<DateTime> visibleDates;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth - 40,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          border: Border(
              // color: border100, width: 1.5,
              // top: BorderSide(color: border100, width: 1.5),
              // right: BorderSide(color: border100, width: 1.5),
              // left: BorderSide(color: border100, width: 1.5),
              )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: purple300,
            ),
            onPressed: () {
              calendarController.backward!();
            },
          ),
          Text(
            'AUg 22',
            style: TextStyle(
              fontSize: 20,
              color: purple300,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: purple300,
            ),
            onPressed: () {
              calendarController.forward!();
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/feature/jitsi/presentation/list_items_builder_2.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/feature/peer_feedback/presentation/popup_peer_feedback.dart';
import 'package:focus42/mobile_widgets/mobile_calendar.dart';
import 'package:focus42/mobile_widgets/mobile_drawer.dart';
import 'package:focus42/mobile_widgets/mobile_group_widget.dart';
import 'package:focus42/mobile_widgets/mobile_reservation.dart';
import 'package:focus42/mobile_widgets/mobile_row_group_toggle_button_widget.dart';
import 'package:focus42/models/group_model.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/view_models.dart/reservation_view_model.dart';
import 'package:focus42/widgets/group_widget.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/line.dart';

class MobileCalendarScreen extends ConsumerStatefulWidget {
  MobileCalendarScreen({Key? key}) : super(key: key);
  @override
  _MobileCalendarScreenState createState() => _MobileCalendarScreenState();
}

class _MobileCalendarScreenState extends ConsumerState<MobileCalendarScreen> {
  late final FirestoreDatabase database;
  bool isNotificationOpen = true;
  CalendarController calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    database = ref.read(databaseProvider);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => popupPeerFeedbacks(database, context));
  }

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final _myGroupStream = ref.watch(myGroupFutureProvider);
    final _myActivatedGroupId = ref.watch(activatedGroupIdProvider);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Focus',
                style: TextStyle(
                  fontFamily: 'Okddung',
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              Text(
                '50',
                style: TextStyle(
                  fontFamily: 'Okddung',
                  fontSize: 30,
                  color: purple300,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: purple300),
        ),
        drawer: MobileDrawer(),
        body: SingleChildScrollView(
          child: Column(
            //페이지 전체 구성
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Line(),
              Column(children: <Widget>[
                // Container(
                //   child: MobileReservation(),
                // ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: screenWidth - 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '그룹',
                        style: MyTextStyle.CgS18W500,
                      ),
                      Container(width: 68, height: 32, child: MobileGroup()),
                    ],
                  ),
                ),
                Container(
                  width: screenWidth - 40,
                  height: 80,
                  child: ListItemsBuilder2<GroupModel>(
                    data: _myGroupStream,
                    itemBuilder: (context, model) =>
                        MobilRowGroupToggleButtonWidget(
                      group: model,
                      isThisGroupActivated:
                          _myActivatedGroupId == model.id ? true : false,
                    ),
                    creator: () => new GroupModel(
                      id: 'public',
                      name: '전체',
                    ),
                    axis: Axis.horizontal,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: border100)),
                  height: screenHeight - 245,
                  child: MobileCalendar(
                    calendarController: calendarController,
                    isNotificationOpen: isNotificationOpen,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: MyColors.purple300,
                  ),
                  child: MobileReservation(),
                ),
              ])
            ],
          ),
        ));
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    required String route,
  }) {
    final color = Colors.white;
    return ListTile(
        leading: Icon(icon, color: color),
        onTap: () {
          Get.rootDelegate.toNamed(route);
        },
        title: Text(
          text,
          style: TextStyle(color: color),
        ));
  }
}

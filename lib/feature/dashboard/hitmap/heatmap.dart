import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/models/reservation_model.dart';

class Heatmap extends ConsumerStatefulWidget {
  const Heatmap({Key? key}) : super(key: key);

  @override
  _HeatmapState createState() => _HeatmapState();
}

class _HeatmapState extends ConsumerState<Heatmap> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController heatLevelController = TextEditingController();

  late DateTime startDate;
  late DateTime endDate;

  Map<DateTime, int> heatMapDatasets = {};

  @override
  void dispose() {
    super.dispose();
    dateController.dispose();
    heatLevelController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _makeHeatmapDate();
    _getMyReservationCount();
  }

  void _makeHeatmapDate() {
    DateTime now = DateTime.now();
    startDate = DateTime(now.year, now.month - 5, now.day);
    endDate = now;
  }

  void _getMyReservationCount() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection("reservation")
        .where("userIds", arrayContains: uid)
        .orderBy("startTime", descending: true)
        .get();

    if (querySnapshot.size == 0) {
      return;
    }

    Map<DateTime, int> reservationCount = {};

    DateTime before = DateTime(2000, 1, 1);
    int count = 1;
    querySnapshot.docs.forEach((docSnap) {
      ReservationModel reservation = ReservationModel.fromMap(docSnap, null);
      bool isEntered = reservation.userInfos?[uid]?.enterDTTM != null;
      DateTime startTime = reservation.startTime!;
      DateTime date = DateTime(startTime.year, startTime.month, startTime.day);
      if (before != date) {
        reservationCount.addAll({date: count});
        before = date;
        count = 1;
      } else {
        count = count + 1;
      }
    });
    reservationCount.forEach((key, value) {
      print("${key} : ${value}");
    });
    setState(() {
      heatMapDatasets = reservationCount;
    });
  }

  Widget _textField(final String hint, final TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 20, top: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffe7e7e7), width: 1.0)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF20bca4), width: 1.0)),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(20),
          elevation: 20,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: HeatMap(
              startDate: startDate,
              endDate: endDate,
              scrollable: true,
              colorMode: ColorMode.opacity,
              datasets: heatMapDatasets,
              colorsets: const {
                1: MyColors.purple300,
              },
              onClick: (value) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(value.toString())));
              },
            ),
          ),
        ),
        _textField('YYYYMMDD', dateController),
        _textField('Heat Level', heatLevelController),
        ElevatedButton(
          child: const Text('COMMIT'),
          onPressed: () {
            setState(() {
              heatMapDatasets[DateTime.parse(dateController.text)] =
                  int.parse(heatLevelController.text);
            });
          },
        ),
      ],
    );
  }
}

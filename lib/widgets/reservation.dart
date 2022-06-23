import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation extends StatefulWidget {
  const Reservation({Key? key}) : super(key: key);
  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  late var data = {};
  void getReservation() {
    final docRef =
        FirebaseFirestore.instance.collection('reservation').doc('jaewontop');
    docRef.get().then(
      (DocumentSnapshot doc) {
        data = doc.data() as Map<String, dynamic>;
        print(data);
      },
      onError: (e) => print("error: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Text(data.toString()),
    );
  }
}

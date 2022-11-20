import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus50/feature/calendar/data/reservation_model.dart';

class RatingModel {
  String? id;
  final double? rating;
  final String? reservationId;
  final ReservationModel? reservationDetail;
  final String? createdBy;
  final DateTime? createdDate;

//default Constructor
  RatingModel({
    this.id,
    this.rating,
    this.reservationId,
    this.reservationDetail,
    this.createdBy,
    this.createdDate,
  });

  factory RatingModel.newRating({
    required double rating,
    required String reservationId,
    required ReservationModel reservationDetail,
    required String createdBy,
  }) {
    DateTime now = DateTime.now();
    return RatingModel(
      rating: rating,
      reservationId: reservationId,
      reservationDetail: reservationDetail,
      createdBy: createdBy,
      createdDate: now,
    );
  }

  factory RatingModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final ReservationModel reservationDetail = new ReservationModel(
      id: data?['reservationDetail']['id'],
      startTime: data?['reservationDetail']['startTime']?.toDate() as DateTime,
      endTime: data?['reservationDetail']['endTime']?.toDate() as DateTime,
      headcount: data?['reservationDetail']['headcount'],
      userIds: data?['reservationDetail']['userIds'] is Iterable
          ? List.from(data?['reservationDetail']['userIds'])
          : null,
      groupId: data?['reservationDetail']['groupId'],
    );

    return RatingModel(
      id: snapshot.id,
      rating: data?['rating'],
      reservationId: data?['reservationId'],
      createdBy: data?['createdBy'],
      createdDate: data?['createdDate']?.toDate() as DateTime,
      reservationDetail: reservationDetail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (rating != null) 'rating': rating,
      if (reservationId != null) 'reservationId': reservationId,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdDate != null) 'createdDate': createdDate,
      if (reservationDetail != null)
        'reservationDetail': reservationDetail!.toMap(),
    };
  }
}

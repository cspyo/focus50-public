import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus50/feature/calendar/data/reservation_model.dart';
import 'package:focus50/feature/focus_rating/data/rating_model.dart';
import 'package:focus50/feature/focus_rating/view_model/provider.dart';
import 'package:focus50/feature/peer_feedback/provider/provider.dart';
import 'package:focus50/services/firestore_database.dart';

void rateFocus(
    FirestoreDatabase database, WidgetRef ref, ReservationModel reservation) {
  final double rating = ref.read(ratingCountStateProvider);
  final String reservationId = ref.read(runningSessionIdProvider);
  database.setRating(RatingModel.newRating(
      rating: rating,
      reservationId: reservationId,
      reservationDetail: reservation,
      createdBy: database.uid));
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/models/user_public_model.dart';
import 'package:focus42/services/firestore_database.dart';
import 'package:focus42/top_level_providers.dart';
import 'package:focus42/view_models.dart/appointments_notifier.dart';
import 'package:focus42/view_models.dart/timeregions_notifier.dart';
import 'package:focus42/view_models.dart/users_notifier.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final reservationViewModelProvider = Provider.autoDispose<ReservationViewModel>(
  (ref) {
    final database = ref.watch(databaseProvider);
    return ReservationViewModel(database: database, ref: ref);
  },
);

class ReservationViewModel {
  ReservationViewModel({required this.database, required this.ref});
  final FirestoreDatabase database;
  final Ref ref;

  List<Appointment> appointments = <Appointment>[];

  List<DateTime> cantHoverTimeList = <DateTime>[];
  List<DateTime> reservationTimeList = <DateTime>[];

  final LOADING_RESERVE = "loading reserve";
  final LOADING_CANCEL = "loading cancel";

  final RESERVE = "reserve";
  final MATCHING = "matching";
  final MATCHED = "matched";
  final CANCEL = "cancel";

  final HOVER = "hover";
  final CANT_RESERVE = "cant reserve";

  bool isSignedUp = false;

  late StreamSubscription<List<ReservationModel>> streamSubscription;

  void cancelListener() {
    streamSubscription.cancel();
  }

  void startView() {
    if (database.uid == "none") {
      getOthersReservation();
    } else {
      listenAllReservation();
    }
  }

  // 모든 예약에 변경이 생기면 업데이트
  void listenAllReservation() async {
    final usersNotifier = ref.read(usersProvider.notifier);
    final myUid = database.uid;
    final myInfo = await database.getUserPublic();
    if (myInfo.nickname != null) {
      usersNotifier.addAll({myUid: myInfo});
      isSignedUp = true;
    } else {
      isSignedUp = false;
    }

    streamSubscription =
        database.allReservationsStream().listen((reservations) async {
      final appointmentsNotifier = ref.read(appointmentsProvider.notifier);
      final timeRegionNotifier = ref.read(timeRegionsProvider.notifier);
      final usersNotifier = ref.read(usersProvider.notifier);

      // 모든 예약들 안의 유저들 정보 먼저
      await Future.forEach(reservations, (ReservationModel reservation) async {
        await Future.forEach(reservation.userIds!, ((String uid) async {
          if (!usersNotifier.containsKey(uid)) {
            UserPublicModel? userInfo =
                await database.getUserPublic(othersUid: uid);
            usersNotifier.addAll({uid: userInfo});
          }
        }));
      });

      List<ReservationModel> myReservations = [];
      List<ReservationModel> othersReservations = [];

      reservations.forEach((reservation) {
        if (reservation.userIds!.contains(myUid)) {
          myReservations.add(reservation);
        } else {
          if (!reservation.isFull!) {
            othersReservations.add(reservation);
          }
        }
      });

      appointmentsNotifier.clear();
      timeRegionNotifier.clearCantReserveRegions();
      cantHoverTimeList.clear();
      reservationTimeList.clear();

      // 내 예약 먼저
      for (ReservationModel reservation in myReservations) {
        DateTime startTime = reservation.startTime!;
        Appointment appointment;

        // 매칭이 완료된 예약이라면
        if (reservation.headcount! >= 2) {
          String userIdsString = reservation.userIds!.join(',');
          appointment = Appointment(
            startTime: reservation.startTime!,
            endTime: reservation.endTime!,
            notes: userIdsString,
            subject: MATCHED, // LOADING,MATCHING,MATCHED
            id: reservation.id,
          );
        } else {
          // 매칭이 안된 예약이라면
          appointment = Appointment(
            startTime: reservation.startTime!,
            endTime: reservation.endTime!,
            subject: MATCHING,
            id: reservation.id,
          );
        }
        appointmentsNotifier.deleteAppointment(startTime);
        appointmentsNotifier.addAppointment(appointment);

        timeRegionNotifier.addCantReserveRegions(
          TimeRegion(
            startTime: startTime.subtract(Duration(minutes: 30)),
            endTime: startTime.add(Duration(minutes: 60)),
            enablePointerInteraction: false,
            text: CANT_RESERVE,
          ),
        );

        cantHoverTimeList.add(startTime);
        cantHoverTimeList.add(startTime.add(Duration(minutes: 30)));
        cantHoverTimeList.add(startTime.subtract(Duration(minutes: 30)));

        reservationTimeList.add(startTime);
        reservationTimeList.add(startTime.add(Duration(minutes: 30)));
        reservationTimeList.add(startTime.subtract(Duration(minutes: 30)));
      }

      timeRegionNotifier.clearReservationRegions();
      othersReservations.removeWhere((element) {
        return element.startTime!.difference(DateTime.now()) < Duration.zero;
      });
      for (ReservationModel reservation in othersReservations) {
        if (!(reservationTimeList.contains(reservation.startTime))) {
          String userIdsString = reservation.userIds!.join(',');
          DateTime startTime = reservation.startTime!;
          timeRegionNotifier.addReservationRegions(TimeRegion(
            startTime: startTime,
            endTime: startTime.add(Duration(minutes: 30)),
            text: userIdsString,
          ));
          reservationTimeList.add(reservation.startTime!);
        }
      }
    });
  }

  // 로그인 안했을 때
  void getOthersReservation() async {
    this.isSignedUp = false;
    final timeRegionNotifier = ref.read(timeRegionsProvider.notifier);
    final usersNotifier = ref.read(usersProvider.notifier);
    final appointmentsNotifier = ref.read(appointmentsProvider.notifier);
    appointmentsNotifier.clear();
    timeRegionNotifier.clearAll();
    reservationTimeList.clear();
    // 다른 사람들의 예약을 만드는 부분
    List<ReservationModel> othersReservations =
        await database.othersReservations();

    await Future.forEach(othersReservations,
        (ReservationModel othersReservation) async {
      if (!(reservationTimeList.contains(othersReservation.startTime))) {
        await Future.forEach(othersReservation.userIds!, (String uid) async {
          if (!usersNotifier.containsKey(uid)) {
            final userInfo = await database.getUserPublic(othersUid: uid);
            usersNotifier.addAll({uid: userInfo});
          }
        });
      }
    });

    if (reservationTimeList.isEmpty) {
      timeRegionNotifier.clearReservationRegions();
    }
    for (ReservationModel othersReservation in othersReservations) {
      if (!(reservationTimeList.contains(othersReservation.startTime))) {
        DateTime startTime = othersReservation.startTime!;
        timeRegionNotifier.addReservationRegions(TimeRegion(
          startTime: startTime,
          endTime: startTime.add(Duration(minutes: 30)),
          text: othersReservation.userIds!.first,
        ));
        reservationTimeList.add(othersReservation.startTime!);
      }
    }
  }

  // 유저 액션이 있을 때 캘린더 전체 업데이트
  void listenWhenUserAction() async {
    final usersNotifier = ref.read(usersProvider.notifier);
    final myUid = database.uid;
    final myInfo = await database.getUserPublic();
    if (myInfo.nickname != null) {
      usersNotifier.addAll({myUid: myInfo});
      isSignedUp = true;
    } else {
      isSignedUp = false;
    }

    streamSubscription =
        database.myReservationsStream().listen((myReservations) async {
      final appointmentsNotifier = ref.read(appointmentsProvider.notifier);
      final timeRegionNotifier = ref.read(timeRegionsProvider.notifier);
      final usersNotifier = ref.read(usersProvider.notifier);

      await Future.forEach(myReservations,
          (ReservationModel myReservation) async {
        await Future.forEach(myReservation.userIds!, ((String uid) async {
          if (!usersNotifier.containsKey(uid)) {
            UserPublicModel? userInfo =
                await database.getUserPublic(othersUid: uid);
            usersNotifier.addAll({uid: userInfo});
          }
        }));
      });

      // 다른 사람들의 예약을 만드는 부분
      List<ReservationModel> notFullReservations =
          await database.othersReservations();

      // 내가 포함된 예약은 위에서 이미 처리했기에 필요없음 (복합쿼리로 가져올 수 없어서 로직으로 처리)
      List<ReservationModel> othersReservations = <ReservationModel>[];
      for (ReservationModel notFullReservation in notFullReservations) {
        if (!notFullReservation.userIds!.contains(database.uid)) {
          othersReservations.add(notFullReservation);
        }
      }

      await Future.forEach(othersReservations,
          (ReservationModel othersReservation) async {
        if (!(reservationTimeList.contains(othersReservation.startTime))) {
          await Future.forEach(othersReservation.userIds!, (String uid) async {
            if (!usersNotifier.containsKey(uid)) {
              final userInfo = await database.getUserPublic(othersUid: uid);
              usersNotifier.addAll({uid: userInfo});
            }
          });
        }
      });

      appointmentsNotifier.clear();
      timeRegionNotifier.clearCantReserveRegions();
      cantHoverTimeList.clear();
      reservationTimeList.clear();

      for (ReservationModel reservation in myReservations) {
        DateTime startTime = reservation.startTime!;
        Appointment appointment;

        // 매칭이 완료된 예약이라면
        if (reservation.isFull!) {
          List<String> othersUidList = [...reservation.userIds!];
          othersUidList.remove(database.uid);
          String partnerUid = othersUidList.first;
          appointment = Appointment(
            startTime: reservation.startTime!,
            endTime: reservation.endTime!,
            notes: partnerUid,
            subject: MATCHED, // LOADING,MATCHING,MATCHED
            id: reservation.id,
          );
        } else {
          // 매칭이 안된 예약이라면
          appointment = Appointment(
            startTime: reservation.startTime!,
            endTime: reservation.endTime!,
            subject: MATCHING,
            id: reservation.id,
          );
        }
        appointmentsNotifier.deleteAppointment(startTime);
        appointmentsNotifier.addAppointment(appointment);

        timeRegionNotifier.addCantReserveRegions(
          TimeRegion(
            startTime: startTime.subtract(Duration(minutes: 30)),
            endTime: startTime.add(Duration(minutes: 60)),
            enablePointerInteraction: false,
            text: CANT_RESERVE,
          ),
        );

        cantHoverTimeList.add(startTime);
        cantHoverTimeList.add(startTime.add(Duration(minutes: 30)));
        cantHoverTimeList.add(startTime.subtract(Duration(minutes: 30)));

        reservationTimeList.add(startTime);
        reservationTimeList.add(startTime.add(Duration(minutes: 30)));
        reservationTimeList.add(startTime.subtract(Duration(minutes: 30)));
      }

      timeRegionNotifier.clearReservationRegions();

      for (ReservationModel othersReservation in othersReservations) {
        if (!(reservationTimeList.contains(othersReservation.startTime))) {
          DateTime startTime = othersReservation.startTime!;
          timeRegionNotifier.addReservationRegions(TimeRegion(
            startTime: startTime,
            endTime: startTime.add(Duration(minutes: 30)),
            text: othersReservation.userIds!.first,
          ));
          reservationTimeList.add(othersReservation.startTime!);
        }
      }
    });
  }
}

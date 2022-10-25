class ReservationUserInfo {
  String? uid;
  String? nickname;
  DateTime? enterDTTM;
  DateTime? leaveDTTM;
  DateTime? reserveDTTM;
  String? reservationVersion;
  String? reservationAgent;
  String? sessionVersion;
  String? sessionAgent;

  ReservationUserInfo({
    this.uid,
    this.nickname,
    this.enterDTTM,
    this.leaveDTTM,
    this.reserveDTTM,
    this.reservationVersion,
    this.reservationAgent,
    this.sessionVersion,
    this.sessionAgent,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (uid != null) "uid": uid,
      if (nickname != null) "nickname": nickname,
      if (enterDTTM != null) "enterDTTM": enterDTTM,
      if (leaveDTTM != null) "leaveDTTM": leaveDTTM,
      if (reserveDTTM != null) "reserveDTTM": reserveDTTM,
      if (reservationVersion != null) "reservationVersion": reservationVersion,
      if (reservationAgent != null) "reservationAgent": reservationAgent,
      if (sessionVersion != null) "sessionVersion": sessionVersion,
      if (sessionAgent != null) "sessionAgent": sessionAgent,
    };
  }
}

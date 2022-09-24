class ReservationUserInfo {
  String? uid;
  String? nickname;
  DateTime? enterDTTM;
  DateTime? leaveDTTM;

  ReservationUserInfo({
    this.uid,
    this.nickname,
    this.enterDTTM,
    this.leaveDTTM,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (uid != null) "uid": uid,
      if (nickname != null) "nickname": nickname,
      if (enterDTTM != null) "enterDTTM": enterDTTM,
      if (leaveDTTM != null) "leaveDTTM": leaveDTTM,
    };
  }
}

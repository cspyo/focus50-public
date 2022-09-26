class FirestorePath {
  static String users() => 'users/';
  static String userPublic(String uid) => 'users/$uid';
  static String userPrivate(String uid) => 'users/$uid/private/$uid';
  static String reservations() => 'reservation/';
  static String reservation(String documentId) => 'reservation/$documentId';
  static String updateReservationUserInfo(String uid, String field) =>
      'userInfos.$uid.$field';
}

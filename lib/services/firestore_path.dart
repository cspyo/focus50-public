class FirestorePath {
  static String users() => 'users/';
  static String userPublic(String uid) => 'users/$uid';
  static String userPrivate(String uid) => 'users/$uid/private/$uid';
  static String reservations() => 'reservation/';
  static String reservation(String documentId) => 'reservation/$documentId';
  static String updateReservationUserInfo(String uid, String field) =>
      'userInfos.$uid.$field';
  static String todos() => 'todo/';
  static String todo(String documentId) => 'todo/$documentId';
  static String groups() => 'group/';
  static String group(String documentId) => 'group/$documentId';
  static String version() => 'CONFIGURATION/VERSION';
  static String notices() => 'notice/';
  static String feedbacks() => 'feedback/';
  static String feedback(String documentId) => 'feedback/$documentId';
  static String ratings() => 'rating/';
  static String histories() => 'history/';
  static String history(String uid) => 'history/$uid';
  static String updateSessionHistory(String nowDate) =>
      'sessionHistory.$nowDate';
}

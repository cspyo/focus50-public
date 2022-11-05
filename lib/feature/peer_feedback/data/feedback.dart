class EnumData {
  final String code;
  final String content;
  const EnumData({required this.code, required this.content});
}

enum FeedbackType {
  POSITIVE_FEEDBACK_1,
  POSITIVE_FEEDBACK_2,
  NEGATIVE_FEEDBACK_1,
  NEGATIVE_FEEDBACK_2,
  UNDEFINED,
}

extension FeedbackTypeExt on FeedbackType {
  static final _data = {
    FeedbackType.POSITIVE_FEEDBACK_1:
        EnumData(code: 'POSITIVE_FEEDBACK_1', content: '👍 50분동안 정말 수고하셨습니다'),
    FeedbackType.POSITIVE_FEEDBACK_2:
        EnumData(code: 'POSITIVE_FEEDBACK_2', content: '🔥 오늘 하루 공부 화이팅입니다'),
    FeedbackType.NEGATIVE_FEEDBACK_1:
        EnumData(code: 'NEGATIVE_FEEDBACK_1', content: '😭 오늘 안들어오셔서 아쉬웠어요'),
    FeedbackType.NEGATIVE_FEEDBACK_2:
        EnumData(code: 'NEGATIVE_FEEDBACK_2', content: '😱 카메라가 꺼져있어서 아쉬웠어요'),
    FeedbackType.UNDEFINED: EnumData(code: '', content: ''),
  };

  static FeedbackType getByCode(String code) {
    try {
      return _data.entries.firstWhere((el) => el.value.code == code).key;
    } catch (e) {
      return FeedbackType.UNDEFINED;
    }
  }

  String get code => _data[this]!.code;
  String get content => _data[this]!.content;
}

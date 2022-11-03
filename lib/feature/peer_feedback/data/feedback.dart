class EnumData {
  final String code;
  final String content;
  const EnumData({required this.code, required this.content});
}

enum FeedbackType {
  POSITIVE_FEEDBACK_1,
  POSITIVE_FEEDBACK_2,
  POSITIVE_FEEDBACK_3,
  NEGATIVE_FEEDBACK_1,
  NEGATIVE_FEEDBACK_2,
  UNDEFINED,
}

extension FeedbackTypeExt on FeedbackType {
  static final _data = {
    FeedbackType.POSITIVE_FEEDBACK_1:
        EnumData(code: 'POSITIVE_FEEDBACK_1', content: '긍정피드백1'),
    FeedbackType.POSITIVE_FEEDBACK_2:
        EnumData(code: 'POSITIVE_FEEDBACK_2', content: '긍정피드백2'),
    FeedbackType.POSITIVE_FEEDBACK_3:
        EnumData(code: 'POSITIVE_FEEDBACK_3', content: '긍정피드백3'),
    FeedbackType.NEGATIVE_FEEDBACK_1:
        EnumData(code: 'NEGATIVE_FEEDBACK_1', content: '부정피드백1'),
    FeedbackType.NEGATIVE_FEEDBACK_2:
        EnumData(code: 'NEGATIVE_FEEDBACK_2', content: '부정피드백2'),
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

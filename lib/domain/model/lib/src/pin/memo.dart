class Memo {
  static const maxLength = 32;

  final String value;

  Memo(String rawValue) : value = rawValue {
    if (rawValue.length > maxLength) {
      throw ArgumentError('メモは$maxLength文字以内で入力してください');
    }
    if (rawValue.contains('\n')) {
      throw ArgumentError('メモに改行を含めることはできません');
    }
  }
}

extension StringX on String {
  /// Converts to Sentence case.
  /// This means the first letter is capitalized and the rest are in lowercase.
  /// ```dart
  /// 'ALPHABET'.toSentenceCase(); // 'Alphabet'
  /// 'abc'.toSentenceCase(); // 'Abc'
  /// ```
  String toSentenceCase() {
    if (isEmpty) return '';
    if (length == 1) return toUpperCase();

    final sentences = split(RegExp(r'(?<=[.!?])\s+'));
    final buffer = StringBuffer();
    bool isFirst = true;

    for (var s in sentences) {
      final p = s.trim();
      if (p.isEmpty) continue;

      if (!isFirst) {
        buffer.write(' ');
      }
      buffer.write(p.substring(0, 1).toUpperCase());
      if (p.length > 1) {
        buffer.write(p.substring(1).toLowerCase());
      }
      isFirst = false;
    }
    return buffer.toString();
  }

  /// Converts to CamelCase.
  /// This means the first letter of each word is capitalized and no spaces are present.
  /// ```dart
  /// 'hello world'.toCamelCase(); // 'HelloWorld'
  /// 'this is a test'.toCamelCase(); // 'ThisIsATest'
  /// ```
  String toCamelCase() {
    if (isEmpty) return '';
    return replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (m) => ('_${m.group(0)!}')).toLowerCase();
  }

  bool get isValidText => trim().isEmpty ? false : true;

  bool get isValidNumber => double.tryParse(this) == null ? false : true;

  int? get parseInt => int.tryParse(this);
  double? get parseDouble => double.tryParse(this);
}

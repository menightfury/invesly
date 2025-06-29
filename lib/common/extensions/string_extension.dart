extension StringX on String {
  /// Converts to Sentence case.
  /// This means the first letter is capitalized and the rest are in lowercase.
  /// ```dart
  /// 'ALPHABET'.toSentenceCase(); // 'Alphabet'
  /// 'abc'.toSentenceCase(); // 'Abc'
  /// ```
  String toSentenceCase() {
    if (isEmpty) return '';
    if (length == 1) return this[0].toUpperCase();

    final sentences = split(RegExp(r'(?<=[.!?])\s+'));
    sentences.map((s) => s.trim().substring(0, 1).toUpperCase() + s.trim().substring(1).toLowerCase());
    return sentences.join(' ');
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
}

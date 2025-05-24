extension EMStringExtension on String {
  String toCapitalize() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String toCamelCase() {
    if (isEmpty) return '';
    return replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (m) => ('_${m.group(0)!}')).toLowerCase();
  }

  bool get isValidText => trim().isEmpty ? false : true;

  bool get isValidNumber => double.tryParse(this) == null ? false : true;
}

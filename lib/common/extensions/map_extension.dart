extension MapX on Map<String, dynamic> {
  Map<String, dynamic> toUpperKeys() => map((key, value) => MapEntry(key.toUpperCase(), value));

  void nest(String name, [String symbol = '_']) {
    final Map<String, dynamic> nested = {};

    forEach((key, value) {
      if (key.startsWith('$name$symbol')) {
        if (key != name) {
          final nestedName = key.substring(name.length + symbol.length);

          if (nestedName.isNotEmpty) {
            nested[nestedName] = value;
          }
        } else if (this[name] is Map) {
          (this[name] as Map).forEach((nestKey, nestValue) {
            nested[nestKey] = nestValue;
          });
        }
      }
    });

    if (nested.isNotEmpty) {
      removeWhere((key, _) => key.startsWith('$name$symbol'));
      this[name] = nested;
    }
  }
}

extension MapX2<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K key, V value) test) {
    return Map.fromEntries(entries.where((e) => test(e.key, e.value)));
  }
}

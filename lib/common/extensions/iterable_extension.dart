import 'package:collection/collection.dart';
// import 'package:flutter/widgets.dart';

extension EnumIterableX<T extends Enum> on Iterable<T> {
  T? byNameOrNull(String name) {
    return firstWhereOrNull((value) => value.name == name);
  }

  T byNameOrFirst(String name) {
    return firstWhere((value) => value.name == name, orElse: () => first);
  }
}

extension IterableX<T> on Iterable<T> {
  T? byIndexOrNull(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return elementAt(index);
  }
}
// extension ListSeparateExt<T extends Widget> on Iterable<T> {
//   List<Widget> separateBy(Widget t) {
//     return isEmpty ? [] : (expand((i) => [i, t]).toList()..removeLast());
//   }
// }

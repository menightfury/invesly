import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  /// Returns the current [ThemeData] of the context.
  ThemeData get theme => Theme.of(this);

  /// Returns the current [TextTheme] of the context.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Checks if the current context can pop a route.
  bool get canPop => Navigator.of(this).canPop();

  /// Pops the current route from the navigator stack.
  void pop<T extends Object>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// Pushes a new route onto the navigator stack.
  Future<T?> push<T extends Object>(Widget page) {
    return Navigator.of(this).push<T>(MaterialPageRoute<T>(builder: (context) => page));
  }

  /// Pushes a new route and removes all previous routes until the specified route.
  Future<T?> go<T extends Object>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(MaterialPageRoute<T>(builder: (context) => page), (_) => false);
  }
}

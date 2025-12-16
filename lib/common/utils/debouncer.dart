import 'dart:async';

class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  Future<void> wait() async {
    final completer = Completer<void>();
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(delay, () => completer.complete());
    return completer.future;
  }

  void dispose() {
    _timer?.cancel();
  }
}

// class Debouncer {
//   final int milliseconds;
//   Timer? _timer;

//   Debouncer({required this.milliseconds});

//   run(VoidCallback action) {
//     _timer?.cancel();
//     _timer = Timer(Duration(milliseconds: milliseconds), action);
//   }
// }

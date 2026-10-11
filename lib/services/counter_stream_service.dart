import 'dart:async';

class CounterStreamService {
  final StreamController<int> _controller = StreamController<int>();

  Stream<int> get counterStream => _controller.stream;

  int _count = 0;
  Timer? _timer;

  void start() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _count++;
        _controller.add(_count);
      },
    );
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

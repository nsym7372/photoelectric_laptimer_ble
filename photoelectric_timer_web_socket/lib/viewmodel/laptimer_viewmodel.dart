import 'dart:async';

import 'package:photoelectric_timer/model/websocket_service.dart';

class LapTimerViewModel {
  final WebSocketService webSocketService;

  final StreamController<String> _laptimeController =
      StreamController<String>.broadcast();
  Stream<String> get laptime => _laptimeController.stream;

  LapTimerViewModel(this.webSocketService) {
    webSocketService.messages.listen(_handleWebSocketMessage);
  }

  void _handleWebSocketMessage(String milliseconds) async {
    _laptimeController.add(_formatDuration(milliseconds));
  }

  String _formatDuration(String milliseconds) {
    var duration = _parseDuration(milliseconds);
    if (duration == null) {
      return "";
    }

    String minutesStr = duration["min"].toString().padLeft(2, '0');
    String secondsStr = duration["sec"].toString().padLeft(2, '0');
    String millisStr = duration["ms"].toString().padLeft(3, '0');

    return "$minutesStr:$secondsStr.$millisStr";
  }

  Map<String, int>? _parseDuration(String milliseconds) {
    final msValue = int.tryParse(milliseconds);
    if (msValue == null) {
      return null;
    }
    return {
      "min": (msValue ~/ 60000),
      "sec": (msValue % 60000) ~/ 1000,
      "ms": msValue % 1000
    };
  }

  void dispose() {
    webSocketService.close();
    _laptimeController.close();
  }
}

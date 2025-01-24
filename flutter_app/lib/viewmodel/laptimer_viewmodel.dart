import 'dart:async';

import 'package:ble_laptimer/model/ble_service.dart';
import 'package:ble_laptimer/model/speak_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LapTimerViewModel {
  final BleService bleService;
  final SpeakService speakService;

  final StreamController<String> _laptimeController =
      StreamController<String>.broadcast();
  Stream<String> get laptime => _laptimeController.stream;

  LapTimerViewModel(this.bleService, this.speakService) {
    _initializeBle();
    bleService.messages.listen(_handleBleMessage);
    WakelockPlus.enable();
  }

  void _initializeBle() async {
    await bleService.connectToDevice("BLE_LapTimer");
    bleService.messages.listen(_handleBleMessage);
  }

  void _handleBleMessage(String milliseconds) async {
    final duration = _parseDuration(milliseconds);
    if (duration == null) {
      _laptimeController.add("ready");
      return;
    }
    _laptimeController.add(_formatDuration(duration));
    speakService.speak(_formatDurationToSpeak(duration));
  }

  String _formatDuration(Map<String, int> duration) {
    String minutesStr = duration["min"].toString().padLeft(2, '0');
    String secondsStr = duration["sec"].toString().padLeft(2, '0');
    String millisStr = duration["ms"].toString().padLeft(3, '0');

    return "$minutesStr:$secondsStr.$millisStr";
  }

  String _formatDurationToSpeak(Map<String, int> duration) {
    String minutesStr =
        duration["min"] == 0 ? "" : '${duration["min"].toString()}分';
    String secondsStr = duration["sec"].toString();
    String millisStr =
        duration["ms"].toString().padLeft(3, '0').replaceAll("", " ");

    return '$minutesStr $secondsStr秒 $millisStr';
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
    WakelockPlus.disable();
    // webSocketService.close();
    _laptimeController.close();
  }
}

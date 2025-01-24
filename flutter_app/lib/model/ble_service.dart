import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer';

class BleService {
  late BluetoothDevice _device;
  BluetoothCharacteristic? _characteristic;
  BleService();

  Future<void> connectToDevice(String deviceId) async {
    await requestPermissions();

    try {
      await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      log("Scan started successfully.");
    } catch (e) {
      log("Error starting scan: $e");
    }

    try {
      log("--- connect ---");
      await for (final results in FlutterBluePlus.scanResults) {
        for (var result in results) {
          log("Found device: ${result.advertisementData.advName} (${result.device.id})");
          if (result.device.advName == deviceId) {
            await FlutterBluePlus.stopScan();
            _device = result.device;

            // Connect to the device
            await _device.connect();

            // Discover services and characteristics
            final services = await _device.discoverServices();
            final service = services.firstWhere((s) => s.uuid
                .toString()
                .startsWith("12345678-1234-5678-1234-56789abcdef0"));
            _characteristic = service.characteristics.firstWhere((c) => c.uuid
                .toString()
                .startsWith("abcdef01-1234-5678-1234-56789abcdef0"));
            await _characteristic?.setNotifyValue(true);

            log("Successfully connected to the device.");
            return;
          }
        }
      }
    } catch (e, stackTrace) {
      log("Error during connection attempt: $e");
      log(stackTrace.toString());
    }
  }

  Stream<String> get messages async* {
    await for (final value
        in _characteristic?.lastValueStream ?? Stream.empty()) {
      yield String.fromCharCodes(value);
    }
  }

  void disconnect() {
    _device.disconnect();
  }

  Future<void> requestPermissions() async {
    // 必要な権限をリクエスト
    final scanStatus = await Permission.bluetoothScan.request();
    if (scanStatus != PermissionStatus.granted) {
      throw Exception("BLUETOOTH_SCAN permission is required.");
    }

    final connectStatus = await Permission.bluetoothConnect.request();
    if (connectStatus != PermissionStatus.granted) {
      throw Exception("BLUETOOTH_CONNECT permission is required.");
    }

    final locationStatus = await Permission.location.request();
    if (locationStatus != PermissionStatus.granted) {
      throw Exception("Location permission is required.");
    }
  }
}

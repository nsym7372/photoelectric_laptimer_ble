// import 'package:flutter_blue/flutter_blue.dart';

// class BluetoothService {
//   final FlutterBlue _flutterBlue = FlutterBlue.instance;
//   BluetoothDevice? _connectedDevice;
//   BluetoothCharacteristic? _characteristic;

//   // メッセージを受信するためのストリーム
//   Stream<String> get messages async* {
//     if (_characteristic == null) {
//       throw Exception(
//           "No Bluetooth characteristic found. Connect to a device first.");
//     }

//     await for (final value in _characteristic!.value) {
//       yield String.fromCharCodes(value);
//     }
//   }

//   // デバイスのスキャンを開始
//   Future<void> startScan() async {
//     _flutterBlue.startScan(timeout: Duration(seconds: 5));
//   }

//   // デバイスのスキャンを停止
//   void stopScan() {
//     _flutterBlue.stopScan();
//   }

//   // デバイスに接続
//   Future<void> connectToDeviceByName(String deviceName) async {
//     final devices = await _flutterBlue.connectedDevices;
//     final device = devices.firstWhere(
//       (d) => d.name == deviceName,
//       orElse: () => throw Exception("Device with name $deviceName not found"),
//     );

//     await device.connect();
//     _connectedDevice = device;

//     final services = await device.discoverServices();
//     for (var service in services) {
//       for (var characteristic in service.characteristics) {
//         if (characteristic.properties.notify) {
//           _characteristic = characteristic;
//           await _characteristic!.setNotifyValue(true);
//           return;
//         }
//       }
//     }

//     throw Exception("No suitable characteristic found.");
//   }

//   // デバイスから切断
//   Future<void> disconnect() async {
//     if (_connectedDevice != null) {
//       await _connectedDevice!.disconnect();
//       _connectedDevice = null;
//       _characteristic = null;
//     }
//   }

//   // Bluetoothの初期化をチェック
//   Future<void> ensureBluetoothEnabled() async {
//     final isAvailable = await _flutterBlue.isAvailable;
//     final isOn = await _flutterBlue.isOn;

//     if (!isAvailable || !isOn) {
//       throw Exception("Bluetooth is not available or not turned on.");
//     }
//   }

//   // 終了処理
//   void close() {
//     disconnect();
//   }
// }

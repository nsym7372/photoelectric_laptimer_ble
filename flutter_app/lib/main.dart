import 'package:flutter/material.dart';
import 'package:ble_laptimer/model/speak_service.dart';
import 'package:ble_laptimer/model/websocket_service.dart';
import 'package:ble_laptimer/view/laptimer_view.dart';
import 'package:ble_laptimer/viewmodel/laptimer_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final speakService = await SpeakService.create();
  final webSocketService = WebSocketService("ws://192.168.179.9:81");
  final viewModel = LapTimerViewModel(webSocketService, speakService);

  runApp(MyApp(viewModel: viewModel));
}

class MyApp extends StatelessWidget {
  final LapTimerViewModel viewModel;
  const MyApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LapTimerView(viewModel: viewModel),
    );
  }
}

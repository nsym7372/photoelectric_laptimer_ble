import 'package:flutter/material.dart';
import 'package:photoelectric_timer/model/websocket_service.dart';
import 'package:photoelectric_timer/view/laptimer_view.dart';
import 'package:photoelectric_timer/viewmodel/laptimer_viewmodel.dart';

void main() async {
  final webSocketService = WebSocketService("ws://192.168.179.9:81");
  final viewModel = LapTimerViewModel(webSocketService);

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

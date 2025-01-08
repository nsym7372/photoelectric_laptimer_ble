import 'package:flutter/material.dart';
import 'package:photoelectric_timer/viewmodel/laptimer_viewmodel.dart';

class LapTimerView extends StatelessWidget {
  final LapTimerViewModel viewModel;

  LapTimerView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photoelectric Timer',
            style: TextStyle(fontSize: 16, color: Colors.black)),
        toolbarHeight: 40.0,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<String>(
                stream: viewModel.laptime,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "waiting for data...",
                    style: const TextStyle(fontSize: 144, color: Colors.white),
                  );
                })
          ],
        ),
      ),
    );
  }
}

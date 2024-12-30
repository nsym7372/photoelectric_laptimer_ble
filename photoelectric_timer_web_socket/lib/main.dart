import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoElectric Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PhotoElectric Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late WebSocketChannel channel;

  String serverMessage = "データを待っています...";
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();

    channel = IOWebSocketChannel.connect("ws://192.168.179.9:81");
    channel.stream.listen((message) {
      setState(() {
        serverMessage = message;
      });
      _speak(message);
    });

    WakelockPlus.enable();
    _flutterTts.setLanguage("ja-JP");
    _flutterTts.setSpeechRate(0.4);
  }

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
            Text(
              _formatDuration(serverMessage),
              style: const TextStyle(fontSize: 144, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    channel.sink.close();
    super.dispose();
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

  // タイムは読み上げるものらしい
  Future _speak(String ms) async {
    var japaneseTime = _formatDurationToSpeak(ms);
    await _flutterTts.speak(japaneseTime);
  }

  String _formatDurationToSpeak(String milliseconds) {
    var duration = _parseDuration(milliseconds);
    if (duration == null) {
      return "";
    }

    String minutesStr =
        duration["min"] == 0 ? "" : '${duration["min"].toString()}分';
    String secondsStr = duration["sec"].toString();
    String millisStr =
        duration["ms"].toString().padLeft(3, '0').replaceAll("", " ");

    return '$minutesStr $secondsStr秒 $millisStr';
  }
}

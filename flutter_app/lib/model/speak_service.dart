import 'package:flutter_tts/flutter_tts.dart';

class SpeakService {
  final FlutterTts _flutterTts;
  SpeakService._(this._flutterTts);

  static Future<SpeakService> create(
      {String language = "ja-JP", double rate = 0.5}) async {
    final flutterTts = FlutterTts();
    await flutterTts.setLanguage(language);
    await flutterTts.setSpeechRate(rate);
    return SpeakService._(flutterTts);
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }
}

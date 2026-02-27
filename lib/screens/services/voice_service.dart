import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> speak(String text, {String language = "en-US"}) async {
    await _tts.setLanguage(language);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}

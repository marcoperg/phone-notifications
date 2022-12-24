import 'package:flutter_tts/flutter_tts.dart';
import 'package:audio_service/audio_service.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final FlutterTts _player = FlutterTts();
  String text = '';

  AudioPlayerHandler() {
    _player.awaitSpeakCompletion(true);
  }

  void setText(String text) => this.text = text;

  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.

  @override
  Future<void> play() async => await _player.speak(text);
}

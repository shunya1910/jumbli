import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Ensures audio failures never crash the game
  static Future<void> _safePlay(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Audio playback failed safely for $assetPath: $e');
    }
  }

  static Future<void> playSuccess() async {
    await _safePlay('audio/success.mp3');
  }

  static Future<void> playFailure() async {
    await _safePlay('audio/wrong.mp3');
  }

  static Future<void> playTimeout() async {
    await _safePlay('audio/timeout.mp3');
  }

  static Future<void> playTick() async {
    await _safePlay('audio/tick.mp3');
  }
}

import 'package:just_audio/just_audio.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();

  factory AudioPlayerManager() {
    return _instance;
  }

  AudioPlayerManager._internal();

  AudioPlayer? _currentPlayer;
  String? _currentAudioUrl;

  Future<AudioPlayer> getPlayer(String audioUrl) async {
    _currentPlayer ??= AudioPlayer();

    if (_currentAudioUrl != audioUrl) {
      await _currentPlayer!.stop();
      _currentAudioUrl = audioUrl;
      await _currentPlayer!.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl),
          headers: {'User-Agent': 'YourApp/1.0'},
        ),
      );
    }
    return _currentPlayer!;
  }

  Future<void> stopCurrentAudio() async {
    if (_currentPlayer != null) {
      await _currentPlayer!.stop();
    }
  }

  Future<void> disposeCurrentPlayer() async {
    if (_currentPlayer != null) {
      await _currentPlayer!.dispose();
      _currentPlayer = null;
      _currentAudioUrl = null;
    }
  }
}

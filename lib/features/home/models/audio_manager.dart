import 'package:just_audio/just_audio.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;
  AudioPlayerManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAudio(String audioUrl) async {
    // Stop any current playback before starting new audio
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
    }
    await _audioPlayer.setUrl(audioUrl);
    _audioPlayer.play();
  }

  Future<void> pauseAudio() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    }
  }

  AudioPlayer get audioPlayer => _audioPlayer;
}

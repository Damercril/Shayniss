import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._();
  static SoundService get instance => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  SoundService._();

  Future<void> init() async {
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.setReleaseMode(ReleaseMode.release);
  }

  Future<void> playMessageSound() async {
    if (!_isMuted) {
      await _audioPlayer.play(AssetSource('sounds/message.mp3'));
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  bool get isMuted => _isMuted;

  void dispose() {
    _audioPlayer.dispose();
  }
}

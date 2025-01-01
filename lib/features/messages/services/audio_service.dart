import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  static AudioService get instance => _instance;

  late final AudioRecorder _audioRecorder;
  final _audioPlayer = AudioPlayer();
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _isRecording = false;
  bool _isPlaying = false;

  AudioService._() {
    _audioRecorder = AudioRecorder();
  }

  Future<void> startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (hasPermission) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/audio_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _isRecording = true;
      _recordingDuration = Duration.zero;
      _startTimer();
    }
  }

  Future<String?> stopRecording() async {
    _stopTimer();
    _isRecording = false;
    
    final path = await _audioRecorder.stop();
    return path;
  }

  Future<void> cancelRecording() async {
    _stopTimer();
    _isRecording = false;
    await _audioRecorder.stop();
  }

  Future<void> playAudio(String url) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    await _audioPlayer.play(UrlSource(url));
    _isPlaying = true;

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
    });
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration += const Duration(seconds: 1);
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
  }

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  Duration get recordingDuration => _recordingDuration;
}

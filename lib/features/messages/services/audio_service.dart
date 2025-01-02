import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;
  AudioService._internal();

  late final AudioRecorder _audioRecorder;
  final _audioPlayer = AudioPlayer();
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _audioRecorder = AudioRecorder();
      _isInitialized = true;
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _audioRecorder.dispose();
      await _audioPlayer.dispose();
      _recordingTimer?.cancel();
      _isInitialized = false;
    }
  }

  Future<String?> startRecording() async {
    if (!_isInitialized) await initialize();

    if (await _audioRecorder.hasPermission()) {
      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

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

      return filePath;
    }
    return null;
  }

  Future<String?> stopRecording() async {
    _stopTimer();
    _isRecording = false;
    
    if (_isInitialized) {
      return await _audioRecorder.stop();
    }
    return null;
  }

  Future<void> cancelRecording() async {
    _stopTimer();
    _isRecording = false;
    await _audioRecorder.stop();
  }

  Future<void> playAudio(String path) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    await _audioPlayer.play(DeviceFileSource(path));
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

  Future<bool> hasPermission() async {
    if (!_isInitialized) await initialize();
    return await _audioRecorder.hasPermission();
  }

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  Duration get recordingDuration => _recordingDuration;
}

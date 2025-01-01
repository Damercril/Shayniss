import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../services/audio_service.dart';

class AudioRecorderWidget extends StatefulWidget {
  final Function(String, Duration) onAudioRecorded;
  final VoidCallback onCancelled;

  const AudioRecorderWidget({
    super.key,
    required this.onAudioRecorded,
    required this.onCancelled,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioService _audioService = AudioService.instance;
  bool _isRecording = false;
  Duration _duration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
      });
      _startTimer();
    } catch (e) {
      print('Erreur lors du démarrage de l\'enregistrement: $e');
      widget.onCancelled();
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final audioPath = await _audioService.stopRecording();
    if (audioPath != null) {
      widget.onAudioRecorded(audioPath, _duration);
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    await _audioService.cancelRecording();
    widget.onCancelled();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.mic,
            color: AppColors.primary,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enregistrement en cours...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDuration(_duration),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.grey,
                onPressed: _cancelRecording,
              ),
              IconButton(
                icon: const Icon(Icons.send),
                color: AppColors.primary,
                onPressed: _stopRecording,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

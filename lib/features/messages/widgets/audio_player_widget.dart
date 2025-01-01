import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../services/audio_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final Duration duration;
  final bool isMe;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.duration,
    required this.isMe,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioService _audioService = AudioService.instance;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.stopAudio();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioService.pauseAudio();
      _timer?.cancel();
    } else {
      await _audioService.playAudio(widget.audioUrl);
      _startTimer();
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_position < widget.duration) {
          _position += const Duration(seconds: 1);
        } else {
          _isPlaying = false;
          _position = Duration.zero;
          timer.cancel();
        }
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
    final color = widget.isMe ? Colors.white : AppColors.text;
    final progressColor = widget.isMe ? Colors.white70 : AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: color,
          ),
          onPressed: _togglePlay,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150.w,
              child: LinearProgressIndicator(
                value: _position.inSeconds / widget.duration.inSeconds,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _formatDuration(_position),
              style: TextStyle(
                fontSize: 12.sp,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

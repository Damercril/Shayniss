import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_colors.dart';

class AudioMessageBubble extends StatefulWidget {
  final String audioPath;
  final bool isMe;
  final String time;

  const AudioMessageBubble({
    Key? key,
    required this.audioPath,
    required this.isMe,
    required this.time,
  }) : super(key: key);

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _setupAudioPlayer() async {
    try {
      await _audioPlayer.setSourceDeviceFile(widget.audioPath);
      final duration = await _audioPlayer.getDuration();
      setState(() {
        _duration = duration ?? Duration.zero;
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      });

      _audioPlayer.onPositionChanged.listen((position) {
        setState(() {
          _position = position;
        });
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      });
    } catch (e) {
      print('Error setting up audio player: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: widget.isMe ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: widget.isMe ? Colors.white : AppColors.primary,
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.resume();
                    }
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150.w,
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: widget.isMe 
                          ? Colors.white.withOpacity(0.3) 
                          : Colors.grey[300],
                        borderRadius: BorderRadius.circular(1.5.r),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final progress = _duration.inMilliseconds > 0
                              ? _position.inMilliseconds / _duration.inMilliseconds
                              : 0.0;
                          return Container(
                            width: constraints.maxWidth * progress,
                            decoration: BoxDecoration(
                              color: widget.isMe 
                                ? Colors.white 
                                : AppColors.primary,
                              borderRadius: BorderRadius.circular(1.5.r),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: widget.isMe 
                          ? Colors.white.withOpacity(0.7) 
                          : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              widget.time,
              style: TextStyle(
                fontSize: 10.sp,
                color: widget.isMe 
                  ? Colors.white.withOpacity(0.7) 
                  : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

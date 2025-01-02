import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/voice_message_widget.dart';
import '../widgets/audio_message_bubble.dart';

class Message {
  final String? text;
  final String? audioPath;
  final bool isMe;
  final String time;

  Message({
    this.text,
    this.audioPath,
    required this.isMe,
    required this.time,
  });
}

class ClientChatScreen extends StatefulWidget {
  final String name;
  final String imageUrl;

  const ClientChatScreen({
    Key? key,
    required this.name,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends State<ClientChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [
    Message(
      text: 'Bonjour, je souhaiterais prendre rendez-vous pour un massage.',
      isMe: true,
      time: '10:30',
    ),
    Message(
      text: 'Bonjour ! Bien sûr, nous avons des disponibilités pour demain à 14h ou après-demain à 11h. Quelle horaire vous conviendrait le mieux ?',
      isMe: false,
      time: '10:32',
    ),
    Message(
      text: 'Demain 14h serait parfait !',
      isMe: true,
      time: '10:33',
    ),
    Message(
      text: 'Très bien, je vous confirme le rendez-vous pour demain à 14h. N\'hésitez pas si vous avez des questions.',
      isMe: false,
      time: '10:34',
    ),
  ];

  void _sendMessage(String text) {
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(
        text: text,
        isMe: true,
        time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      ));
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _sendVoiceMessage(String audioPath) {
    setState(() {
      _messages.add(Message(
        audioPath: audioPath,
        isMe: true,
        time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessage(Message message) {
    if (message.audioPath != null) {
      return AudioMessageBubble(
        audioPath: message.audioPath!,
        isMe: message.isMe,
        time: message.time,
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) SizedBox(width: 8.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: message.isMe ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text!,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black87,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    message.time,
                    style: TextStyle(
                      color: message.isMe 
                        ? Colors.white.withOpacity(0.7) 
                        : Colors.grey[600],
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe) SizedBox(width: 8.w),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.attach_file,
                color: AppColors.primary,
              ),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            VoiceMessageWidget(
              onVoiceMessageSent: _sendVoiceMessage,
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: AppColors.primary,
              ),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: NetworkImage(widget.imageUrl),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'En ligne',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.videocam_outlined,
              color: AppColors.primary,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.call_outlined,
              color: AppColors.primary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
}

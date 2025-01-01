import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../models/chat_preview_model.dart' show ChatPreview;
import '../models/message_model.dart';
import '../services/message_service.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final ChatPreview chat;

  const ChatScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _markChatAsRead();
    // Charger les messages de test
    _messages.addAll([
      Message(
        id: '1',
        chatId: widget.chat.id,
        senderId: 'user1',
        content: 'Bonjour, comment allez-vous ?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Message(
        id: '2',
        chatId: widget.chat.id,
        senderId: widget.chat.id,
        content: 'Très bien, merci ! Et vous ?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
    ]);
  }

  void _markChatAsRead() {
    MessageService.instance.markChatAsRead(widget.chat.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final size = await image.length();
      final path = image.path;
      
      setState(() {
        _messages.add(
          Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            chatId: widget.chat.id,
            senderId: 'user1',
            content: 'Image',
            timestamp: DateTime.now(),
            type: MessageType.image,
            attachment: MessageAttachment(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: 'image',
              url: path,
              mimeType: 'image/${image.name.split('.').last}',
              name: image.name,
              size: size,
            ),
          ),
        );
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      final file = result.files.first;
      final path = file.path;
      
      if (path != null) {
        setState(() {
          _messages.add(
            Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              chatId: widget.chat.id,
              senderId: 'user1',
              content: file.name,
              timestamp: DateTime.now(),
              type: MessageType.file,
              attachment: MessageAttachment(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: 'file',
                url: path,
                name: file.name,
                size: file.size,
                mimeType: file.extension ?? 'application/octet-stream',
              ),
            ),
          );
        });
      }
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      senderId: 'user1',
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.avatar),
              radius: 16.r,
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.chat.isOnline)
                  Text(
                    'En ligne',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          TypingIndicator(isTyping: _isTyping),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.image),
                            title: const Text('Image'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.attach_file),
                            title: const Text('Fichier'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickFile();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == 'user1';
    final bubbleColor = isMe ? AppColors.primary : Colors.grey[200];
    final textColor = isMe ? Colors.white : AppColors.text;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.avatar),
              radius: 16.r,
            ),
            SizedBox(width: 8.w),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.image && message.attachment != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      File(message.attachment!.url),
                      width: 200.w,
                      height: 200.w,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (message.type == MessageType.file && message.attachment != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: textColor,
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.attachment!.name ?? 'Fichier',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            '${(message.attachment!.size! / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Text(
                    message.content,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                    ),
                  ),
                SizedBox(height: 4.h),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=500',
              ),
              radius: 16.r,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'maintenant';
    }
  }
}

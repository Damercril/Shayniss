import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../models/chat_preview_model.dart';
import '../services/message_service.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final chats = MessageService.instance.getChats();

    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Messages',
        showBackButton: true,
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(chat.avatar),
                  radius: 24.r,
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              chat.name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              chat.lastMessage,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: SizedBox(
              width: 65.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(chat.lastMessageTime),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  if (chat.unreadCount > 0)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 20.w,
                        maxHeight: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          chat.unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chat: chat),
                ),
              );
              // Force la mise à jour de l'interface après le retour
              if (context.mounted) {
                setState(() {});
              }
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      switch (time.weekday) {
        case 1:
          return 'Lun';
        case 2:
          return 'Mar';
        case 3:
          return 'Mer';
        case 4:
          return 'Jeu';
        case 5:
          return 'Ven';
        case 6:
          return 'Sam';
        case 7:
          return 'Dim';
        default:
          return '';
      }
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

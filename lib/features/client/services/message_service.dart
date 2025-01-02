import 'package:flutter/foundation.dart';

class MessageService extends ChangeNotifier {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'Sarah Martin',
      'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200',
      'lastMessage': 'Votre rendez-vous est confirmé pour demain à 14h',
      'time': '14:30',
      'unread': 2,
      'online': true,
    },
    {
      'id': '2',
      'name': 'Marie Dubois',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
      'lastMessage': 'Merci pour votre visite ! N\'hésitez pas à laisser un avis',
      'time': 'Hier',
      'unread': 0,
      'online': false,
    },
    {
      'id': '3',
      'name': 'Julie Bernard',
      'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200',
      'lastMessage': 'Nous avons de nouvelles disponibilités pour la semaine prochaine',
      'time': 'Hier',
      'unread': 1,
      'online': true,
    },
  ];

  List<Map<String, dynamic>> get conversations => List.from(_conversations);
  
  int get totalUnreadMessages => _conversations.fold(0, (sum, conv) => sum + (conv['unread'] as int));

  void markConversationAsRead(String conversationId) {
    final index = _conversations.indexWhere((conv) => conv['id'] == conversationId);
    if (index != -1) {
      _conversations[index]['unread'] = 0;
      notifyListeners();
    }
  }

  void addMessage(String conversationId, String message) {
    final index = _conversations.indexWhere((conv) => conv['id'] == conversationId);
    if (index != -1) {
      _conversations[index]['lastMessage'] = message;
      _conversations[index]['time'] = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      notifyListeners();
    }
  }
}

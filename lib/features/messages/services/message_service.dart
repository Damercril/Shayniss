import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../models/chat_preview_model.dart' as chat_model;

class MessageService extends ChangeNotifier {
  static final MessageService _instance = MessageService._();
  static MessageService get instance => _instance;

  late final SharedPreferences _prefs;
  final String _messagesKey = 'messages';
  final String _unreadCountKey = 'unread_messages_count';
  List<Message> _messages = [];
  int _unreadCount = 0;
  Map<String, int> _unreadCountPerChat = {};

  MessageService._();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadMessages();
    await _loadUnreadCount();
    
    // Initialiser avec les données de test
    _unreadCountPerChat = {
      for (var chat in chat_model.ChatPreview.samples)
        chat.id: chat.unreadCount
    };
    _unreadCount = _unreadCountPerChat.values.fold(0, (sum, count) => sum + count);
    notifyListeners();
  }

  Future<void> _loadMessages() async {
    final messagesJson = _prefs.getStringList(_messagesKey) ?? [];
    _messages = messagesJson
        .map((json) => Message.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _loadUnreadCount() async {
    _unreadCount = _prefs.getInt(_unreadCountKey) ?? 0;
    final countsJson = _prefs.getString('unread_counts_per_chat');
    if (countsJson != null) {
      _unreadCountPerChat = jsonDecode(countsJson).cast<String, int>();
    }
  }

  Future<void> _saveMessages() async {
    final messagesJson = _messages
        .map((message) => jsonEncode(message.toJson()))
        .toList();
    await _prefs.setStringList(_messagesKey, messagesJson);
  }

  Future<void> _saveUnreadCount() async {
    await _prefs.setInt(_unreadCountKey, _unreadCount);
    // Sauvegarder les compteurs par chat
    final countsJson = jsonEncode(_unreadCountPerChat);
    await _prefs.setString('unread_counts_per_chat', countsJson);
  }

  int getUnreadCount() => _unreadCount;

  int getUnreadCountForChat(String chatId) => _unreadCountPerChat[chatId] ?? 0;

  Future<void> markChatAsRead(String chatId) async {
    if (_unreadCountPerChat.containsKey(chatId)) {
      final previousCount = _unreadCountPerChat[chatId] ?? 0;
      _unreadCount -= previousCount;
      _unreadCountPerChat[chatId] = 0;
      await _saveUnreadCount();
      notifyListeners();
    }
  }

  Future<void> addMessage(Message message) async {
    _messages.add(message);
    if (!message.isRead) {
      _unreadCount++;
      _unreadCountPerChat[message.chatId] = 
          (_unreadCountPerChat[message.chatId] ?? 0) + 1;
    }
    await _saveMessages();
    await _saveUnreadCount();
    notifyListeners();
  }

  List<chat_model.ChatPreview> getChats() {
    final chats = chat_model.ChatPreview.samples;
    return List<chat_model.ChatPreview>.from(chats.map((chat) {
      return chat.copyWith(
        unreadCount: _unreadCountPerChat[chat.id] ?? 0,
      );
    }));
  }
}

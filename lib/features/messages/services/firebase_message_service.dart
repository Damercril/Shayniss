import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/message_model.dart';
import '../models/chat_preview_model.dart';

class FirebaseMessageService {
  static final FirebaseMessageService _instance = FirebaseMessageService._();
  static FirebaseMessageService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseMessageService._();

  // Collection references
  CollectionReference get _chatsCollection => _firestore.collection('chats');
  CollectionReference get _messagesCollection => _firestore.collection('messages');

  // Get chat messages stream
  Stream<List<Message>> getChatMessages(String chatId) {
    return _messagesCollection
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get chat previews stream
  Stream<List<ChatPreview>> getChatPreviews(String userId) {
    return _chatsCollection
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ChatPreview(
                id: doc.id,
                name: data['name'],
                avatar: data['avatar'],
                lastMessage: data['lastMessage'],
                lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
                unreadCount: data['unreadCount'] ?? 0,
                isOnline: data['isOnline'] ?? false,
              );
            }).toList());
  }

  // Send a message
  Future<void> sendMessage(Message message) async {
    await _messagesCollection.add(message.toJson());
    
    // Update chat preview
    await _chatsCollection.doc(message.chatId).update({
      'lastMessage': message.content,
      'lastMessageTime': message.timestamp,
    });
  }

  // Upload file to Firebase Storage
  Future<String> uploadFile(String chatId, File file, String type) async {
    final ref = _storage.ref().child('chats/$chatId/${DateTime.now().millisecondsSinceEpoch}_$type');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId, String userId) async {
    final batch = _firestore.batch();

    // Update all unread messages in the chat
    final unreadMessages = await _messagesCollection
        .where('chatId', isEqualTo: chatId)
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();

    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // Update chat preview unread count
    batch.update(_chatsCollection.doc(chatId), {'unreadCount': 0});

    await batch.commit();
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    await _messagesCollection.doc(messageId).delete();
  }

  // Get unread count for all chats
  Future<int> getTotalUnreadCount(String userId) async {
    final chats = await _chatsCollection
        .where('participants', arrayContains: userId)
        .get();

    int total = 0;
    for (var doc in chats.docs) {
      total += (doc.data() as Map<String, dynamic>)['unreadCount'] ?? 0;
    }
    return total;
  }
}

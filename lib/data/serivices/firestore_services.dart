// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_room_models.dart';
import '../models/user_model.dart';

import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  Stream<UserModel?> getUser(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc.data()!, doc.id);
    });
  }

  Future<void> updateUserOnline(String userId, bool isOnline) async {
    await _firestore.collection('users').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Chat Rooms
  Future<String> createChatRoom(List<String> participants) async {
    final roomRef = _firestore.collection('chatRooms').doc();
    await roomRef.set({
      'participants': participants,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': <String, int>{},
    });
    return roomRef.id;
  }

  Stream<List<ChatRoomModel>> getUserChatRooms(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatRoomModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Messages
  Stream<List<MessageModel>> getChatMessages(String roomId) {
    return _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  Future<void> sendMessage(String roomId, MessageModel message) async {
    await _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc()
        .set({
      'senderId': message.senderId,
      'content': message.content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': message.type,
    });

    // Update room lastMessage
    await _firestore.collection('chatRooms').doc(roomId).update({
      'lastMessage': message.content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class ChatRepositories {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get currentUserId   => _auth.currentUser?.uid ?? '';
  String get currentUserName =>
      _auth.currentUser?.displayName ??
          _auth.currentUser?.email ??
          'Unknown';

  // ── Send message ──────────────────────────────────────────────────────
  Future<void> sendMessage({
    required String roomId,
    required String content,
    String type = 'text',
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final message = MessageModel(
      id:         '',
      senderId:   user.uid,                                    // ← uid
  // ← senderName not senderId
      content:    content,
      timestamp:  DateTime.now(),
      isRead:     false,
      type:       type, senderName: '',
    );

    final batch  = _db.batch();
    final msgRef = _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc();

    batch.set(msgRef, message.toMap());

    batch.set(
      _db.collection('chatRooms').doc(roomId),
      {
        'lastMessage':     content,
        'lastMessageTime': Timestamp.now(),
        'lastSenderId':    user.uid,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  // ── Stream of messages ────────────────────────────────────────────────
  Stream<List<MessageModel>> messagesStream(String roomId) {
    return _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => MessageModel.fromFirestore(
      doc.data(),
      doc.id,
    ))
        .toList());
  }

  // ── Mark messages as read ─────────────────────────────────────────────
  Future<void> markAsRead(String roomId) async {
    final unread = await _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: currentUserId)
        .get();

    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── Typing indicator ──────────────────────────────────────────────────
  Future<void> setTyping(String roomId, bool isTyping) async {
    await _db.collection('chatRooms').doc(roomId).set({
      'typing': {currentUserId: isTyping},
    }, SetOptions(merge: true));
  }

  // ── Stream typing of other user ───────────────────────────────────────
  Stream<bool> typingStream(String roomId, String otherUserId) {
    return _db
        .collection('chatRooms')
        .doc(roomId)
        .snapshots()
        .map((snap) {
      final data   = snap.data();
      if (data == null) return false;
      final typing = data['typing'] as Map<String, dynamic>?;
      return typing?[otherUserId] == true;
    });                                                    // ← ) was missing
  }
}
// models/message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  late final String senderName;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'text' | 'image'

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.type,
    required this.senderName,
  });
  factory MessageModel.fromFirestore(Map<String, dynamic> data, String id) {
      return MessageModel(

      id: id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'text',
        senderName:data['senderName']??'unknown',
    );
  }
  Map<String, dynamic> toMap() => {
    'senderId':   senderId,
    'senderName': senderName,
    'content':    content,
    'timestamp':  Timestamp.fromDate(timestamp),
    'isRead':     isRead,
    'type':       type,
  };
  @override
  String toString() =>
      'MessageModel(id: $id, senderId: $senderId, content: $content)';
}
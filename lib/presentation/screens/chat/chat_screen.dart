// // In your chat screen
// import '../../../data/serivices/firestore_services.dart';
//
// final firestoreService = FirestoreService();
//
// // Get chat rooms
// late stream: firestoreService.getUserChatRooms(currentUserId)
//
// // Send message
// firestoreService.sendMessage(roomId, MessageModel(
// senderId: currentUserId,
// content: 'Hello',
// timestamp: DateTime.now(),
// isRead: false,
// type: 'text',
// ));
//
// // Listen messages
// firestoreService.getChatMessages(roomId)
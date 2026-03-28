// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../data/repositories/chat_repositories.dart';
// import '../../../logic/blocs/chat/chat_bloc.dart';
//
// class ChatScreen extends StatelessWidget {
//   final String roomId;
//
//   const ChatScreen({super.key, required this.roomId});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => ChatBloc(ChatRepositories())
//         ..add(LoadMessages(roomId)),
//       child: Scaffold(
//         appBar: _buildAppBar(context),
//         body: Column(children: [
//           Expanded(
//             child: StreamBuilder<List<MessageModel>>(
//               stream: ChatRepository().messagesStream(roomId),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) return const CircularProgressIndicator();
//                 final messages = snapshot.data!;
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (_, i) => MessageBubble(
//                     message: messages[messages.length - 1 - i],
//                     isMe: messages[i].senderId == currentUserId,
//                   ),
//                 );
//               },
//             ),
//           ),
//           const TypingIndicator(),
//           const ChatInputBar(),
//         ]),
//       ),
//     );
//   }
// }
//
// class ChatRepository {
// }
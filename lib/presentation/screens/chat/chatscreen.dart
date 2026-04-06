import 'package:chatapp/core/constants/app_colors.dart';
import 'package:chatapp/logic/blocs/auth/auth_bloc.dart';
import 'package:chatapp/presentation/screens/chat/chattile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hi!',           'isMe': true,  'time': '11:59 am', 'date': 'Tuesday, 15'},
    {'text': 'Hi!',           'isMe': false, 'time': '12:56 pm', 'date': ''},
    {'text': 'We can meet? I am free', 'isMe': true, 'time': '11:30 pm', 'date': ''},
    {'text': 'Can you write the time and place of the meeting?', 'isMe': true, 'time': '11:30 pm', 'date': ''},
    {'text': "That's fine",   'isMe': false, 'time': '2:40 pm',  'date': ''},
    {'text': 'Then at 5 near the tower', 'isMe': false, 'time': '2:41 pm', 'date': ''},
    {'text': 'Deal!',         'isMe': true,  'time': '11:43 pm', 'date': ''},
    {'text': 'Kisses! 😘',    'isMe': false, 'time': '2:44 pm',  'date': ''},
    {'text': '😎',            'isMe': true,  'time': '2:52 pm',  'date': ''},
    {'text': 'Hey! I looked at your project yesterday that you sent me.',
      'isMe': true, 'time': '10:00 am', 'date': 'Friday, 18'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: _buildAppBar(AuthState()),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          // ChatInputBar(onSend: _onSendMessage),
        ],
      ),
    );
  }

  AppBar _buildAppBar(state) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color:AppColors.primaryBlue, size: 20),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: Column(
        children: [
      Center(
      child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(50),
        child: Image.network("${state.value?.user
            ?.photoURL}")),
    ), Center(
    child: Text("Email: ${state.value?.user?.email}"),
    ), Center(
    child: Text(
    "Name: ${state.value?.user?.displayName}"),
    ), Center(
    child: Text(
    "PhoneNumber: ${state.value?.user
        ?.phoneNumber}"),
    ),
          const SizedBox(height:1),
          const Text(
            'Chat App',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const Text(
            'online',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.greenYellow,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.blue),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return Column(
          children: [
            if ((msg['date'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              // DateChip(label: msg['date']),
              const SizedBox(height: 8),
            ],
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return ChatTile(
                  chat: {
                    'initials': 'I',
                    'name': 'shambhav',
                    'message': msg['text'] ?? '',
                    'isSender': msg['isMe'] ?? false,
                    'time': msg['time'] ?? '',
                    'unread': 0,
                    'isAudio': false,
                    'isPhoto': false,
                    'isOnline': true,
                  },
                  onTap: () {},
                );
              },
            ),ElevatedButton(onPressed: () {
              context.goNamed('login');

            }, child: Text("log out"))
          ],
        );
      },
    );
  }
}

class MessageBubble {
}
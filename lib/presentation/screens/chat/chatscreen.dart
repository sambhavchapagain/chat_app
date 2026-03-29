import 'package:chatapp/presentation/screens/chat/chattile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';

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
    {'text': 'Hi!',           'isMe': false, 'time': '12:56 pm', 'date': null},
    {'text': 'We can meet? I am free', 'isMe': true, 'time': '11:30 pm', 'date': null},
    {'text': 'Can you write the time and place of the meeting?', 'isMe': true, 'time': '11:30 pm', 'date': null},
    {'text': "That's fine",   'isMe': false, 'time': '2:40 pm',  'date': null},
    {'text': 'Then at 5 near the tower', 'isMe': false, 'time': '2:41 pm', 'date': null},
    {'text': 'Deal!',         'isMe': true,  'time': '11:43 pm', 'date': null},
    {'text': 'Kisses! 😘',    'isMe': false, 'time': '2:44 pm',  'date': null},
    {'text': '😎',            'isMe': true,  'time': '2:52 pm',  'date': null},
    {'text': 'Hey! I looked at your project yesterday that you sent me.',
      'isMe': true, 'time': '10:00 am', 'date': 'Friday, 18'},
  ];

  void _onSendMessage(String text) {
    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
        'date': null,
      });
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          // ChatInputBar(onSend: _onSendMessage),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: Color(0xFF007AFF), size: 20),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: Column(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE5E5EA),
            child: Text(
              'I',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Imogen',
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
              color: Color(0xFF34C759),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF007AFF)),
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
            if (msg['date'] != null) ...[
              const SizedBox(height: 8),
              // DateChip(label: msg['date']),
              const SizedBox(height: 8),
            ],
            BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
return ChatTile(chat: {"chat":"gv"}, onTap: (){});
  },
),
          ],
        );
      },
    );
  }
}

class MessageBubble {
}
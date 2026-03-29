import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../widgets/custom_loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Gyllinton',
      'message': "I don't know what you're ...",
      'time': '3:44 pm',
      'unread': 3,
      'isOnline': true,
      'initials': 'G',
      'isSender': false,
    },
    {
      'name': 'Mark',
      'message': 'Why?',
      'time': '9:00 am',
      'unread': 0,
      'isOnline': true,
      'initials': 'M',
      'isSender': true,
    },
    {
      'name': 'Imogen',
      'message': 'Kisses! 😘',
      'time': 'Friday',
      'unread': 0,
      'isOnline': false,
      'initials': 'I',
      'isSender': false,
    },
    {
      'name': 'Alice',
      'message': "Okay, I'll tell him",
      'time': '8:34 am',
      'unread': 0,
      'isOnline': true,
      'initials': 'A',
      'isSender': true,
    },
    {
      'name': 'Cloud',
      'message': 'Audio',
      'time': '8:31 am',
      'unread': 0,
      'isOnline': false,
      'initials': 'C',
      'isAudio': true,
      'isSender': false,
    },
    {
      'name': 'Emily',
      'message': 'Photo',
      'time': '6:00 am',
      'unread': 0,
      'isOnline': false,
      'initials': 'E',
      'isPhoto': true,
      'isSender': true,
    },
    {
      'name': 'Pavel',
      'message': 'What is a "bug"?',
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': false,
      'initials': 'P',
      'isSender': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.logoutStatus == LogoutStatus.loading) {
          customLoadingWidget(context: context, title: "logout");
        }
        if (state.logoutStatus == LogoutStatus.logoutSucess) {
          context.pushReplacementNamed('login');
        }},
        child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
              backgroundColor: const Color(0xFFF2F2F7),
              body: SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      _buildSearchBar(),
                      const SizedBox(height: 8),
                      // _buildChatList(),
                      Column(
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

                          ElevatedButton(onPressed: () {
                            context.read<AuthBloc>().add(SignOutRequested());
                          }, child: Text("log out"))
                        ],
                      ),
                    ],
                  )));
        }));

  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'New',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.search, color: Color(0xFF8E8E93), size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle:
                  TextStyle(color: Color(0xFF8E8E93), fontSize: 17),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const Icon(Icons.mic, color: Color(0xFF8E8E93), size: 20),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
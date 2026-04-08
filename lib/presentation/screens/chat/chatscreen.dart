import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen>
    with WidgetsBindingObserver {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ Detect app going to background/foreground → update online status
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (currentUser == null) return;
    if (state == AppLifecycleState.resumed) {
      _setOnlineStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _setOnlineStatus(false);
    }
  }

  Future<void> _initUser() async {
    if (currentUser == null) return;
    await _ensureUserInFirestore(currentUser!);
    await _setOnlineStatus(true);
  }

  Future<void> _setOnlineStatus(bool isOnline) async {
    if (currentUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  Future<void> _ensureUserInFirestore(User user) async {
    final userDoc =
    FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      await userDoc.set({
        'displayName':
        user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'email': user.email ?? '',
        'isOnline': true,
        'uid': user.uid,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  void _logout() async {
    try {
      await _setOnlineStatus(false);
      await FirebaseAuth.instance.signOut();
      if (mounted) context.goNamed('login');
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  void _sendMessage() async {
    final text = _textEditingController.text.trim();
    if (text.isEmpty) return;
    if (currentUser == null) return;

    try {
      _textEditingController.clear();
      await FirebaseFirestore.instance.collection('messages').add({
        'text': text,
        'senderId': currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ✅ Online users strip at the top
          _buildOnlineUsersStrip(),
          // ✅ Status notification banner (who came online/went offline)
          _buildStatusBanner(),
          // Messages list
          Expanded(child: _buildMessagesList()),
          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF075E54),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.chat_bubble, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chat App',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Logout',
          onPressed: _logout,
        ),
      ],
    );
  }

  // ✅ Horizontal strip showing all online users with green dot
  Widget _buildOnlineUsersStrip() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final onlineUsers = snapshot.data!.docs
            .where((doc) => doc.id != currentUser?.uid)
            .toList();

        if (onlineUsers.isEmpty) return const SizedBox.shrink();

        return Container(
          color: const Color(0xFF075E54).withOpacity(0.05),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: onlineUsers.length,
            itemBuilder: (context, index) {
              final userData =
              onlineUsers[index].data() as Map<String, dynamic>;
              final name = userData['displayName'] ?? 'User';

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: _getAvatarColor(name),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name.split(' ')[0],
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ✅ Shows a live banner: "X is now online" / "X went offline"
  String _lastStatusEvent = '';

  Widget _buildStatusBanner() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        // Check for document changes
        for (final change in snapshot.data!.docChanges) {
          if (change.doc.id == currentUser?.uid) continue;
          final data = change.doc.data() as Map<String, dynamic>;
          final name = data['displayName'] ?? 'Someone';
          final isOnline = data['isOnline'] ?? false;

          if (change.type == DocumentChangeType.modified) {
            final newEvent = isOnline
                ? '$name is now online 🟢'
                : '$name went offline ⚫';

            if (newEvent != _lastStatusEvent) {
              _lastStatusEvent = newEvent;
              // Show snackbar for status change
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newEvent,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: isOnline
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(10),
                    ),
                  );
                }
              });
            }
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('No messages yet',
                    style: TextStyle(color: Colors.grey.shade500)),
                Text('Say hello! 👋',
                    style: TextStyle(color: Colors.grey.shade400)),
              ],
            ),
          );
        }

        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final data = message.data() as Map<String, dynamic>;
            final String? senderId = data['senderId'];

            if (senderId == null || senderId.isEmpty) {
              return const SizedBox.shrink();
            }

            final isMe = senderId == currentUser?.uid;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(senderId)
                  .get(),
              builder: (context, userSnapshot) {
                String name = 'User';
                bool isOnline = false;

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
                  name = userData['displayName'] ?? 'User';
                  isOnline = userData['isOnline'] ?? false;
                }

                return _buildMessageBubble(
                  text: data['text'] ?? '',
                  name: name,
                  isMe: isMe,
                  isOnline: isOnline,
                  timestamp: data['timestamp'] as Timestamp?,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required String name,
    required bool isMe,
    required bool isOnline,
    Timestamp? timestamp,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Stack(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getAvatarColor(name),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF075E54) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getAvatarColor(name),
                      ),
                    ),
                  if (!isMe) const SizedBox(height: 2),
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textEditingController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF075E54),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Generates a consistent color per username
  Color _getAvatarColor(String name) {
    final colors = [
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.red,
    ];
    final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[index];
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _logout() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'isOnline': false});
      }
      await FirebaseAuth.instance.signOut();
      if (mounted) context.goNamed('login');
    } catch (e) {
      print('Error logging out: $e');
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
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update({'isOnline': true});
    }
  }

  @override
  void initState() {
    super.initState();
    // Ensure user doc exists as soon as screen loads
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _ensureUserInFirestore(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data() as Map<String, dynamic>;
                    final String? senderId = data['senderId'];

                    // Skip old messages that have no senderId
                    if (senderId == null || senderId.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(senderId)
                          .get(),
                      builder: (context, userSnapshot) {
                        // Still loading
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text('Loading...'),
                          );
                        }

                        // Permission error or doc missing
                        if (userSnapshot.hasError ||
                            !userSnapshot.hasData ||
                            !userSnapshot.data!.exists) {
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child:
                              Icon(Icons.person, color: Colors.white),
                            ),
                            title: const Text('Unknown User'),
                            subtitle: Text(data['text'] ?? ''),
                          );
                        }

                        final userData = userSnapshot.data!.data()
                        as Map<String, dynamic>;
                        final String name =
                            userData['displayName'] ?? 'User';
                        final bool isOnline = userData['isOnline'] ?? false;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            isOnline ? Colors.green : Colors.grey,
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text(data['text'] ?? ''),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _textEditingController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No logged-in user!');
      return;
    }

    try {
      // Make sure user doc exists before sending
      await _ensureUserInFirestore(user);

      await FirebaseFirestore.instance.collection('messages').add({
        'text': text,
        'senderId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _textEditingController.clear();
    } catch (e) {
      print('Error sending message: $e');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to send message. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
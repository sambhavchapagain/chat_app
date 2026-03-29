import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  const ChatTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = (chat['unread'] ?? 0) > 0;
    final bool isSender  = chat['isSender'] ?? false;
    final bool isAudio   = chat['isAudio'] ?? false;
    final bool isPhoto   = chat['isPhoto'] ?? false;
    final bool isOnline  = chat['isOnline'] ?? false;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _buildAvatar(isOnline, hasUnread),
            const SizedBox(width: 12),
            _buildNameAndMessage(isSender, isAudio, isPhoto),
            _buildTimeAndBadge(hasUnread),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isOnline, bool hasUnread) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE5E5EA),
          child: Text(
            chat['initials'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
            ),
          ),
        ),
        if (isOnline && !hasUnread)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameAndMessage(
      bool isSender, bool isAudio, bool isPhoto) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chat['name'],
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              if (isSender)
                const Text(
                  'You: ',
                  style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
                ),
              if (isAudio)
                const Row(children: [
                  Icon(Icons.mic, size: 15, color: Color(0xFF007AFF)),
                  SizedBox(width: 2),
                  Text('Audio',
                      style: TextStyle(
                          fontSize: 15, color: Color(0xFF007AFF))),
                ])
              else if (isPhoto)
                const Row(children: [
                  Icon(Icons.image, size: 15, color: Color(0xFF007AFF)),
                  SizedBox(width: 2),
                  Text('Photo',
                      style: TextStyle(
                          fontSize: 15, color: Color(0xFF007AFF))),
                ])
              else
                Expanded(
                  child: Text(
                    chat['message'],
                    style: const TextStyle(
                        fontSize: 15, color: Color(0xFF8E8E93)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAndBadge(bool hasUnread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          chat['time'],
          style: TextStyle(
            fontSize: 13,
            color: hasUnread
                ? const Color(0xFF007AFF)
                : const Color(0xFF8E8E93),
          ),
        ),
        const SizedBox(height: 4),
        if (hasUnread)
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: const BoxDecoration(
              color: Color(0xFF007AFF),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${chat['unread']}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          const SizedBox(height: 20),
      ],
    );
  }
}
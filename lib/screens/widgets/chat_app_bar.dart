import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onNewChat;
  final VoidCallback onOpenHistory;

  const ChatAppBar({
    super.key,
    required this.title,
    required this.onNewChat,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
  //    backgroundColor: const Color(0xFF020617),
        title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onNewChat,
        ),
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: onOpenHistory,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/chat_provider.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/session_drawer.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/scroll_to_bottom_button.dart';
import 'widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  bool _showScrollToBottom = false;
  bool _shouldAutoScroll = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (currentScroll < maxScroll - 200) {
        _shouldAutoScroll = false;
        setState(() => _showScrollToBottom = true);
      } else {
        _shouldAutoScroll = true;
        setState(() => _showScrollToBottom = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool force = false}) {
    if (!force && !_shouldAutoScroll) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      key: _scaffoldKey,
     // backgroundColor: const Color(0xFF020617),
      appBar: ChatAppBar(
        title: chat.currentSession?.title ?? "AI Tutor",
        onNewChat: () {
          context.read<ChatProvider>().startNewChat();
          _shouldAutoScroll = true;
          _scrollToBottom(force: true);
        },
        onOpenHistory: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      endDrawer: const SessionDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ChatMessageList(
                  controller: _scrollController,
                  messages: chat.messages,
                ),
              ),
              if (chat.isTyping) const TypingIndicator(),
              MessageInput(
                onSend: () {
                  _shouldAutoScroll = true;
                  _scrollToBottom();
                },
              ),
            ],
          ),
          ScrollToBottomButton(
            visible: _showScrollToBottom,
            onTap: () {
              _shouldAutoScroll = true;
              _scrollToBottom(force: true);
            },
          ),
        ],
      ),
    );
  }
}

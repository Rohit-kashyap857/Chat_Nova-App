import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../models/message_model.dart';

class ChatMessageList extends StatelessWidget {
  final ScrollController controller;
  final List<MessageModel> messages;

  const ChatMessageList({
    super.key,
    required this.controller,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          "Start a new conversation 👋",
        //  style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];

        return Align(
          alignment:
          msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: msg.isUser
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF1F2937),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                bottomRight: Radius.circular(msg.isUser ? 4 : 18),
              ),
            ),
            child: _buildMessageContent(msg.text),
          ),
        );
      },
    );
  }

  Widget _buildMessageContent(String text) {
    if (!text.contains("```")) {
      return SelectableText(
        text,
        style: const TextStyle(
          fontSize: 15.5,
          height: 1.5,
          color: Colors.white,
        ),
      );
    }

    final parts = text.split("```");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(parts.length, (index) {
        final isCode = index % 2 == 1;

        if (!isCode) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: SelectableText(
              parts[index].trim(),
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          );
        }

        return _buildCodeBlock(parts[index].trim());
      }),
    );
  }

  Widget _buildCodeBlock(String code) {
    final lines = code.split('\n');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Code",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    size: 18,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: code));
                  },
                ),
              ],
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line numbers
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8),
                  color: const Color(0xFF0B1220),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: List.generate(
                      lines.length,
                          (index) => Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                // Highlighted code
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: HighlightView(
                    code,
                    language: 'dart',
                    theme: atomOneDarkTheme,
                    textStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

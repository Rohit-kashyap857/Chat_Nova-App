import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/chat_provider.dart';

class MessageInput extends StatefulWidget {
  final VoidCallback? onSend;

  const MessageInput({super.key, this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatProvider>().sendMessage(text);
    _controller.clear();
    widget.onSend?.call();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _handleSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: "Ask anything…",
                filled: true,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
     
          CircleAvatar(
            radius: 22,
            backgroundColor:
            _isListening ? Colors.green : const Color(0xFF423B3B),
            child: IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 20,
                color: Colors.white,
              ),
              onPressed: _listen,
            ),
          ),

          const SizedBox(width: 8),

        
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF423B3B),
            child: IconButton(
              icon: const Icon(Icons.send,
                  size: 18, color: Colors.white),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}

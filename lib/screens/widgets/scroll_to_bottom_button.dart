import 'package:flutter/material.dart';

class ScrollToBottomButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const ScrollToBottomButton({
    super.key,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned(
      bottom: 90,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: const Color(0xFF111827),
        onPressed: onTap,
        child: const Icon(Icons.arrow_downward),
      ),
    );
  }
}

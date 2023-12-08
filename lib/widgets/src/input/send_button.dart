import 'package:flutter/material.dart';

// import '../state/inherited_chat_theme.dart';
// import '../state/inherited_l10n.dart';

/// A class that represents send button widget.
class SendButton extends StatelessWidget {
  /// Creates send button widget.
  const SendButton({
    super.key,
    required this.onPressed,
    required this.color,
    this.padding = EdgeInsets.zero,
  });

  /// Callback for send button tap event.
  final VoidCallback onPressed;

  /// Padding around the button.
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
        child: IconButton(
          constraints: const BoxConstraints(
            minHeight: 24,
            minWidth: 24,
          ),
          icon: const Icon(Icons.send),
          color: color,
          onPressed: onPressed,
          padding: padding,
          splashRadius: 1,
          tooltip: "寄送",
        ),
      );
}

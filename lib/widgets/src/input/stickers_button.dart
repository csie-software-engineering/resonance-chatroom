import 'package:flutter/material.dart';

/// A class that represents attachment button widget.
class StickerButton extends StatelessWidget {
  /// Creates attachment button widget.
  const StickerButton({
    super.key,
    this.isLoading = false,
    this.onPressed,
    this.padding = EdgeInsets.zero,
  });

  /// Show a loading indicator instead of the button.
  final bool isLoading;

  /// Callback for attachment button tap event.
  final VoidCallback? onPressed;

  /// Padding around the button.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsetsDirectional.fromSTEB(
          0, // 8
          0,
          8,
          0,
        ),
    child: IconButton(
      constraints: const BoxConstraints(
        minHeight: 24,
        minWidth: 24,
      ),
      icon: const Icon(Icons.emoji_emotions), // 原本有 isLoading
      onPressed: isLoading ? null : onPressed,
      padding: padding,
      splashRadius: 24,
      tooltip: "貼圖",
    ),
  );
}

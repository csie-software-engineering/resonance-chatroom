import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resonance_chatroom/widgets/widgets.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// import '../../models/input_clear_mode.dart';
// import '../../models/send_button_visibility_mode.dart';
// import '../../util.dart';
// import '../state/inherited_chat_theme.dart';
// import '../state/inherited_l10n.dart';
// // import 'attachment_button.dart';
// import 'stickers_button.dart';
// import 'input_text_field_controller.dart';
// import 'send_button.dart';

/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
class Input extends StatefulWidget {
  /// Creates [Input] widget.
  const Input({
    super.key,
    // this.isAttachmentUploading,
    this.onAttachmentPressed,
    required this.onSendPressed,
    // this.options = const InputOptions(),
  });

  // final void Function(types.PartialText) onSendPressed;
  final void Function(String) onSendPressed; // 暫時先用 string 塞著

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.

  // final bool? isAttachmentUploading;

  /// See [AttachmentButton.onPressed].
  final VoidCallback? onAttachmentPressed;

  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.
  // final void Function(types.PartialText) onSendPressed;

  /// Customisation options for the [Input].
  final InputOptions options = const InputOptions();

  @override
  State<Input> createState() => _InputState();
}

/// [Input] widget state.
class _InputState extends State<Input> {
  late final _inputFocusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (event.physicalKey == PhysicalKeyboardKey.enter &&
          !HardwareKeyboard.instance.physicalKeysPressed.any(
                (el) => <PhysicalKeyboardKey>{
              PhysicalKeyboardKey.shiftLeft,
              PhysicalKeyboardKey.shiftRight,
            }.contains(el),
          )) {
        if (event is KeyDownEvent) {
          _handleSendPressed();
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  bool _sendButtonVisible = false;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = InputTextFieldController();
    _handleSendButtonVisibilityModeChange();
  }

  void _handleSendButtonVisibilityModeChange() {
    _textController.removeListener(_handleTextControllerChange);
    if (widget.options.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.hidden) {
      _sendButtonVisible = false;
    } else if (widget.options.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }
  }

  void _handleSendPressed() {
    final trimmedText = _textController.text.trim();
    if (trimmedText != '') {
      // final partialText = types.PartialText(text: trimmedText);
      // widget.onSendPressed(partialText);
      final partialText = trimmedText;
      widget.onSendPressed(partialText);

      if (widget.options.inputClearMode == InputClearMode.always) {
        _textController.clear();
      }
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text.trim() != '';
    });
  }

  Widget _inputBuilder() {
    final query = MediaQuery.of(context);
    const buttonPadding = EdgeInsets.fromLTRB(24, 20, 24, 20);
    final safeAreaInsets = EdgeInsets.fromLTRB(
      query.padding.left,
      0,
      query.padding.right,
      query.viewInsets.bottom + query.padding.bottom,
    ); // isMobile
    const textPadding = EdgeInsets.fromLTRB(0, 20, 0, 20);

    return Focus(
      autofocus: !widget.options.autofocus,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Material(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          color: Theme.of(context).colorScheme.primary,
          surfaceTintColor: Theme.of(context).colorScheme.secondary,
          elevation: 0,
          child: Container(
            padding: safeAreaInsets,
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                  IconButton(
                    // Next
                    color: const Color(0xff5c8736),
                    icon: const Icon(Icons.next_plan),
                    tooltip: "換話題",
                    onPressed: () {},
                    iconSize: 30,
                    splashRadius: 1,
                    padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                  ),
                IconButton( // sticker
                  // isLoading: widget.isAttachmentUploading ?? false,
                  color: const Color(0xff5c8736),
                  icon: const Icon(Icons.emoji_emotions),
                  tooltip: "貼圖",
                  onPressed: () {}, //  插入 function
                  iconSize: 30,
                  splashRadius: 1,
                  padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
                ),
                Expanded(
                  child: Padding(
                    padding: textPadding,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: TextField(
                        enabled: widget.options.enabled,
                        autocorrect: widget.options.autocorrect,
                        autofocus: widget.options.autofocus,
                        enableSuggestions: widget.options.enableSuggestions,
                        controller: _textController,
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffc8d7a7),
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          hintText: '輸入訊息',
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        ),
                        // decoration: InputDecoration(
                        //   filled: true, // 启用背景填充
                        //   fillColor: Colors.lightBlue, // 设置背景颜色
                        //   labelText: 'Enter your text',
                        //   border: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(10.0)
                        //   )
                        // ),
                        focusNode: _inputFocusNode,
                        keyboardType: widget.options.keyboardType,
                        maxLines: 5,
                        minLines: 1,
                        onChanged: widget.options.onTextChanged,
                        onTap: widget.options.onTextFieldTap,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: buttonPadding.bottom + buttonPadding.top + 24,
                  ),
                  child: SendButton(
                    onPressed: _handleSendPressed,
                    color: _sendButtonVisible ? Colors.black : Colors.black12,
                    padding: buttonPadding,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.sendButtonVisibilityMode !=
        oldWidget.options.sendButtonVisibilityMode) {
      _handleSendButtonVisibilityModeChange();
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _inputFocusNode.requestFocus(),
    child: _inputBuilder(),
  );
}

enum SendButtonVisibilityMode {
  /// Always show the [SendButton] regardless of the [TextField] state.
  always,

  /// The [SendButton] will only appear when the [TextField] is not empty.
  editing,

  /// Always hide the [SendButton] regardless of the [TextField] state.
  hidden,
}

enum InputClearMode {
  /// Always clear [Input] regardless if message is sent or not.
  always,
  /// Never clear [Input]. You should do it manually, depending on your use case.
  /// To clear the input manually, use [Input.options.textEditingController] (see
  /// docs how to use it properly, but TL;DR set it to [InputTextFieldController]
  /// imported from the library, to not lose any functionalily).
  never,
}

@immutable
class InputOptions {
  const InputOptions({
    this.inputClearMode = InputClearMode.always,
    this.keyboardType = TextInputType.multiline,
    this.onTextChanged,
    this.onTextFieldTap,
    this.sendButtonVisibilityMode = SendButtonVisibilityMode.editing,
    this.textEditingController,
    this.autocorrect = true,
    this.autofocus = false,
    this.enableSuggestions = true,
    this.enabled = true,
  });

  /// Controls the [Input] clear behavior. Defaults to [InputClearMode.always].
  final InputClearMode inputClearMode;

  /// Controls the [Input] keyboard type. Defaults to [TextInputType.multiline].
  final TextInputType keyboardType;

  /// Will be called whenever the text inside [TextField] changes.
  final void Function(String)? onTextChanged;

  /// Will be called on [TextField] tap.
  final VoidCallback? onTextFieldTap;

  /// Controls the visibility behavior of the [SendButton] based on the
  /// [TextField] state inside the [Input] widget.
  /// Defaults to [SendButtonVisibilityMode.editing].
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  /// Custom [TextEditingController]. If not provided, defaults to the
  /// [InputTextFieldController], which extends [TextEditingController] and has
  /// additional fatures like markdown support. If you want to keep additional
  /// features but still need some methods from the default [TextEditingController],
  /// you can create your own [InputTextFieldController] (imported from this lib)
  /// and pass it here.
  final TextEditingController? textEditingController;

  /// Controls the [TextInput] autocorrect behavior. Defaults to [true].
  final bool autocorrect;

  /// Whether [TextInput] should have focus. Defaults to [false].
  final bool autofocus;

  /// Controls the [TextInput] enableSuggestions behavior. Defaults to [true].
  final bool enableSuggestions;

  /// Controls the [TextInput] enabled behavior. Defaults to [true].
  final bool enabled;
}

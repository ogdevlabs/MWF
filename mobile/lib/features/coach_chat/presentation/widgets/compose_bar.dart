import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Bottom compose bar with TextField, camera icon button, and send button.
///
/// [onSend] is called with the message text and optional photo file path.
/// The send button is disabled when both text is empty and no photo is attached.
class ComposeBar extends StatefulWidget {
  const ComposeBar({super.key, required this.onSend});

  final ValueChanged<({String message, String? photoPath})> onSend;

  @override
  State<ComposeBar> createState() => _ComposeBarState();
}

class _ComposeBarState extends State<ComposeBar> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedPhotoPath;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to update send button enabled state
  }

  bool get _canSend =>
      _textController.text.isNotEmpty || _selectedPhotoPath != null;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _selectedPhotoPath = file.path);
    }
  }

  void _send() {
    if (!_canSend) return;
    widget.onSend((
      message: _textController.text,
      photoPath: _selectedPhotoPath,
    ));
    setState(() {
      _textController.clear();
      _selectedPhotoPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedPhotoPath != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedPhotoPath!),
                          width: 60,
                          height: 45,
                          fit: BoxFit.cover,
                          errorBuilder: (context2, err, stack) => Container(
                            width: 60,
                            height: 45,
                            color: colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image, size: 20),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _selectedPhotoPath = null),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Message coach…',
                        hintStyle: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: const Icon(Icons.photo_camera_outlined),
                      onPressed: _pickPhoto,
                      tooltip: 'Attach photo',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: FilledButton(
                      onPressed: _canSend ? _send : null,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: _canSend
                            ? colorScheme.primary
                            : colorScheme.onSurface
                                .withValues(alpha: 0.38),
                        minimumSize: const Size(44, 44),
                      ),
                      child: Semantics(
                        label: 'Send message',
                        child: const Icon(Icons.send, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

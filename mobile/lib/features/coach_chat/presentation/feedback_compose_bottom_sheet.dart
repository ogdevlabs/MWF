import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/feedback_providers.dart';
import '../../../core/sync/connectivity_provider.dart';

/// Bottom sheet for composing session-linked feedback to the coach.
///
/// Opens via [showModalBottomSheet] from [SessionCompletionScreen].
/// Submits feedback tied to the specific session ([sessionId]).
/// Guards against duplicate submissions with UNIQUE constraint check.
class FeedbackComposeBottomSheet extends ConsumerStatefulWidget {
  const FeedbackComposeBottomSheet({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
  });

  final String sessionId;
  final String sessionTitle;

  @override
  ConsumerState<FeedbackComposeBottomSheet> createState() =>
      _FeedbackComposeBottomSheetState();
}

class _FeedbackComposeBottomSheetState
    extends ConsumerState<FeedbackComposeBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedPhotoPath;
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend =>
      !_isSending &&
      (_controller.text.trim().isNotEmpty || _selectedPhotoPath != null);

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _selectedPhotoPath = picked.path);
    }
  }

  void _removePhoto() {
    setState(() => _selectedPhotoPath = null);
  }

  Future<void> _send() async {
    if (!_canSend) return;
    setState(() => _isSending = true);

    final repo = ref.read(feedbackRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // UNIQUE constraint guard — one feedback per session
      final existing = await repo.getBySession(widget.sessionId);
      if (existing != null) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('You already sent feedback for this session'),
            ),
          );
          navigator.pop();
        }
        return;
      }

      final isOnline = ref.read(connectivityProvider);
      String? photoUrl;
      String? localPhotoPath;

      if (_selectedPhotoPath != null) {
        if (isOnline) {
          photoUrl = await repo.uploadPhoto(File(_selectedPhotoPath!));
        } else {
          localPhotoPath = _selectedPhotoPath;
        }
      }

      await repo.submitFeedback(
        sessionId: widget.sessionId,
        message: _controller.text.trim(),
        photoUrl: photoUrl,
        localPhotoPath: localPhotoPath,
        isOnline: isOnline,
      );

      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Note sent to coach')),
        );
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to send — tap to retry'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title + session subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Feedback to Coach',
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Session: ${widget.sessionTitle}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Text input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _controller,
              minLines: 4,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              style: textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Write a note to your coach...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          // Photo attachment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _selectedPhotoPath == null
                ? TextButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Attach Photo'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      alignment: Alignment.centerLeft,
                    ),
                  )
                : Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedPhotoPath!),
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _removePhoto,
                        icon: const Icon(Icons.close),
                        tooltip: 'Remove photo',
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          // Send button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _canSend ? _send : null,
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Note'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

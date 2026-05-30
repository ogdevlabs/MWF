import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/feedback_providers.dart';
import '../domain/feedback_message_model.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/compose_bar.dart';

/// iMessage-style chat thread between student and coach.
///
/// Accepts an optional [sessionId] query param — when present, the screen
/// scrolls to and highlights the matching message (deep-link support from
/// FCM notification tap).
class CoachChatScreen extends ConsumerStatefulWidget {
  const CoachChatScreen({super.key, this.sessionId});

  final String? sessionId;

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to the message matching [widget.sessionId].
  void _scrollToHighlighted(List<LocalFeedbackThread> threads) {
    if (widget.sessionId == null) return;
    final index =
        threads.indexWhere((t) => t.sessionId == widget.sessionId);
    if (index < 0) return;

    // Build flat item list the same way the ListView does
    int itemCount = 0;
    int targetItem = 0;
    for (int i = 0; i < threads.length; i++) {
      if (i == index) targetItem = itemCount;
      itemCount++; // student bubble
      if (threads[i].coachReply != null) itemCount++; // coach reply
    }

    // With reverse: true, item 0 is the last item visually (newest at bottom)
    final reversedTarget = itemCount - 1 - targetItem;
    const estimatedItemHeight = 88.0;
    final offset = reversedTarget * estimatedItemHeight;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          offset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _handleSend(
      ({String message, String? photoPath}) payload) async {
    final repo = ref.read(feedbackRepositoryProvider);
    try {
      String? photoUrl;
      if (payload.photoPath != null) {
        photoUrl = await repo.uploadPhoto(File(payload.photoPath!));
      }
      await repo.submitFeedback(
        sessionId: kGeneralSessionId,
        message: payload.message,
        photoUrl: photoUrl,
        isOnline: true,
      );
    } catch (_) {
      // Fall back to offline path (enqueues to SyncQueue for later replay)
      await repo.submitFeedback(
        sessionId: kGeneralSessionId,
        message: payload.message,
        localPhotoPath: payload.photoPath,
        isOnline: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final threadsAsync = ref.watch(feedbackThreadProvider);
    final studentId = ref.read(feedbackRepositoryProvider).studentId;

    return Scaffold(
      appBar: AppBar(title: const Text('Coach')),
      body: Column(
        children: [
          Expanded(
            child: threadsAsync.when(
              data: (threads) {
                if (widget.sessionId != null) {
                  _scrollToHighlighted(threads);
                }

                if (threads.isEmpty) {
                  // Empty state: show welcome message from coach
                  return ListView(
                    reverse: true,
                    controller: _scrollController,
                    children: [
                      _WelcomeBubble(),
                    ],
                  );
                }

                // Build flat list of bubbles (student + optional coach reply)
                final items = <_BubbleItem>[];
                for (final thread in threads) {
                  items.add(_BubbleItem(thread: thread, isCoach: false));
                  if (thread.coachReply != null) {
                    items.add(_BubbleItem(thread: thread, isCoach: true));
                  }
                }

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    // reverse: true + reversed index = ascending order
                    final forwardIndex = items.length - 1 - index;
                    final item = items[forwardIndex];
                    final isHighlighted = widget.sessionId != null &&
                        item.thread.sessionId == widget.sessionId;
                    return ChatBubble(
                      thread: item.thread,
                      isCoach: item.isCoach,
                      studentId: studentId,
                      highlighted: isHighlighted,
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    const Text('Failed to load conversations'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(feedbackThreadProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ComposeBar(onSend: _handleSend),
        ],
      ),
    );
  }
}

class _BubbleItem {
  const _BubbleItem({required this.thread, required this.isCoach});
  final LocalFeedbackThread thread;
  final bool isCoach;
}

/// Synthetic welcome message shown when the thread has no messages yet.
class _WelcomeBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[Coach]',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text(
              "Hi! Complete a session and send me a note — I'd love to hear how it went. 🌿",
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

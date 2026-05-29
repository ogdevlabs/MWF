import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import 'photo_thumbnail.dart';

/// Renders a single chat message bubble.
///
/// [isCoach] = true: coach reply bubble (left-aligned, surfaceContainerHighest).
/// [isCoach] = false: student message bubble (right-aligned, primaryContainer).
/// [highlighted] = true: adds a colored border for deep-link highlight.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.thread,
    required this.isCoach,
    required this.studentId,
    this.highlighted = false,
  });

  final LocalFeedbackThread thread;
  final bool isCoach;
  final String studentId;
  final bool highlighted;

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = isPm ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;

    final backgroundColor = isCoach
        ? colorScheme.surfaceContainerHighest
        : colorScheme.primaryContainer;

    final borderRadius = isCoach
        ? const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    final messageText = isCoach ? thread.coachReply! : thread.studentMessage;
    final timestamp = isCoach ? thread.repliedAt! : thread.createdAt;
    final isPending = !isCoach && thread.status == 'pending';

    Widget bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: highlighted
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thread.photoUrl != null || thread.localPhotoPath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PhotoThumbnail(
                photoUrl: thread.photoUrl,
                localPhotoPath: thread.localPhotoPath,
              ),
            ),
          Text(
            messageText,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );

    // Sender label + timestamp row
    Widget timestampRow;
    if (isCoach) {
      timestampRow = Text(
        '[Coach] ${_formatTime(timestamp)}',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      timestampRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPending)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.schedule,
                size: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          Text(
            '${_formatTime(timestamp)} [You]',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    final semanticLabel =
        '${isCoach ? 'Coach' : 'You'} at ${_formatTime(timestamp)}: $messageText';

    return Semantics(
      label: semanticLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Column(
          crossAxisAlignment:
              isCoach ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            if (isCoach)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: timestampRow,
              ),
            bubble,
            if (!isCoach)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: timestampRow,
              ),
          ],
        ),
      ),
    );
  }
}

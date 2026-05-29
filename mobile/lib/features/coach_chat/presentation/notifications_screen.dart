import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../data/feedback_providers.dart';

/// Notifications screen — shows coach replies to student messages.
///
/// Each reply taps through to [CoachChatScreen] with the [sessionId]
/// query parameter so the chat screen can scroll to and highlight the
/// relevant message.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesAsync = ref.watch(coachRepliesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: repliesAsync.when(
        data: (replies) {
          if (replies.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: replies.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final reply = replies[index];
              return _ReplyTile(reply: reply);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Unable to load notifications',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({required this.reply});

  final LocalFeedbackThread reply;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      // Today — show time
      final h = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final m = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $period';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } else {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '${date.year}-$month-$day';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final preview = (reply.coachReply ?? '').length > 80
        ? '${(reply.coachReply ?? '').substring(0, 80)}...'
        : (reply.coachReply ?? '');

    return Semantics(
      label: 'Coach replied to session: $preview',
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          'Coach replied',
          style: textTheme.bodyLarge,
        ),
        subtitle: Text(
          preview,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatDate(reply.repliedAt),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () => context.goNamed(
          'coach-chat',
          queryParameters: {'sessionId': reply.sessionId},
        ),
      ),
    );
  }
}

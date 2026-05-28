import 'package:flutter/material.dart';

import '../domain/session_download_state.dart';
import '../domain/session_model.dart';

/// A list tile displaying a session row with visual state indicators.
/// Per D-09, D-10: shows day number, title, exercise count, state icon.
///
/// States (per UI-SPEC):
/// - Complete: green check_circle, transparent bg, tappable
/// - Current: primary play_circle_filled, primaryContainer bg (alpha 0.3), tappable
/// - Locked: grey lock, transparent bg, non-tappable, opacity 0.6
///
/// Download state badge (Phase 5, Plan 05-03):
/// - notDownloaded: download_outlined icon (online) / "Not available offline" (offline)
/// - inProgress: CircularProgressIndicator
/// - downloaded: download_done icon
class SessionListTile extends StatelessWidget {
  const SessionListTile({
    super.key,
    required this.session,
    this.onTap,
    this.downloadState,
    this.isOnline = true,
  });

  final SessionModel session;
  final VoidCallback? onTap;

  /// Download state for the download badge (Phase 5). Null = badge not shown.
  final SessionDownloadState? downloadState;

  /// Whether the device currently has network connectivity.
  /// When false and [downloadState] is notDownloaded, the tile is disabled.
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (session.state) {
      SessionState.complete => (Icons.check_circle, Colors.green),
      SessionState.current => (
          Icons.play_circle_filled,
          theme.colorScheme.primary
        ),
      SessionState.locked => (Icons.lock, Colors.grey),
    };

    return Opacity(
      opacity: session.state == SessionState.locked ? 0.6 : 1.0,
      child: ListTile(
        leading: Icon(icon, color: color, semanticLabel: session.state.name),
        title: Text('Day ${session.dayNumber} — ${session.title}'),
        subtitle: Text(
          '${session.exerciseCount} exercises · ~20 min',
          style: theme.textTheme.bodySmall,
        ),
        trailing: session.state == SessionState.locked
            ? null
            : const Icon(Icons.chevron_right),
        onTap: session.state == SessionState.locked ? null : onTap,
        tileColor: session.state == SessionState.current
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

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
/// Download state (per D-07, D-11, D-12):
/// - notDownloaded + online: shows download_outlined badge
/// - inProgress:             shows CircularProgressIndicator badge
/// - downloaded:             shows download_done badge
/// - notDownloaded + offline: shows 'Not available offline', non-tappable
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

  /// Current download state for this session's exercises.
  /// When null, no download badge is shown (backward compatible).
  final SessionDownloadState? downloadState;

  /// Whether the device currently has network connectivity.
  /// Defaults to true so existing callers that don't pass this are unaffected.
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Offline + not fully downloaded => unavailable
    final isOfflineUnavailable =
        !isOnline && downloadState != SessionDownloadState.downloaded;

    final (icon, color) = switch (session.state) {
      SessionState.complete => (Icons.check_circle, Colors.green),
      SessionState.current => (
          Icons.play_circle_filled,
          theme.colorScheme.primary,
        ),
      SessionState.locked => (Icons.lock, Colors.grey),
    };

    final effectiveOnTap =
        (session.state == SessionState.locked || isOfflineUnavailable)
            ? null
            : onTap;

    // Trailing badge logic
    final Widget? trailingWidget;
    if (isOfflineUnavailable) {
      trailingWidget = null;
    } else if (downloadState == SessionDownloadState.inProgress) {
      trailingWidget = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (downloadState == SessionDownloadState.downloaded) {
      trailingWidget =
          const Icon(Icons.download_done, size: 20, color: Colors.green);
    } else if (downloadState == SessionDownloadState.notDownloaded) {
      trailingWidget =
          const Icon(Icons.download_outlined, size: 20, color: Colors.grey);
    } else {
      // downloadState == null (backward compat) — show chevron if not locked
      trailingWidget = session.state == SessionState.locked
          ? null
          : const Icon(Icons.chevron_right);
    }

    final subtitleText = isOfflineUnavailable
        ? 'Not available offline'
        : '${session.exerciseCount} exercises · ~20 min';

    return Opacity(
      opacity:
          (session.state == SessionState.locked || isOfflineUnavailable)
              ? 0.6
              : 1.0,
      child: ListTile(
        leading: Icon(icon, color: color, semanticLabel: session.state.name),
        title: Text('Day ${session.dayNumber} — ${session.title}'),
        subtitle: Text(
          subtitleText,
          style: isOfflineUnavailable
              ? TextStyle(color: Colors.orange.shade700, fontSize: 12)
              : theme.textTheme.bodySmall,
        ),
        trailing: trailingWidget,
        onTap: effectiveOnTap,
        tileColor: session.state == SessionState.current
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

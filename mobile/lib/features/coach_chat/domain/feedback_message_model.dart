/// Sentinel session ID for general DM messages not linked to a specific session.
/// Used by the compose bar on CoachChatScreen (free-form DM).
/// The FeedbackComposeBottomSheet uses the real session_id from the completed session.
const String kGeneralSessionId = '00000000-0000-0000-0000-000000000000';

/// Status of a feedback message in the local database.
enum FeedbackStatus {
  sent, // Successfully synced or online-submitted
  pending, // Offline — awaiting SyncQueue replay
}

-- 003_cqrs_read_models.sql
-- CQRS Query-Side Projection Views
-- IMPORTANT: Regular views with security_invoker=true (NOT materialized)
-- Materialized views break RLS — they cannot call auth.uid() at query time.

-- 1. program_catalog_view: Published programs with enrollment/subscription overlay
CREATE VIEW program_catalog_view WITH (security_invoker = true) AS
SELECT
  p.id,
  p.title,
  p.description,
  p.difficulty,
  p.duration_weeks,
  p.thumbnail_url,
  p.published_at,
  e.id AS enrollment_id,
  e.current_day,
  CASE WHEN sub.status = 'active' THEN true ELSE false END AS is_subscribed
FROM programs p
LEFT JOIN enrollments e ON e.program_id = p.id AND e.student_id = auth.uid()
LEFT JOIN subscriptions sub ON sub.student_id = auth.uid() AND sub.status = 'active'
WHERE p.published = true;

GRANT SELECT ON program_catalog_view TO authenticated;

-- 2. student_today_session_view: Current session for enrolled student
CREATE VIEW student_today_session_view WITH (security_invoker = true) AS
SELECT
  e.student_id,
  e.program_id,
  e.current_day,
  s.id AS session_id,
  s.title AS session_title,
  s.day_number,
  p.title AS program_title,
  CASE WHEN sub.status = 'active' THEN true ELSE false END AS is_unlocked
FROM enrollments e
JOIN programs p ON p.id = e.program_id
JOIN sessions s ON s.program_id = e.program_id AND s.day_number = e.current_day
LEFT JOIN subscriptions sub ON sub.student_id = e.student_id AND sub.status = 'active'
WHERE e.student_id = auth.uid();

GRANT SELECT ON student_today_session_view TO authenticated;

-- 3. session_playback_view: Ordered exercises with media readiness for a session
CREATE VIEW session_playback_view WITH (security_invoker = true) AS
SELECT
  s.id AS session_id,
  s.program_id,
  s.title AS session_title,
  s.day_number,
  ex.id AS exercise_id,
  ex.display_order,
  ex.title AS exercise_title,
  ex.cue_text,
  ex.mux_playback_id,
  ex.mux_download_url,
  ex.model_asset_url,
  ex.rep_count,
  ex.duration_seconds,
  ex.video_version,
  CASE WHEN ex.mux_playback_id IS NOT NULL THEN true ELSE false END AS video_ready,
  CASE WHEN ex.model_asset_url IS NOT NULL THEN true ELSE false END AS model_ready
FROM sessions s
JOIN exercises ex ON ex.session_id = s.id
WHERE EXISTS (
  SELECT 1 FROM enrollments e
  WHERE e.program_id = s.program_id AND e.student_id = auth.uid()
)
ORDER BY s.id, ex.display_order;

GRANT SELECT ON session_playback_view TO authenticated;

-- 4. student_progress_dashboard_view: Completion aggregates for progress screen
CREATE VIEW student_progress_dashboard_view WITH (security_invoker = true) AS
SELECT
  pr.student_id,
  COUNT(pr.id) AS total_completions,
  MAX(pr.completed_at) AS last_completed_at,
  SUM(pr.duration_seconds) AS total_duration_seconds,
  e.program_id,
  p.title AS program_title,
  p.duration_weeks,
  e.current_day
FROM progress_records pr
JOIN sessions s ON s.id = pr.session_id
JOIN enrollments e ON e.program_id = s.program_id AND e.student_id = pr.student_id
JOIN programs p ON p.id = e.program_id
WHERE pr.student_id = auth.uid()
GROUP BY pr.student_id, e.program_id, p.title, p.duration_weeks, e.current_day;

GRANT SELECT ON student_progress_dashboard_view TO authenticated;

-- 5. student_notifications_view: Coach replies ordered by time
CREATE VIEW student_notifications_view WITH (security_invoker = true) AS
SELECT
  ft.id,
  ft.session_id,
  ft.student_message,
  ft.coach_reply,
  ft.replied_at,
  ft.notification_sent,
  s.title AS session_title,
  p.title AS program_title
FROM feedback_threads ft
JOIN sessions s ON s.id = ft.session_id
JOIN programs p ON p.id = s.program_id
WHERE ft.student_id = auth.uid()
  AND ft.coach_reply IS NOT NULL
ORDER BY ft.replied_at DESC;

GRANT SELECT ON student_notifications_view TO authenticated;

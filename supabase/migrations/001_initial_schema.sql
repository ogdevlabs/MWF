-- 001_initial_schema.sql
-- Mat Pilates Coach — Initial Schema
-- Source: specs/001-mat-pilates-coach/data-model.md
-- Generated: 2026-05-25 — verify against spec if data-model.md is updated.

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE students (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  display_name text,
  avatar_url text,
  timezone text NOT NULL DEFAULT 'UTC',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  revenuecat_customer_id text NOT NULL,
  plan_id text NOT NULL,
  status text NOT NULL CHECK (status IN ('active', 'expired', 'cancelled', 'grace_period')),
  valid_until timestamptz,
  store text NOT NULL CHECK (store IN ('app_store', 'play_store')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE programs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  difficulty text NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  duration_weeks int NOT NULL,
  thumbnail_url text,
  published boolean NOT NULL DEFAULT false,
  published_at timestamptz,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id uuid NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
  day_number int NOT NULL,
  title text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (program_id, day_number)
);

CREATE TABLE exercises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  display_order int NOT NULL,
  title text NOT NULL,
  cue_text text,
  mux_asset_id text,
  mux_playback_id text,
  mux_download_url text,
  model_asset_url text,
  rep_count int,
  duration_seconds int,
  video_version int NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (session_id, display_order)
);

CREATE TABLE enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  program_id uuid NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
  enrolled_at timestamptz NOT NULL DEFAULT now(),
  current_day int NOT NULL DEFAULT 1,
  UNIQUE (student_id, program_id)
);

CREATE TABLE progress_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  session_id uuid NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  completed_at timestamptz NOT NULL,
  duration_seconds int,
  synced_from_offline boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (student_id, session_id)
);

CREATE TABLE metric_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  metric_type text NOT NULL CHECK (metric_type IN ('weight', 'measurement', 'flexibility')),
  metric_subtype text,
  value numeric(7,2) NOT NULL,
  unit text NOT NULL CHECK (unit IN ('kg', 'cm', 'degrees')),
  logged_at date NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE feedback_threads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  session_id uuid NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  student_message text NOT NULL,
  photo_url text,
  coach_reply text,
  replied_at timestamptz,
  notification_sent boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (student_id, session_id)
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE metric_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_threads ENABLE ROW LEVEL SECURITY;

-- Students: read/update own row only
CREATE POLICY "students_select_own" ON students FOR SELECT USING (id = auth.uid());
CREATE POLICY "students_update_own" ON students FOR UPDATE USING (id = auth.uid());
CREATE POLICY "students_insert_own" ON students FOR INSERT WITH CHECK (id = auth.uid());

-- Subscriptions: students read own; webhook (service role) writes
CREATE POLICY "subscriptions_select_own" ON subscriptions FOR SELECT USING (student_id = auth.uid());

-- Programs: any authenticated user reads published programs
CREATE POLICY "programs_select_published" ON programs FOR SELECT USING (published = true);

-- Sessions: readable by students enrolled in parent program
CREATE POLICY "sessions_select_enrolled" ON sessions FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM enrollments
    WHERE enrollments.program_id = sessions.program_id
      AND enrollments.student_id = auth.uid()
  ));

-- Exercises: readable by students enrolled in parent program
CREATE POLICY "exercises_select_enrolled" ON exercises FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM enrollments e
    JOIN sessions s ON s.id = exercises.session_id
    WHERE e.program_id = s.program_id
      AND e.student_id = auth.uid()
  ));

-- Enrollments: students read and insert own
CREATE POLICY "enrollments_select_own" ON enrollments FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "enrollments_insert_own" ON enrollments FOR INSERT WITH CHECK (student_id = auth.uid());

-- Progress records: students read and insert own
CREATE POLICY "progress_select_own" ON progress_records FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "progress_insert_own" ON progress_records FOR INSERT WITH CHECK (student_id = auth.uid());

-- Metric logs: students read and insert own
CREATE POLICY "metrics_select_own" ON metric_logs FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "metrics_insert_own" ON metric_logs FOR INSERT WITH CHECK (student_id = auth.uid());

-- Feedback threads: students read ONLY own (private DM — no cross-student access)
CREATE POLICY "feedback_select_own" ON feedback_threads FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "feedback_insert_own" ON feedback_threads FOR INSERT WITH CHECK (student_id = auth.uid());

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_subscriptions_student ON subscriptions(student_id);
CREATE INDEX idx_sessions_program ON sessions(program_id);
CREATE INDEX idx_exercises_session ON exercises(session_id);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_program ON enrollments(program_id);
CREATE INDEX idx_progress_student ON progress_records(student_id);
CREATE INDEX idx_progress_session ON progress_records(session_id);
CREATE INDEX idx_metric_logs_student ON metric_logs(student_id);
CREATE INDEX idx_metric_logs_type ON metric_logs(student_id, metric_type);
CREATE INDEX idx_feedback_student ON feedback_threads(student_id);
CREATE INDEX idx_feedback_session ON feedback_threads(session_id);

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_students BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at_subscriptions BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at_programs BEFORE UPDATE ON programs FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at_sessions BEFORE UPDATE ON sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at_exercises BEFORE UPDATE ON exercises FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at_feedback BEFORE UPDATE ON feedback_threads FOR EACH ROW EXECUTE FUNCTION update_updated_at();

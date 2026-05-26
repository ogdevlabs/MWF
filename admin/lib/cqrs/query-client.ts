import { createClient } from '@supabase/supabase-js';

// Admin uses service role key — bypasses RLS for coach access
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
);

/**
 * CQRS Query Client for the admin panel.
 *
 * Reads from projection views defined in 003_cqrs_read_models.sql.
 * Uses service role key for full access (coach sees all students' data).
 * Feature pages import these functions instead of making raw Supabase queries.
 */

export interface ProgramCatalogItem {
  id: string;
  title: string;
  description: string | null;
  difficulty: string;
  duration_weeks: number;
  thumbnail_url: string | null;
  published_at: string | null;
  enrollment_id: string | null;
  current_day: number | null;
  is_subscribed: boolean;
}

export interface StudentProgressItem {
  student_id: string;
  total_completions: number;
  last_completed_at: string | null;
  total_duration_seconds: number | null;
  program_id: string;
  program_title: string;
  duration_weeks: number;
  current_day: number;
}

export interface NotificationItem {
  id: string;
  session_id: string;
  student_message: string;
  coach_reply: string | null;
  replied_at: string | null;
  notification_sent: boolean;
  session_title: string;
  program_title: string;
}

/**
 * Fetch all programs from the catalog view.
 * Admin sees all published programs regardless of enrollment.
 */
export async function getProgramCatalog(): Promise<ProgramCatalogItem[]> {
  const { data, error } = await supabase
    .from('program_catalog_view')
    .select('*');
  if (error) throw error;
  return data ?? [];
}

/**
 * Fetch progress dashboard data for a specific student.
 * Coach can view any student's progress.
 */
export async function getStudentProgress(
  studentId: string,
): Promise<StudentProgressItem[]> {
  const { data, error } = await supabase
    .from('student_progress_dashboard_view')
    .select('*')
    .eq('student_id', studentId);
  if (error) throw error;
  return data ?? [];
}

/**
 * Fetch all notifications (feedback threads with replies).
 * Coach sees all students' threads for reply management.
 */
export async function getAllNotifications(): Promise<NotificationItem[]> {
  const { data, error } = await supabase
    .from('student_notifications_view')
    .select('*')
    .order('replied_at', { ascending: false });
  if (error) throw error;
  return data ?? [];
}

/**
 * Fetch pending feedback threads (no coach reply yet).
 * Reads from the base table since the notifications view only has replied items.
 */
export async function getPendingFeedback() {
  const { data, error } = await supabase
    .from('feedback_threads')
    .select('*, sessions(title, programs(title))')
    .is('coach_reply', null)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return data ?? [];
}

/**
 * Fetch session playback details for content management.
 */
export async function getSessionPlayback(sessionId: string) {
  const { data, error } = await supabase
    .from('session_playback_view')
    .select('*')
    .eq('session_id', sessionId)
    .order('display_order');
  if (error) throw error;
  return data ?? [];
}

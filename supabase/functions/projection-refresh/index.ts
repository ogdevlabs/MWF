

// Projection Refresh Handler
// Triggered by Supabase Database Webhook on command-side table changes.
// Since we use regular views (not materialized), projections are always fresh.
// This function logs the refresh event for monitoring/idempotency tracking.
//
// Webhook configuration (manual step in Supabase Dashboard):
//   Tables: programs, sessions, exercises, enrollments, progress_records, metric_logs, feedback_threads
//   Events: INSERT, UPDATE, DELETE
//   URL: https://<project-ref>.supabase.co/functions/v1/projection-refresh

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: Record<string, unknown>;
  old_record: Record<string, unknown> | null;
  schema: string;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const payload: WebhookPayload = await req.json();

    // Log the event — views are live, no refresh needed
    // This endpoint exists for:
    // 1. Monitoring projection lag (compare event timestamp vs query freshness)
    // 2. Future cache invalidation hooks
    // 3. Idempotency tracking
    console.log(
      `[projection-refresh] ${payload.type} on ${payload.schema}.${payload.table}`,
    );

    return Response.json({
      refreshed: true,
      table: payload.table,
      type: payload.type,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error("[projection-refresh] Error processing webhook:", error);
    return Response.json(
      { error: "Failed to process webhook payload" },
      { status: 400 },
    );
  }
});

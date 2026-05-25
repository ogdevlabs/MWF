import "@supabase/functions-js/edge-runtime.d.ts";

// Mux webhook stub
// TODO Phase 8: Validate Mux-Signature header using MUX_WEBHOOK_SIGNING_SECRET
// TODO Phase 8: On video.asset.ready event, update exercises.mux_playback_id and mux_download_url
// Payload shape: { type: "video.asset.ready", data: { id: string, playback_ids: [...] } }

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = await req.json();
  console.log("Mux webhook received:", body.type);

  return Response.json({ received: true });
});

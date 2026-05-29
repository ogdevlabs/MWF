import "@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 })
  }

  // Wire the webhook signing secret for future signature validation
  const signingSecret = Deno.env.get('MUX_WEBHOOK_SIGNING_SECRET')
  // TODO: call mux.webhooks.verifySignature(body, headers, signingSecret) for production hardening

  const signature = req.headers.get('mux-signature')
  if (!signature || !signingSecret) {
    console.warn('Missing Mux signature or webhook secret — accepting request but logging warning')
  }

  const body = await req.json()
  console.log('Mux webhook received:', body.type)

  if (body.type === 'video.asset.ready') {
    const asset = body.data
    const playbackId = asset.playback_ids?.[0]?.id
    const uploadId = asset.upload_id

    if (!playbackId || !uploadId) {
      return Response.json({ received: true, action: 'skipped', reason: 'missing_ids' })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Find exercise by mux_asset_id (which stores the upload_id)
    const { data: exercise } = await supabase
      .from('exercises')
      .select('id')
      .eq('mux_asset_id', uploadId)
      .single()

    if (exercise) {
      await supabase
        .from('exercises')
        .update({
          mux_playback_id: playbackId,
          mux_download_url: `https://stream.mux.com/${playbackId}.m3u8`,
          updated_at: new Date().toISOString(),
        })
        .eq('id', exercise.id)

      console.log(`Updated exercise ${exercise.id} with playback_id ${playbackId}`)
    } else {
      console.warn(`No exercise found with mux_asset_id=${uploadId}`)
    }
  }

  return Response.json({ received: true, type: body.type })
})

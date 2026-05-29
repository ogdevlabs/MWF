import Mux from '@mux/mux-node'
import { createSupabaseServerClient } from '@/lib/supabase/server'

const mux = new Mux({
  tokenId: process.env.MUX_TOKEN_ID!,
  tokenSecret: process.env.MUX_TOKEN_SECRET!,
})

export async function POST() {
  // Verify auth — use getUser() not getSession()
  const supabase = await createSupabaseServerClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return new Response('Unauthorized', { status: 401 })
  }

  const upload = await mux.video.uploads.create({
    cors_origin: process.env.NEXT_PUBLIC_APP_URL ?? '*',
    new_asset_settings: {
      playback_policies: ['public'],
    },
  })

  return Response.json({ uploadId: upload.id, url: upload.url })
}

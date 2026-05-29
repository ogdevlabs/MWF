import { createClient } from '@supabase/supabase-js'

/**
 * Service role client for coach writes — bypasses RLS.
 * Only use server-side (Server Actions, Route Handlers).
 * Never expose to the client.
 */
export function createServiceClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )
}

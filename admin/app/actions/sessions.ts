'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { z } from 'zod'
import { createServiceClient } from '@/lib/supabase/service'

const SessionSchema = z.object({
  day_number: z.coerce.number().int().positive(),
  title: z.string().min(1, 'Title is required').max(100),
  description: z.string().optional().default(''),
})

export async function createSession(
  programId: string,
  prevState: unknown,
  formData: FormData
): Promise<{ errors?: Record<string, string[]> }> {
  const result = SessionSchema.safeParse(Object.fromEntries(formData))

  if (!result.success) {
    return { errors: result.error.flatten().fieldErrors }
  }

  const supabase = createServiceClient()
  const { data, error } = await supabase
    .from('sessions')
    .insert({ ...result.data, program_id: programId })
    .select('id')
    .single()

  if (error || !data) {
    return { errors: { day_number: ['Failed to create session. Please try again.'] } }
  }

  revalidatePath(`/programs/${programId}`)
  redirect(`/programs/${programId}/sessions/${data.id}`)
}

export async function updateSession(
  programId: string,
  sessionId: string,
  prevState: unknown,
  formData: FormData
): Promise<{ errors?: Record<string, string[]>; success?: boolean }> {
  const result = SessionSchema.safeParse(Object.fromEntries(formData))

  if (!result.success) {
    return { errors: result.error.flatten().fieldErrors }
  }

  const supabase = createServiceClient()
  const { error } = await supabase
    .from('sessions')
    .update({ ...result.data, updated_at: new Date().toISOString() })
    .eq('id', sessionId)

  if (error) {
    return { errors: { title: ['Failed to update session. Please try again.'] } }
  }

  revalidatePath(`/programs/${programId}/sessions/${sessionId}`)
  return { success: true }
}

export async function deleteSession(
  programId: string,
  sessionId: string
): Promise<void> {
  const supabase = createServiceClient()
  await supabase.from('sessions').delete().eq('id', sessionId)

  revalidatePath(`/programs/${programId}`)
  redirect(`/programs/${programId}`)
}

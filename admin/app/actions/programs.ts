'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { z } from 'zod'
import { createServiceClient } from '@/lib/supabase/service'

const ProgramSchema = z.object({
  title: z.string().min(1, 'Title is required').max(100),
  description: z.string().optional().default(''),
  difficulty: z.enum(['beginner', 'intermediate', 'advanced']),
  duration_weeks: z.coerce.number().int().positive().max(52),
  thumbnail_url: z.string().optional(),
})

export async function createProgram(
  prevState: unknown,
  formData: FormData
): Promise<{ errors?: Record<string, string[]> }> {
  const result = ProgramSchema.safeParse(Object.fromEntries(formData))

  if (!result.success) {
    return { errors: result.error.flatten().fieldErrors }
  }

  const supabase = createServiceClient()
  const { data, error } = await supabase
    .from('programs')
    .insert(result.data)
    .select('id')
    .single()

  if (error || !data) {
    return { errors: { title: ['Failed to create program. Please try again.'] } }
  }

  revalidatePath('/programs')
  redirect(`/programs/${data.id}`)
}

export async function updateProgram(
  programId: string,
  prevState: unknown,
  formData: FormData
): Promise<{ errors?: Record<string, string[]>; success?: boolean }> {
  const result = ProgramSchema.safeParse(Object.fromEntries(formData))

  if (!result.success) {
    return { errors: result.error.flatten().fieldErrors }
  }

  const supabase = createServiceClient()
  const { error } = await supabase
    .from('programs')
    .update({ ...result.data, updated_at: new Date().toISOString() })
    .eq('id', programId)

  if (error) {
    return { errors: { title: ['Failed to update program. Please try again.'] } }
  }

  revalidatePath('/programs')
  revalidatePath(`/programs/${programId}`)
  return { success: true }
}

export async function deleteProgram(programId: string): Promise<void> {
  const supabase = createServiceClient()
  await supabase.from('programs').delete().eq('id', programId)

  revalidatePath('/programs')
  redirect('/programs')
}

export async function publishProgram(programId: string): Promise<void> {
  const supabase = createServiceClient()
  await supabase
    .from('programs')
    .update({
      published: true,
      published_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', programId)

  revalidatePath('/programs')
  revalidatePath(`/programs/${programId}`)
}

export async function unpublishProgram(programId: string): Promise<void> {
  const supabase = createServiceClient()
  await supabase
    .from('programs')
    .update({
      published: false,
      published_at: null,
      updated_at: new Date().toISOString(),
    })
    .eq('id', programId)

  revalidatePath('/programs')
  revalidatePath(`/programs/${programId}`)
}

export async function uploadThumbnail(
  programId: string,
  formData: FormData
): Promise<{ success?: boolean; path?: string; error?: string }> {
  const file = formData.get('file') as File | null

  if (!file) {
    return { error: 'No file provided' }
  }

  if (!file.type.startsWith('image/')) {
    return { error: 'File must be an image' }
  }

  const supabase = createServiceClient()
  const path = `thumbnails/${programId}/${file.name}`

  const { error: uploadError } = await supabase.storage
    .from('program-assets')
    .upload(path, file, { upsert: true })

  if (uploadError) {
    return { error: 'Failed to upload image' }
  }

  const { error: updateError } = await supabase
    .from('programs')
    .update({ thumbnail_url: path, updated_at: new Date().toISOString() })
    .eq('id', programId)

  if (updateError) {
    return { error: 'Failed to update program thumbnail' }
  }

  revalidatePath(`/programs/${programId}`)
  return { success: true, path }
}

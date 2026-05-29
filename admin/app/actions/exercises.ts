'use server'

import { revalidatePath } from 'next/cache'
import { z } from 'zod'
import { createServiceClient } from '@/lib/supabase/service'

const ExerciseSchema = z
  .object({
    display_order: z.coerce.number().int().positive(),
    title: z.string().min(1, 'Title is required').max(100),
    cue_text: z.string().optional().default(''),
    rep_count: z.coerce.number().int().positive().nullable().optional(),
    duration_seconds: z.coerce.number().int().positive().nullable().optional(),
  })
  .refine((data) => data.rep_count || data.duration_seconds, {
    message: 'Either rep_count or duration_seconds must be set',
  })

export async function createExercise(
  sessionId: string,
  programId: string,
  prevState: unknown,
  formData: FormData
): Promise<{ errors?: Record<string, string[] | string>; success?: boolean; exerciseId?: string }> {
  const raw = Object.fromEntries(formData)

  // Convert empty string numeric fields to null so Zod handles optional correctly
  if (raw.rep_count === '') raw.rep_count = undefined as unknown as string
  if (raw.duration_seconds === '') raw.duration_seconds = undefined as unknown as string

  const result = ExerciseSchema.safeParse(raw)

  if (!result.success) {
    const fieldErrors = result.error.flatten().fieldErrors
    const formErrors = result.error.flatten().formErrors
    return {
      errors: {
        ...fieldErrors,
        ...(formErrors.length > 0 ? { _form: formErrors[0] } : {}),
      },
    }
  }

  const { rep_count, duration_seconds, ...rest } = result.data

  // Mutual exclusion: if rep_count set, clear duration_seconds and vice versa
  const insertData = {
    ...rest,
    session_id: sessionId,
    rep_count: rep_count ?? null,
    duration_seconds: rep_count ? null : (duration_seconds ?? null),
  }

  const supabase = createServiceClient()
  const { data, error } = await supabase
    .from('exercises')
    .insert(insertData)
    .select('id')
    .single()

  if (error || !data) {
    return { errors: { title: ['Failed to create exercise. Please try again.'] } }
  }

  revalidatePath(`/programs/${programId}/sessions/${sessionId}`)
  return { success: true, exerciseId: data.id }
}

export async function updateExercise(
  exerciseId: string,
  sessionId: string,
  programId: string,
  prevState: unknown,
  formData: FormData
): Promise<{ errors?: Record<string, string[] | string>; success?: boolean }> {
  const raw = Object.fromEntries(formData)

  if (raw.rep_count === '') raw.rep_count = undefined as unknown as string
  if (raw.duration_seconds === '') raw.duration_seconds = undefined as unknown as string

  const result = ExerciseSchema.safeParse(raw)

  if (!result.success) {
    const fieldErrors = result.error.flatten().fieldErrors
    const formErrors = result.error.flatten().formErrors
    return {
      errors: {
        ...fieldErrors,
        ...(formErrors.length > 0 ? { _form: formErrors[0] } : {}),
      },
    }
  }

  const { rep_count, duration_seconds, ...rest } = result.data

  const updateData = {
    ...rest,
    rep_count: rep_count ?? null,
    duration_seconds: rep_count ? null : (duration_seconds ?? null),
    updated_at: new Date().toISOString(),
  }

  const supabase = createServiceClient()
  const { error } = await supabase
    .from('exercises')
    .update(updateData)
    .eq('id', exerciseId)

  if (error) {
    return { errors: { title: ['Failed to update exercise. Please try again.'] } }
  }

  revalidatePath(`/programs/${programId}/sessions/${sessionId}/exercises/${exerciseId}`)
  return { success: true }
}

export async function updateExerciseVideo(
  exerciseId: string,
  muxAssetId: string,
  programId: string,
  sessionId: string
): Promise<{ success?: boolean; error?: string }> {
  const supabase = createServiceClient()

  // Fetch current exercise to get current video_version
  const { data: exercise, error: fetchError } = await supabase
    .from('exercises')
    .select('video_version')
    .eq('id', exerciseId)
    .single()

  if (fetchError || !exercise) {
    return { error: 'Exercise not found' }
  }

  const currentVersion = (exercise.video_version as number) ?? 1

  const { error } = await supabase
    .from('exercises')
    .update({
      mux_asset_id: muxAssetId,
      mux_playback_id: null,
      video_version: currentVersion + 1,
      updated_at: new Date().toISOString(),
    })
    .eq('id', exerciseId)

  if (error) {
    return { error: 'Failed to update exercise video' }
  }

  revalidatePath(`/programs/${programId}/sessions/${sessionId}/exercises/${exerciseId}`)
  return { success: true }
}

export async function uploadAsset(
  formData: FormData
): Promise<{ path?: string; error?: string }> {
  const file = formData.get('file') as File | null
  const type = formData.get('type') as string | null
  const programId = formData.get('programId') as string | null
  const exerciseId = formData.get('exerciseId') as string | null

  if (!file || !type || !programId || !exerciseId) {
    return { error: 'Missing required fields' }
  }

  const supabase = createServiceClient()
  const path = `${type}/${programId}/${exerciseId}/${file.name}`

  const { error: uploadError } = await supabase.storage
    .from('program-assets')
    .upload(path, file, { upsert: true })

  if (uploadError) {
    return { error: 'Failed to upload asset' }
  }

  if (type === 'glb') {
    const { error: updateError } = await supabase
      .from('exercises')
      .update({ model_asset_url: path, updated_at: new Date().toISOString() })
      .eq('id', exerciseId)

    if (updateError) {
      return { error: 'Failed to update exercise model asset' }
    }
  } else if (type === 'thumbnail') {
    const { error: updateError } = await supabase
      .from('programs')
      .update({ thumbnail_url: path, updated_at: new Date().toISOString() })
      .eq('id', programId)

    if (updateError) {
      return { error: 'Failed to update program thumbnail' }
    }
  }

  return { path }
}

export async function deleteExercise(
  exerciseId: string,
  sessionId: string,
  programId: string
): Promise<void> {
  const supabase = createServiceClient()
  await supabase.from('exercises').delete().eq('id', exerciseId)
  revalidatePath(`/programs/${programId}/sessions/${sessionId}`)
}

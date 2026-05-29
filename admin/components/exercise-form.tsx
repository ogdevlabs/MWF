'use client'

import { useActionState, useState } from 'react'
import { VideoUploader } from '@/components/video-uploader'
import { GlbUploader } from '@/components/glb-uploader'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { updateExerciseVideo } from '@/app/actions/exercises'

interface ExerciseData {
  id: string
  display_order: number
  title: string
  cue_text: string | null
  mux_asset_id: string | null
  mux_playback_id: string | null
  model_asset_url: string | null
  rep_count: number | null
  duration_seconds: number | null
}

interface ExerciseFormState {
  errors?: Record<string, string[] | string>
  success?: boolean
  exerciseId?: string
}

type ServerAction = (
  prevState: unknown,
  formData: FormData
) => Promise<ExerciseFormState>

interface ExerciseFormProps {
  exercise?: ExerciseData
  sessionId: string
  programId: string
  action: ServerAction
}

type ExerciseType = 'rep' | 'time'

export function ExerciseForm({ exercise, sessionId, programId, action }: ExerciseFormProps) {
  const [state, formAction, pending] = useActionState(action, undefined)

  // Determine initial exercise type from existing data
  const initialType: ExerciseType =
    exercise?.duration_seconds ? 'time' : 'rep'
  const [exerciseType, setExerciseType] = useState<ExerciseType>(initialType)

  // Track current asset IDs (can update after upload without refetch)
  const [currentAssetId, setCurrentAssetId] = useState(exercise?.mux_asset_id ?? null)
  const [currentModelPath, setCurrentModelPath] = useState(exercise?.model_asset_url ?? null)

  async function handleVideoUploadComplete(uploadId: string) {
    if (!exercise) return
    await updateExerciseVideo(exercise.id, uploadId, programId, sessionId)
    setCurrentAssetId(uploadId)
  }

  const formError =
    state?.errors?._form && typeof state.errors._form === 'string'
      ? state.errors._form
      : Array.isArray(state?.errors?._form)
        ? (state.errors._form as string[])[0]
        : null

  return (
    <form action={formAction} className="space-y-6 max-w-2xl">
      {/* Display order */}
      <div className="space-y-1">
        <Label htmlFor="display_order">Display Order</Label>
        <Input
          id="display_order"
          name="display_order"
          type="number"
          min={1}
          defaultValue={exercise?.display_order ?? 1}
          required
        />
        {state?.errors?.display_order && (
          <p className="text-sm text-red-600">
            {Array.isArray(state.errors.display_order)
              ? state.errors.display_order[0]
              : state.errors.display_order}
          </p>
        )}
      </div>

      {/* Title */}
      <div className="space-y-1">
        <Label htmlFor="title">Title</Label>
        <Input
          id="title"
          name="title"
          defaultValue={exercise?.title ?? ''}
          required
          maxLength={100}
          placeholder="e.g. Hundred"
        />
        {state?.errors?.title && (
          <p className="text-sm text-red-600">
            {Array.isArray(state.errors.title)
              ? state.errors.title[0]
              : state.errors.title}
          </p>
        )}
      </div>

      {/* Cue text */}
      <div className="space-y-1">
        <Label htmlFor="cue_text">Cue Text</Label>
        <Textarea
          id="cue_text"
          name="cue_text"
          defaultValue={exercise?.cue_text ?? ''}
          rows={3}
          placeholder="Written instructions shown during exercise..."
        />
      </div>

      {/* Exercise type toggle */}
      <div className="space-y-2">
        <Label>Exercise Type</Label>
        <div className="flex gap-4">
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="radio"
              name="_exerciseType"
              value="rep"
              checked={exerciseType === 'rep'}
              onChange={() => setExerciseType('rep')}
              className="accent-slate-900"
            />
            <span className="text-sm">Rep-based</span>
          </label>
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="radio"
              name="_exerciseType"
              value="time"
              checked={exerciseType === 'time'}
              onChange={() => setExerciseType('time')}
              className="accent-slate-900"
            />
            <span className="text-sm">Time-based</span>
          </label>
        </div>
      </div>

      {/* Rep count (only for rep-based) */}
      {exerciseType === 'rep' && (
        <div className="space-y-1">
          <Label htmlFor="rep_count">Rep Count</Label>
          <Input
            id="rep_count"
            name="rep_count"
            type="number"
            min={1}
            defaultValue={exercise?.rep_count ?? ''}
            placeholder="e.g. 10"
          />
          {state?.errors?.rep_count && (
            <p className="text-sm text-red-600">
              {Array.isArray(state.errors.rep_count)
                ? state.errors.rep_count[0]
                : state.errors.rep_count}
            </p>
          )}
        </div>
      )}

      {/* Duration seconds (only for time-based) */}
      {exerciseType === 'time' && (
        <div className="space-y-1">
          <Label htmlFor="duration_seconds">Duration (seconds)</Label>
          <Input
            id="duration_seconds"
            name="duration_seconds"
            type="number"
            min={1}
            defaultValue={exercise?.duration_seconds ?? ''}
            placeholder="e.g. 60"
          />
          {state?.errors?.duration_seconds && (
            <p className="text-sm text-red-600">
              {Array.isArray(state.errors.duration_seconds)
                ? state.errors.duration_seconds[0]
                : state.errors.duration_seconds}
            </p>
          )}
        </div>
      )}

      {formError && (
        <p className="text-sm text-red-600">{formError}</p>
      )}

      <Button type="submit" disabled={pending}>
        {pending ? 'Saving...' : exercise ? 'Save Changes' : 'Create Exercise'}
      </Button>

      {/* Video and GLB uploaders — only shown when exercise already exists */}
      {exercise && (
        <div className="pt-6 border-t space-y-6">
          <VideoUploader
            currentAssetId={currentAssetId}
            onUploadComplete={handleVideoUploadComplete}
          />
          <GlbUploader
            exerciseId={exercise.id}
            programId={programId}
            currentPath={currentModelPath}
            onUploadComplete={(path) => setCurrentModelPath(path)}
          />
        </div>
      )}
    </form>
  )
}

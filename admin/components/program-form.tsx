'use client'

import { useActionState } from 'react'
import { ThumbnailUploader } from '@/components/thumbnail-uploader'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'

interface Program {
  id: string
  title: string
  description: string | null
  difficulty: string
  duration_weeks: number
  thumbnail_url: string | null
}

interface ProgramFormState {
  errors?: Record<string, string[]>
  success?: boolean
}

interface ProgramFormProps {
  program?: Program
  action: (prevState: unknown, formData: FormData) => Promise<ProgramFormState>
}

export function ProgramForm({ program, action }: ProgramFormProps) {
  const [state, formAction, pending] = useActionState(action, undefined)

  return (
    <form action={formAction} className="space-y-4 max-w-2xl">
      {/* Title */}
      <div className="space-y-1">
        <Label htmlFor="title">Title</Label>
        <Input
          id="title"
          name="title"
          defaultValue={program?.title ?? ''}
          required
          maxLength={100}
          placeholder="e.g. 8-Week Beginner Pilates"
        />
        {state?.errors?.title && (
          <p className="text-sm text-red-600">{state.errors.title[0]}</p>
        )}
      </div>

      {/* Description */}
      <div className="space-y-1">
        <Label htmlFor="description">Description</Label>
        <Textarea
          id="description"
          name="description"
          defaultValue={program?.description ?? ''}
          rows={4}
          placeholder="Describe what students will achieve..."
        />
        {state?.errors?.description && (
          <p className="text-sm text-red-600">{state.errors.description[0]}</p>
        )}
      </div>

      {/* Difficulty */}
      <div className="space-y-1">
        <Label htmlFor="difficulty">Difficulty</Label>
        <Select name="difficulty" defaultValue={program?.difficulty ?? 'beginner'}>
          <SelectTrigger id="difficulty">
            <SelectValue placeholder="Select difficulty" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="beginner">Beginner</SelectItem>
            <SelectItem value="intermediate">Intermediate</SelectItem>
            <SelectItem value="advanced">Advanced</SelectItem>
          </SelectContent>
        </Select>
        {state?.errors?.difficulty && (
          <p className="text-sm text-red-600">{state.errors.difficulty[0]}</p>
        )}
      </div>

      {/* Duration weeks */}
      <div className="space-y-1">
        <Label htmlFor="duration_weeks">Duration (weeks)</Label>
        <Input
          id="duration_weeks"
          name="duration_weeks"
          type="number"
          min={1}
          max={52}
          defaultValue={program?.duration_weeks ?? 4}
          required
        />
        {state?.errors?.duration_weeks && (
          <p className="text-sm text-red-600">{state.errors.duration_weeks[0]}</p>
        )}
      </div>

      {/* Hidden thumbnail_url (preserved across edits) */}
      {program?.thumbnail_url && (
        <input type="hidden" name="thumbnail_url" value={program.thumbnail_url} />
      )}

      {/* Thumbnail uploader — only shown in edit mode */}
      {program && (
        <ThumbnailUploader
          programId={program.id}
          currentThumbnailUrl={program.thumbnail_url}
        />
      )}

      <Button type="submit" disabled={pending}>
        {pending ? 'Saving...' : program ? 'Save Changes' : 'Create Program'}
      </Button>
    </form>
  )
}

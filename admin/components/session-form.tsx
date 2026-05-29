'use client'

import { useActionState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'

interface SessionData {
  id: string
  day_number: number
  title: string
  description: string | null
}

interface SessionFormState {
  errors?: Record<string, string[]>
  success?: boolean
}

type ServerAction = (
  prevState: unknown,
  formData: FormData
) => Promise<SessionFormState>

interface SessionFormProps {
  session?: SessionData
  action: ServerAction
}

export function SessionForm({ session, action }: SessionFormProps) {
  const [state, formAction, pending] = useActionState(action, undefined)

  return (
    <form action={formAction} className="space-y-4 max-w-2xl">
      {/* Day number */}
      <div className="space-y-1">
        <Label htmlFor="day_number">Day Number</Label>
        <Input
          id="day_number"
          name="day_number"
          type="number"
          min={1}
          defaultValue={session?.day_number ?? ''}
          required
          placeholder="e.g. 1"
        />
        {state?.errors?.day_number && (
          <p className="text-sm text-red-600">{state.errors.day_number[0]}</p>
        )}
      </div>

      {/* Title */}
      <div className="space-y-1">
        <Label htmlFor="title">Title</Label>
        <Input
          id="title"
          name="title"
          defaultValue={session?.title ?? ''}
          required
          maxLength={100}
          placeholder="e.g. Warm-Up & Core Fundamentals"
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
          defaultValue={session?.description ?? ''}
          rows={3}
          placeholder="Optional session notes..."
        />
      </div>

      <Button type="submit" disabled={pending}>
        {pending ? 'Saving...' : session ? 'Save Changes' : 'Add Session'}
      </Button>
    </form>
  )
}

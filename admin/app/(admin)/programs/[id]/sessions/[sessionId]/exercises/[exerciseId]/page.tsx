import { notFound } from 'next/navigation'
import Link from 'next/link'
import { createServiceClient } from '@/lib/supabase/service'
import { ExerciseForm } from '@/components/exercise-form'
import { Button } from '@/components/ui/button'
import { updateExercise, deleteExercise } from '@/app/actions/exercises'

export const dynamic = 'force-dynamic'

interface PageProps {
  params: Promise<{ id: string; sessionId: string; exerciseId: string }>
}

export default async function ExerciseDetailPage({ params }: PageProps) {
  const { id: programId, sessionId, exerciseId } = await params
  const supabase = createServiceClient()

  const { data: exercise } = await supabase
    .from('exercises')
    .select(
      'id, display_order, title, cue_text, mux_asset_id, mux_playback_id, model_asset_url, rep_count, duration_seconds'
    )
    .eq('id', exerciseId)
    .single()

  if (!exercise) {
    notFound()
  }

  const boundUpdateExercise = updateExercise.bind(null, exerciseId, sessionId, programId)

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <div className="mb-1">
            <Button asChild variant="ghost" size="sm">
              <Link href={`/programs/${programId}/sessions/${sessionId}`}>
                &larr; Back to Session
              </Link>
            </Button>
          </div>
          <h1 className="text-2xl font-bold text-slate-900">Edit Exercise</h1>
        </div>
        <form action={deleteExercise.bind(null, exerciseId, sessionId, programId)}>
          <Button type="submit" variant="destructive" size="sm">
            Delete Exercise
          </Button>
        </form>
      </div>

      <ExerciseForm
        exercise={exercise}
        sessionId={sessionId}
        programId={programId}
        action={boundUpdateExercise}
      />
    </div>
  )
}

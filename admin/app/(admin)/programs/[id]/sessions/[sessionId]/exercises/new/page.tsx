import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { ExerciseForm } from '@/components/exercise-form'
import { createExercise } from '@/app/actions/exercises'

interface PageProps {
  params: Promise<{ id: string; sessionId: string }>
}

export default async function NewExercisePage({ params }: PageProps) {
  const { id: programId, sessionId } = await params
  const action = createExercise.bind(null, sessionId, programId)

  return (
    <div className="p-8 space-y-6">
      <div className="flex items-center gap-4">
        <Button asChild variant="ghost" size="sm">
          <Link href={`/programs/${programId}/sessions/${sessionId}`}>&larr; Back to Session</Link>
        </Button>
        <h1 className="text-2xl font-bold text-slate-900">Add Exercise</h1>
      </div>
      {/* No exercise prop — VideoUploader and GlbUploader are hidden until exercise exists */}
      <ExerciseForm sessionId={sessionId} programId={programId} action={action} />
    </div>
  )
}

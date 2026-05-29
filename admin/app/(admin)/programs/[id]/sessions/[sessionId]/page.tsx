import { notFound } from 'next/navigation'
import Link from 'next/link'
import { createServiceClient } from '@/lib/supabase/service'
import { SessionForm } from '@/components/session-form'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { updateSession, deleteSession } from '@/app/actions/sessions'

export const dynamic = 'force-dynamic'

interface Exercise {
  id: string
  display_order: number
  title: string
  mux_asset_id: string | null
  mux_playback_id: string | null
}

interface PageProps {
  params: Promise<{ id: string; sessionId: string }>
}

function videoStatusBadge(exercise: Exercise) {
  if (exercise.mux_playback_id) {
    return (
      <Badge className="bg-green-100 text-green-800 border-green-200">Ready</Badge>
    )
  }
  if (exercise.mux_asset_id) {
    return (
      <Badge className="bg-yellow-100 text-yellow-800 border-yellow-200">Processing</Badge>
    )
  }
  return <Badge variant="secondary">No video</Badge>
}

export default async function SessionDetailPage({ params }: PageProps) {
  const { id: programId, sessionId } = await params
  const supabase = createServiceClient()

  const [{ data: session }, { data: exercises }] = await Promise.all([
    supabase
      .from('sessions')
      .select('id, day_number, title, description')
      .eq('id', sessionId)
      .single(),
    supabase
      .from('exercises')
      .select('id, display_order, title, mux_asset_id, mux_playback_id')
      .eq('session_id', sessionId)
      .order('display_order'),
  ])

  if (!session) {
    notFound()
  }

  const boundUpdateSession = updateSession.bind(null, programId, sessionId)

  return (
    <div className="p-8 space-y-8">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <div className="flex items-center gap-3 mb-1">
            <Button asChild variant="ghost" size="sm">
              <Link href={`/programs/${programId}`}>&larr; Back to Program</Link>
            </Button>
          </div>
          <h1 className="text-2xl font-bold text-slate-900">
            Day {session.day_number}: {session.title}
          </h1>
        </div>
        <form action={deleteSession.bind(null, programId, sessionId)}>
          <Button type="submit" variant="destructive" size="sm">
            Delete Session
          </Button>
        </form>
      </div>

      {/* Edit session form */}
      <div>
        <h2 className="text-lg font-semibold text-slate-800 mb-4">Session Details</h2>
        <SessionForm session={session} action={boundUpdateSession} />
      </div>

      {/* Exercises */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-slate-800">Exercises</h2>
          <Button asChild variant="outline" size="sm">
            <Link href={`/programs/${programId}/sessions/${sessionId}/exercises/new`}>
              Add Exercise
            </Link>
          </Button>
        </div>

        {!exercises || exercises.length === 0 ? (
          <p className="text-slate-500 text-sm">
            No exercises yet. Add exercises to build out this session.
          </p>
        ) : (
          <div className="border rounded-md overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 border-b">
                <tr>
                  <th className="text-left px-4 py-2 font-medium text-slate-700">Order</th>
                  <th className="text-left px-4 py-2 font-medium text-slate-700">Title</th>
                  <th className="text-left px-4 py-2 font-medium text-slate-700">Video</th>
                  <th className="px-4 py-2"></th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {(exercises as Exercise[]).map((exercise) => (
                  <tr key={exercise.id}>
                    <td className="px-4 py-3 text-slate-600">{exercise.display_order}</td>
                    <td className="px-4 py-3 font-medium text-slate-800">{exercise.title}</td>
                    <td className="px-4 py-3">{videoStatusBadge(exercise)}</td>
                    <td className="px-4 py-3 text-right">
                      <Button asChild variant="ghost" size="sm">
                        <Link
                          href={`/programs/${programId}/sessions/${sessionId}/exercises/${exercise.id}`}
                        >
                          Edit
                        </Link>
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}

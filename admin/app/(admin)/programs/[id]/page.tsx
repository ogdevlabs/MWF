import { notFound } from 'next/navigation'
import Link from 'next/link'
import { createServiceClient } from '@/lib/supabase/service'

export const dynamic = 'force-dynamic'
import { ProgramForm } from '@/components/program-form'
import { DeleteProgramButton } from '@/components/delete-program-button'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  publishProgram,
  unpublishProgram,
  updateProgram,
} from '@/app/actions/programs'

interface Session {
  id: string
  day_number: number
  title: string
}

interface PageProps {
  params: Promise<{ id: string }>
}

export default async function ProgramDetailPage({ params }: PageProps) {
  const { id } = await params
  const supabase = createServiceClient()

  const [{ data: program }, { data: sessions }] = await Promise.all([
    supabase
      .from('programs')
      .select('id, title, description, difficulty, duration_weeks, thumbnail_url, published, published_at')
      .eq('id', id)
      .single(),
    supabase
      .from('sessions')
      .select('id, day_number, title')
      .eq('program_id', id)
      .order('day_number'),
  ])

  if (!program) {
    notFound()
  }

  const boundUpdateProgram = updateProgram.bind(null, program.id)

  return (
    <div className="p-8 space-y-8">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">{program.title}</h1>
          <div className="mt-1">
            {program.published ? (
              <Badge className="bg-green-100 text-green-800 border-green-200">Published</Badge>
            ) : (
              <Badge variant="secondary">Draft</Badge>
            )}
          </div>
        </div>
        <div className="flex items-center gap-2">
          {program.published ? (
            <form action={unpublishProgram.bind(null, program.id)}>
              <Button type="submit" variant="outline" size="sm">
                Unpublish
              </Button>
            </form>
          ) : (
            <form action={publishProgram.bind(null, program.id)}>
              <Button type="submit" size="sm">
                Publish
              </Button>
            </form>
          )}
          <DeleteProgramButton programId={program.id} />
        </div>
      </div>

      {/* Edit form */}
      <div>
        <h2 className="text-lg font-semibold text-slate-800 mb-4">Program Details</h2>
        <ProgramForm program={program} action={boundUpdateProgram} />
      </div>

      {/* Sessions */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-slate-800">Sessions</h2>
          <Button asChild variant="outline" size="sm">
            <Link href={`/programs/${program.id}/sessions/new`}>Add Session</Link>
          </Button>
        </div>

        {!sessions || sessions.length === 0 ? (
          <p className="text-slate-500 text-sm">No sessions yet. Add sessions to build out this program.</p>
        ) : (
          <div className="divide-y border rounded-md">
            {(sessions as Session[]).map((session) => (
              <div key={session.id} className="flex items-center justify-between px-4 py-3">
                <div>
                  <span className="text-sm font-medium text-slate-700">
                    Day {session.day_number}
                  </span>
                  <span className="mx-2 text-slate-300">|</span>
                  <span className="text-sm text-slate-600">{session.title}</span>
                </div>
                <Button asChild variant="ghost" size="sm">
                  <Link href={`/programs/${program.id}/sessions/${session.id}`}>Edit</Link>
                </Button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

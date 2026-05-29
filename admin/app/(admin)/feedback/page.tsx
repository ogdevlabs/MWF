import Link from 'next/link'
import { createServiceClient } from '@/lib/supabase/service'

export const dynamic = 'force-dynamic'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'

export default async function FeedbackPage() {
  const supabase = createServiceClient()

  const { data: threads } = await supabase
    .from('feedback_threads')
    .select(
      '*, students(display_name, email), sessions(title, day_number, programs(title))'
    )
    .order('created_at', { ascending: false })

  const pending = threads?.filter((t) => !t.coach_reply) ?? []
  const replied = threads?.filter((t) => t.coach_reply) ?? []

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-slate-900 mb-6">
        Student Feedback
      </h1>

      {/* Pending threads */}
      <section className="mb-10">
        <h2 className="text-lg font-semibold text-slate-700 mb-3">
          Pending ({pending.length})
        </h2>
        {pending.length === 0 ? (
          <p className="text-slate-500 text-sm">No pending feedback.</p>
        ) : (
          <div className="space-y-3">
            {pending.map((thread) => (
              <FeedbackCard key={thread.id} thread={thread} />
            ))}
          </div>
        )}
      </section>

      {/* Replied threads */}
      <section>
        <h2 className="text-lg font-semibold text-slate-700 mb-3">
          Replied ({replied.length})
        </h2>
        {replied.length === 0 ? (
          <p className="text-slate-500 text-sm">No replied feedback.</p>
        ) : (
          <div className="space-y-3">
            {replied.map((thread) => (
              <FeedbackCard key={thread.id} thread={thread} />
            ))}
          </div>
        )}
      </section>
    </div>
  )
}

function FeedbackCard({ thread }: { thread: any }) {
  const student = thread.students
  const session = thread.sessions
  const program = session?.programs

  const isReplied = !!thread.coach_reply
  const messagePreview =
    thread.student_message?.slice(0, 100) +
    (thread.student_message?.length > 100 ? '…' : '')

  return (
    <Link href={`/feedback/${thread.id}`}>
      <Card className="hover:shadow-md transition-shadow cursor-pointer">
        <CardHeader className="pb-2">
          <div className="flex items-start justify-between gap-2">
            <CardTitle className="text-base">
              {student?.display_name ?? student?.email ?? 'Unknown student'}
            </CardTitle>
            <Badge
              variant={isReplied ? 'default' : 'outline'}
              className={
                isReplied
                  ? 'bg-green-100 text-green-800 border-green-200'
                  : 'bg-yellow-100 text-yellow-800 border-yellow-200'
              }
            >
              {isReplied ? 'Replied' : 'Pending'}
            </Badge>
          </div>
          <CardDescription>
            {program?.title}
            {session ? ` › Day ${session.day_number}: ${session.title}` : ''}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-slate-600">{messagePreview}</p>
        </CardContent>
      </Card>
    </Link>
  )
}

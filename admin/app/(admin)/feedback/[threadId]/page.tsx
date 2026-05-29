import { notFound } from 'next/navigation'
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
import { FeedbackReplyForm } from '@/components/feedback-reply-form'

interface Props {
  params: Promise<{ threadId: string }>
}

export default async function ThreadDetailPage({ params }: Props) {
  const { threadId } = await params
  const supabase = createServiceClient()

  const { data: thread } = await supabase
    .from('feedback_threads')
    .select(
      '*, students(display_name, email), sessions(title, day_number, programs(title))'
    )
    .eq('id', threadId)
    .single()

  if (!thread) {
    notFound()
  }

  const student = thread.students
  const session = thread.sessions
  const program = session?.programs
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL ?? ''

  return (
    <div className="p-8 max-w-3xl">
      {/* Back link */}
      <Link
        href="/feedback"
        className="text-sm text-slate-500 hover:text-slate-800 mb-6 inline-block"
      >
        ← Back to feedback
      </Link>

      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center gap-3 mb-1">
          <h1 className="text-2xl font-bold text-slate-900">
            {student?.display_name ?? student?.email ?? 'Unknown student'}
          </h1>
          <Badge
            variant={thread.coach_reply ? 'default' : 'outline'}
            className={
              thread.coach_reply
                ? 'bg-green-100 text-green-800 border-green-200'
                : 'bg-yellow-100 text-yellow-800 border-yellow-200'
            }
          >
            {thread.coach_reply ? 'Replied' : 'Pending'}
          </Badge>
        </div>
        {session && (
          <p className="text-slate-500 text-sm">
            {program?.title} › Day {session.day_number}: {session.title}
          </p>
        )}
      </div>

      {/* Student message */}
      <Card className="mb-4">
        <CardHeader className="pb-2">
          <CardTitle className="text-sm font-semibold text-slate-500 uppercase tracking-wide">
            Student message
          </CardTitle>
          <CardDescription>
            {new Date(thread.created_at).toLocaleString()}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-slate-800 whitespace-pre-wrap">
            {thread.student_message}
          </p>
        </CardContent>
      </Card>

      {/* Attached photo */}
      {thread.photo_url && (
        <Card className="mb-4">
          <CardContent className="pt-4">
            {/* eslint-disable-next-line @next/next-eslint-plugin/no-img-element */}
            <img
              src={`${supabaseUrl}/storage/v1/object/public/feedback-photos/${thread.photo_url}`}
              alt="Student feedback photo"
              className="max-w-sm rounded-md"
            />
          </CardContent>
        </Card>
      )}

      {/* Coach reply (already exists) */}
      {thread.coach_reply ? (
        <Card className="mb-4 border-green-200 bg-green-50">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-semibold text-green-700 uppercase tracking-wide">
              Your reply
            </CardTitle>
            <CardDescription>
              {thread.replied_at
                ? new Date(thread.replied_at).toLocaleString()
                : ''}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-slate-800 whitespace-pre-wrap">
              {thread.coach_reply}
            </p>
          </CardContent>
        </Card>
      ) : (
        /* Reply form (no reply yet) */
        <div className="mt-6">
          <h2 className="text-lg font-semibold text-slate-800 mb-3">
            Post a reply
          </h2>
          <FeedbackReplyForm threadId={threadId} />
        </div>
      )}
    </div>
  )
}

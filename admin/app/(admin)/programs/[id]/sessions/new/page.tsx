import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { SessionForm } from '@/components/session-form'
import { createSession } from '@/app/actions/sessions'

interface PageProps {
  params: Promise<{ id: string }>
}

export default async function NewSessionPage({ params }: PageProps) {
  const { id: programId } = await params
  const action = createSession.bind(null, programId)

  return (
    <div className="p-8 space-y-6">
      <div className="flex items-center gap-4">
        <Button asChild variant="ghost" size="sm">
          <Link href={`/programs/${programId}`}>&larr; Back to Program</Link>
        </Button>
        <h1 className="text-2xl font-bold text-slate-900">Add Session</h1>
      </div>
      <SessionForm action={action} />
    </div>
  )
}

import Link from 'next/link'
import { createServiceClient } from '@/lib/supabase/service'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'

export const dynamic = 'force-dynamic'

export default async function DashboardPage() {
  const supabase = createServiceClient()

  const [
    { count: totalPrograms },
    { count: publishedPrograms },
    { count: pendingFeedback },
  ] = await Promise.all([
    supabase
      .from('programs')
      .select('id', { count: 'exact', head: true }),
    supabase
      .from('programs')
      .select('id', { count: 'exact', head: true })
      .eq('published', true),
    supabase
      .from('feedback_threads')
      .select('id', { count: 'exact', head: true })
      .is('coach_reply', null),
  ])

  return (
    <div className="p-8 space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Dashboard</h1>
        <p className="text-sm text-slate-500 mt-1">Welcome back, Coach</p>
      </div>

      {/* Stats cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Total Programs</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold text-slate-900">{totalPrograms ?? 0}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Published</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold text-green-700">{publishedPrograms ?? 0}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Pending Feedback</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-end justify-between">
              <p className="text-3xl font-bold text-amber-600">{pendingFeedback ?? 0}</p>
              <Link
                href="/feedback"
                className="text-xs text-slate-500 hover:text-slate-700 underline underline-offset-2"
              >
                View all
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Quick actions */}
      <div>
        <h2 className="text-lg font-semibold text-slate-800 mb-4">Quick Actions</h2>
        <div className="flex gap-3">
          <Button asChild>
            <Link href="/programs/new">Create Program</Link>
          </Button>
          <Button asChild variant="outline">
            <Link href="/feedback">View Feedback</Link>
          </Button>
        </div>
      </div>
    </div>
  )
}

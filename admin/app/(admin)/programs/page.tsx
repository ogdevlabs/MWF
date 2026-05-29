import Link from 'next/link'
import { createServiceClient } from '@/lib/supabase/service'

export const dynamic = 'force-dynamic'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'

interface Program {
  id: string
  title: string
  difficulty: string
  duration_weeks: number
  published: boolean
  published_at: string | null
  created_at: string
}

export default async function ProgramsPage() {
  const supabase = createServiceClient()
  const { data: programs } = await supabase
    .from('programs')
    .select('id, title, difficulty, duration_weeks, published, published_at, created_at')
    .order('created_at', { ascending: false })

  const rows = (programs ?? []) as Program[]

  return (
    <div className="p-8 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-slate-900">Programs</h1>
        <Button asChild>
          <Link href="/programs/new">Create Program</Link>
        </Button>
      </div>

      {rows.length === 0 ? (
        <p className="text-slate-500">No programs yet. Create your first program to get started.</p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Title</TableHead>
              <TableHead>Difficulty</TableHead>
              <TableHead>Duration</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {rows.map((program) => (
              <TableRow key={program.id}>
                <TableCell className="font-medium">{program.title}</TableCell>
                <TableCell className="capitalize">{program.difficulty}</TableCell>
                <TableCell>{program.duration_weeks} wks</TableCell>
                <TableCell>
                  {program.published ? (
                    <Badge className="bg-green-100 text-green-800 border-green-200">
                      Published
                    </Badge>
                  ) : (
                    <Badge variant="secondary">Draft</Badge>
                  )}
                </TableCell>
                <TableCell>
                  <Button asChild variant="outline" size="sm">
                    <Link href={`/programs/${program.id}`}>Edit</Link>
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  )
}

import { createProgram } from '@/app/actions/programs'
import { ProgramForm } from '@/components/program-form'

export default function NewProgramPage() {
  return (
    <div className="p-8 space-y-6">
      <h1 className="text-2xl font-bold text-slate-900">Create Program</h1>
      <ProgramForm action={createProgram} />
    </div>
  )
}

import { NavLink } from '@/components/nav-link'

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="flex min-h-screen">
      {/* Sidebar */}
      <aside className="w-64 bg-slate-900 flex flex-col shrink-0">
        <div className="px-4 py-6">
          <h1 className="text-lg font-bold text-white">Move With Fergie</h1>
          <p className="text-xs text-slate-400 mt-1">Coach Admin</p>
        </div>
        <nav className="flex-1 px-2 space-y-1">
          <NavLink href="/programs">Programs</NavLink>
          <NavLink href="/feedback">Feedback</NavLink>
        </nav>
      </aside>

      {/* Main content */}
      <main className="flex-1 bg-slate-50 overflow-auto">
        {children}
      </main>
    </div>
  )
}

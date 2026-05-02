import { Outlet } from 'react-router-dom';
import { Satellite } from 'lucide-react';

export default function AppLayout() {
  return (
    <div className="min-h-screen bg-surface text-text-main flex flex-col font-sans max-w-3xl mx-auto border-x-2 border-neutral">
      <header className="flex items-center justify-between p-4 border-b-2 border-neutral bg-surface">
        <div className="flex items-center gap-2 font-bold text-xl tracking-tight">
          <Satellite size={24} strokeWidth={2.5} className="text-primary" />
          LifeMesh
        </div>
        <div className="font-mono text-xs tracking-widest uppercase font-bold text-neutral px-3 py-1 border-2 border-neutral">
          Demo Mode
        </div>
      </header>
      <main className="flex-1 p-6 flex flex-col gap-6">
        <Outlet />
      </main>
    </div>
  );
}

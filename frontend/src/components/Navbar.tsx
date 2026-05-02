import { Satellite } from 'lucide-react';

export default function Navbar() {
  return (
    <nav className="flex items-center justify-between px-6 md:px-12 py-4 border-b-2 border-neutral bg-surface z-50 sticky top-0">
      <div className="flex items-center gap-2 font-bold text-3xl tracking-tight text-neutral">
        <Satellite size={32} strokeWidth={2.5} className="text-primary" />
        NOMADIA
      </div>
      <div className="hidden md:flex space-x-12 font-mono text-sm font-bold tracking-widest uppercase text-neutral">
        <a href="#layers" className="hover:text-primary transition-colors">Architecture</a>
        <a href="#problem" className="hover:text-primary transition-colors">Thesis</a>
        <a href="#flow" className="hover:text-primary transition-colors">Logistics</a>
      </div>
      <button onClick={() => window.location.href='/app'} className="bg-neutral text-surface px-8 py-3 font-mono font-bold tracking-widest uppercase hover:bg-primary transition-colors text-sm border-2 border-neutral">
        Deploy
      </button>
    </nav>
  );
}

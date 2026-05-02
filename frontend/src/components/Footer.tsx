import { Satellite } from 'lucide-react';

export default function Footer() {
  return (
    <footer className="bg-surface border-t-2 border-neutral p-6 md:p-12 border-b-2">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-8 border-b-2 border-neutral pb-12 mb-8">
        <div>
          <div className="flex items-center gap-2 font-bold text-3xl tracking-tight text-neutral mb-4">
            <Satellite size={32} strokeWidth={2.5} className="text-primary" />
            NOMADIA
          </div>
          <p className="font-mono text-sm tracking-wide font-bold uppercase max-w-sm text-text-muted">
            Turning isolated communities from the last mile into the first line of survival.
          </p>
        </div>
        <div className="grid grid-cols-2 gap-12 font-mono text-sm font-bold tracking-widest uppercase">
          <div className="flex flex-col gap-4">
            <a href="#" className="hover:text-primary transition-colors">Manifesto</a>
            <a href="#" className="hover:text-primary transition-colors">Technology</a>
            <a href="#" className="hover:text-primary transition-colors">Pilot Data</a>
          </div>
          <div className="flex flex-col gap-4">
            <a href="#" className="hover:text-primary transition-colors">Partners</a>
            <a href="#" className="hover:text-primary transition-colors">Careers</a>
            <a href="#" className="hover:text-primary transition-colors">Contact</a>
          </div>
        </div>
      </div>
      <div className="flex flex-col md:flex-row justify-between text-xs font-mono text-text-muted font-bold uppercase tracking-widest">
        <span>© 2026 Nomadia Systems</span>
        <span>Built for Resilience</span>
      </div>
    </footer>
  );
}

import { AlertTriangle, Lock } from 'lucide-react';

export default function Problem() {
  return (
    <section id="problem" className="flex flex-col lg:flex-row border-b-2 border-neutral">
      <div className="lg:w-1/3 bg-neutral text-surface px-6 md:px-12 py-16 lg:py-24 border-b-2 lg:border-b-0 lg:border-r-2 border-neutral">
        <h2 className="text-5xl font-black leading-none mb-8">
          THE <br/> PROBLEM
        </h2>
        <p className="text-xl font-medium text-surface/80 leading-relaxed">
          Remote regions — mountain villages, islands, disaster zones, and conflict territories — fall into total deprivation when infrastructure collapses.
        </p>
      </div>

      <div className="lg:w-2/3 grid grid-cols-1 md:grid-cols-2">
        <div className="p-8 md:p-12 border-b-2 md:border-b-0 md:border-r-2 border-neutral">
          <AlertTriangle className="text-primary mb-6" size={48} strokeWidth={1.5} />
          <h3 className="text-2xl font-bold tracking-tight mb-4">Total Dependency</h3>
          <p className="font-medium text-text-muted text-lg">
            Complete reliance on roads and global supply chains means food and medicine disappear the moment connections are severed. No roads = no access.
          </p>
        </div>
        <div className="p-8 md:p-12">
          <Lock className="text-neutral mb-6" size={48} strokeWidth={1.5} />
          <h3 className="text-2xl font-bold tracking-tight mb-4">The Insight</h3>
          <div className="bg-primary/10 border-l-4 border-primary p-6">
             <p className="font-bold text-xl text-primary mb-2">No single solution works alone.</p>
             <ul className="space-y-2 font-mono text-sm tracking-wide text-neutral">
               <li>→ Drones don't carry bulk food.</li>
               <li>→ Central warehouses lack speed.</li>
               <li>→ Pure data doesn't deliver cargo.</li>
             </ul>
          </div>
        </div>
      </div>
    </section>
  );
}

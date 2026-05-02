import { Terminal } from 'lucide-react';

export default function SystemFlow() {
  return (
    <section id="flow" className="flex flex-col lg:flex-row border-b-2 border-neutral bg-surface">
      <div className="lg:w-1/2 p-6 md:p-12 border-b-2 lg:border-b-0 lg:border-r-2 border-neutral">
         <h2 className="text-4xl md:text-5xl font-black uppercase tracking-tight mb-8">Scenario 72H:<br/> Complete Isolation</h2>
         
         <div className="space-y-10">
           <div className="relative pl-8 border-l-4 border-primary">
             <h4 className="font-mono font-bold tracking-widest text-sm uppercase text-text-muted mb-2">T-MINUS 12H — BEFORE</h4>
             <p className="text-xl font-bold">Predictive deployment. Pods are restocked proactively based on catastrophe forecasting. Systems armed.</p>
           </div>
           <div className="relative pl-8 border-l-4 border-neutral">
             <h4 className="font-mono font-bold tracking-widest text-sm uppercase text-text-muted mb-2">T-ZERO — DURING</h4>
             <p className="text-xl font-bold">Local markets activated via Aid Credits. Reserves from LifePods accessed locally. Drones dispatched ONLY for acute medical emergencies.</p>
           </div>
           <div className="relative pl-8 border-l-4 border-neutral">
             <h4 className="font-mono font-bold tracking-widest text-sm uppercase text-text-muted mb-2">T-PLUS 72H — AFTER</h4>
             <p className="text-xl font-bold">Supply lines restored. Inventory data synchronized. Local providers automatically compensated.</p>
           </div>
         </div>
      </div>
      <div className="lg:w-1/2 bg-neutral text-surface p-6 md:p-12 flex flex-col">
         <div className="flex items-center gap-4 mb-8 text-primary border-b-2 border-primary pb-4">
           <Terminal size={24} />
           <span className="font-mono font-bold tracking-widest text-sm uppercase">Nomadia.CLI — Active</span>
         </div>
         <div className="font-mono text-sm leading-relaxed text-surface/80 space-y-4">
           <p><span className="text-primary">&gt;</span> scanning local_nodes...</p>
           <p><span className="text-primary">&gt;</span> 3 suppliers detected. transmitting aid_credits...</p>
           <p><span className="text-primary">&gt;</span> WARNING: cold_chain_vaccines critical.</p>
           <p><span className="text-primary">&gt;</span> initializing LifePod_04. solar_status: OK.</p>
           <p className="animate-pulse"><span className="text-primary">&gt;</span> waiting for drone clearance...</p>
         </div>
         <div className="mt-auto pt-12">
            <h3 className="text-2xl font-bold mb-4 line-through decoration-primary decoration-4">Not a Delivery System</h3>
            <h3 className="text-4xl font-black text-primary">A SURVIVAL INFRASTRUCTURE.</h3>
         </div>
      </div>
    </section>
  );
}

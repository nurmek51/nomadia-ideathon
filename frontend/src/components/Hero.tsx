import { Crosshair } from 'lucide-react';

export default function Hero() {
  return (
    <section className="flex flex-col lg:flex-row border-b-2 border-neutral">
      <div className="lg:w-2/3 px-6 md:px-12 py-20 lg:py-32 border-b-2 lg:border-b-0 lg:border-r-2 border-neutral flex flex-col justify-center">
        <div className="font-mono text-primary font-bold tracking-widest text-sm uppercase mb-6 flex items-center gap-2">
          <Crosshair size={18} /> Network Zero
        </div>
        <h1 className="text-6xl md:text-8xl font-black leading-[0.9] tracking-tight mb-8">
          The First Line <br className="hidden md:block"/> Of Survival.
        </h1>
        <p className="text-xl md:text-3xl font-medium max-w-3xl leading-snug mb-12">
          An autonomous survival network for isolated regions. Activating local resources, deploying scalable pods, and connecting the last mile when minutes matter.
        </p>
        <div className="flex flex-col sm:flex-row gap-4">
          <button className="bg-primary text-surface px-10 py-5 font-mono font-bold tracking-widest uppercase border-2 border-primary hover:bg-transparent hover:text-primary transition-colors text-base">
            System Specs
          </button>
          <button className="bg-transparent text-neutral px-10 py-5 font-mono font-bold tracking-widest uppercase hover:bg-neutral hover:text-surface transition-colors text-base border-2 border-neutral">
            Read Whitepaper
          </button>
        </div>
      </div>
      <div className="lg:w-1/3 bg-neutral flex flex-col pt-12 overflow-hidden relative min-h-[400px] lg:min-h-auto">
        <div className="px-8 z-10 relative space-y-8">
           <div className="bg-surface p-6 border-b-4 border-r-4 border-l-2 border-t-2 border-surface/50 border-r-primary border-b-primary shadow-[8px_8px_0_0_#d85c41]">
             <div className="font-mono text-neutral font-bold tracking-widest text-xs uppercase mb-2">Status</div>
             <div className="text-3xl font-black text-neutral tracking-tight">SYSTEM ONLINE</div>
           </div>
           <div className="bg-surface p-6 border-b-4 border-r-4 border-l-2 border-t-2 border-surface/50 border-r-primary border-b-primary shadow-[8px_8px_0_0_#d85c41]">
             <div className="font-mono text-neutral font-bold tracking-widest text-xs uppercase mb-2">Coverage</div>
             <div className="text-3xl font-black text-neutral tracking-tight">ISOLATED ZONES</div>
           </div>
        </div>
        
        {/* Decorative Grid Background pattern for Brutalist feel */}
        <div className="absolute inset-0 opacity-10 pointer-events-none" style={{
           backgroundImage: 'linear-gradient(#f3efe6 1px, transparent 1px), linear-gradient(90deg, #f3efe6 1px, transparent 1px)',
           backgroundSize: '40px 40px'
         }}>
        </div>
      </div>
    </section>
  );
}

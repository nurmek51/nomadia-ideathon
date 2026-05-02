import { Store, Box, Plane } from 'lucide-react';

const layers = [
  {
    num: "01",
    title: "LOCAL",
    subtitle: "RescueMarket",
    icon: <Store size={40} className="text-primary group-hover:text-surface transition-colors" />,
    desc: "Activates local resources (shops, farmers) first. Community buys with aid credits; suppliers are compensated digitally.",
    stats: "Immediate Action • Local Economy"
  },
  {
    num: "02",
    title: "PODS",
    subtitle: "LifePods",
    icon: <Box size={40} className="text-primary group-hover:text-surface transition-colors" />,
    desc: "Pre-positioned autonomous micro-warehouses holding 7-14 days of food, water filters, and solar-cooled vaccines.",
    stats: "Cold Chain • Medium Term Intervention"
  },
  {
    num: "03",
    title: "AIR",
    subtitle: "Medical Drone Line",
    icon: <Plane size={40} className="text-primary group-hover:text-surface transition-colors" />,
    desc: "High-tech air delivery reserved strictly for critical, time-sensitive cargo: blood, insulin, emergency antibiotics.",
    stats: "High Speed • Low Volume"
  }
];

export default function Layers() {
  return (
    <section id="layers" className="border-b-2 border-neutral bg-surface">
      <div className="px-6 md:px-12 py-16 lg:py-24 border-b-2 border-neutral">
         <h2 className="text-5xl md:text-7xl font-black uppercase tracking-tight">System Architecture</h2>
         <p className="text-2xl font-medium mt-4 max-w-2xl text-text-muted">
           A three-layered modular structure that utilizes progressive escalation—local assets first, advanced technology last.
         </p>
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-3">
        {layers.map((layer, idx) => (
           <div key={idx} className={`group p-8 md:p-12 border-b-2 lg:border-b-0 ${idx !== 2 ? 'lg:border-r-2' : ''} border-neutral hover:bg-neutral hover:text-surface transition-colors cursor-default`}>
              <div className="flex justify-between items-start mb-12">
                 <div className="font-mono text-4xl font-bold tracking-tighter opacity-50">{layer.num}</div>
                 {layer.icon}
              </div>
              <h3 className="text-4xl font-black mb-2">{layer.title}</h3>
              <div className="font-mono text-primary font-bold tracking-widest text-sm uppercase mb-6">{layer.subtitle}</div>
              <p className="text-lg font-medium leading-relaxed mb-12 opacity-80 group-hover:opacity-100">
                {layer.desc}
              </p>
              <div className="mt-auto text-sm font-mono tracking-widest uppercase border-t-2 border-neutral/20 group-hover:border-surface/30 pt-6">
                {layer.stats}
              </div>
           </div>
        ))}
      </div>
    </section>
  );
}

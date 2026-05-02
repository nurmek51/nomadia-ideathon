import { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { ApiService } from '../api/apiService';
import { Navigation, MapPin } from 'lucide-react';

export default function DeliveryScreen() {
  const location = useLocation();
  const navigate = useNavigate();
  const { delivery } = location.state || {};
  const [complete, setComplete] = useState(false);

  const handleComplete = async () => {
    await ApiService.completeDelivery(delivery.delivery_id);
    setComplete(true);
  };

  if (!delivery) return <div>No Delivery Data</div>;

  if (complete) {
    return (
      <div className="flex flex-col h-full items-center justify-center text-center">
         <div className="bg-success text-surface p-8 rounded-full mb-8">
           <MapPin size={48} />
         </div>
         <h2 className="text-4xl font-black mb-4 uppercase">Доставка завершена</h2>
         <p className="font-mono text-text-muted font-bold tracking-widest uppercase mb-12">Груз успешно передан</p>
         <button 
            onClick={() => navigate('/app/dashboard')}
            className="bg-neutral text-surface px-8 py-4 font-mono font-bold tracking-widest uppercase hover:bg-primary transition-colors text-lg border-2 border-neutral w-full max-w-sm"
          >
            В командный центр
          </button>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full">
      <h1 className="text-3xl font-black mb-8 border-b-2 border-neutral pb-4 tracking-tight uppercase">ДОСТАВКА ЗАПУЩЕНА</h1>
      
      <div className="mb-8 font-mono text-sm font-bold uppercase tracking-widest space-y-4">
        <div className="flex items-center text-success"><span className="w-6 leading-none">✓</span> Заявка создана</div>
        <div className="flex items-center text-success"><span className="w-6 leading-none">✓</span> Приоритет рассчитан</div>
        <div className="flex items-center text-success"><span className="w-6 leading-none">✓</span> Ресурс найден</div>
        <div className="flex items-center text-primary animate-pulse"><span className="w-6 leading-none">►</span> Доставка запущена</div>
        <div className="flex items-center text-neutral opacity-30"><span className="w-6 leading-none">○</span> Доставлено</div>
      </div>

      <div className="border-2 border-neutral bg-surface p-6 mb-8 shadow-[8px_8px_0_0_#191512]">
        <h2 className="text-2xl font-black mb-4 uppercase flex items-center gap-2">
          <Navigation className="text-primary"/> DRONE MEDICAL LINE
        </h2>
        <div className="font-mono text-xs mb-6 uppercase tracking-widest font-bold">
           Аптека Аксу → Горное село
        </div>
        <div className="flex justify-between items-center border-t-2 border-neutral pt-4 font-mono font-bold">
           <div className="flex flex-col">
             <span className="text-xs uppercase text-text-muted">ETA</span>
             <span className="text-2xl text-primary">{delivery.eta_minutes} МИН</span>
           </div>
           <div className="flex flex-col text-right">
             <span className="text-xs uppercase text-text-muted">СТАТУС</span>
             <span className="text-sm">Дрон вылетел</span>
           </div>
        </div>
      </div>

      <div className="flex-1 min-h-[200px] border-2 border-neutral bg-surface/50 relative overflow-hidden mb-8 grid place-items-center">
        {/* Mock Map Background */}
        <div className="absolute inset-0 opacity-10 pointer-events-none" style={{ backgroundImage: 'linear-gradient(#f3efe6 2px, transparent 2px), linear-gradient(90deg, #f3efe6 2px, transparent 2px)', backgroundSize: '20px 20px', backgroundColor: '#d85c41' }}></div>
        <div className="relative z-10 font-mono text-neutral font-bold tracking-widest uppercase bg-surface px-4 py-2 border-2 border-neutral">
          [ КАРТА АКТИВНА ]
        </div>
      </div>

      <div className="mt-auto">
        <button 
          onClick={handleComplete}
          className="w-full bg-neutral text-surface py-4 font-mono font-bold tracking-widest uppercase hover:bg-success transition-colors text-lg border-2 border-neutral"
        >
          Отметить как доставлено
        </button>
      </div>
    </div>
  );
}

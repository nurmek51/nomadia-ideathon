import { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { ApiService } from '../api/apiService';

export default function MatchResultScreen() {
  const location = useLocation();
  const navigate = useNavigate();
  const match = location.state?.match;
  const [loading, setLoading] = useState(false);

  const handleApprove = async () => {
    setLoading(true);
    const delivery = await ApiService.approveDelivery(match.request_id);
    navigate('/app/delivery', { state: { delivery, match } });
  };

  if (!match) return <div>No Match Data</div>;

  return (
    <div className="flex flex-col h-full">
      <h1 className="text-3xl font-black mb-8 border-b-2 border-neutral pb-4 tracking-tight uppercase">РЕСУРС НАЙДЕН</h1>
      
      <div className="border-2 border-success bg-surface p-6 mb-6 shadow-[8px_8px_0_0_#2e7d4f]">
        <h2 className="text-3xl font-black mb-4 text-success">{match.matched_node}</h2>
        <div className="font-mono text-sm space-y-2 font-bold">
           <div className="flex justify-between border-b-2 border-success/20 pb-2"><span>Инсулин доступен:</span> <span>{match.available_units} единиц</span></div>
           <div className="flex justify-between border-b-2 border-success/20 pb-2"><span>Расстояние:</span> <span>{match.distance_km} км</span></div>
           <div className="flex justify-between border-b-2 border-success/20 pb-2"><span>Метод:</span> <span className="text-success uppercase">{match.delivery_type}</span></div>
           <div className="flex justify-between pt-2"><span>ETA:</span> <span>{match.eta_minutes} минут</span></div>
        </div>
      </div>

      <div className="border-2 border-danger bg-surface p-6 mb-8 opacity-80 opacity-70">
        <h2 className="text-xl font-bold mb-2">LifePod — Горное село</h2>
        <div className="font-mono text-sm space-y-1 font-medium">
           <div className="text-danger font-bold uppercase">Инсулин: 0 единиц</div>
           <div>Статус: требуется внешняя доставка</div>
        </div>
      </div>

      <div className="border-l-4 border-neutral pl-4 mb-12">
        <p className="text-lg font-medium leading-relaxed font-sans">{match.reason}</p>
      </div>

      <div className="mt-auto">
        <button 
          onClick={handleApprove}
          disabled={loading}
          className="w-full bg-success text-surface py-4 font-mono font-bold tracking-widest uppercase hover:bg-neutral transition-colors text-lg border-2 border-success hover:border-neutral"
        >
          {loading ? 'ЗАПУСК МИССИИ...' : 'Подтвердить доставку'}
        </button>
      </div>
    </div>
  );
}

import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ApiService } from '../api/apiService';

export default function DispatcherDashboardScreen() {
  const navigate = useNavigate();
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    ApiService.getDashboard().then(setData);
  }, []);

  if (!data) return <div className="font-mono text-sm uppercase tracking-widest font-bold p-4">Loading Data...</div>;

  return (
    <div className="flex flex-col h-full">
      <h1 className="text-3xl font-black mb-8 border-b-2 border-neutral pb-4 uppercase tracking-tighter">Командный Центр</h1>
      
      <div className="grid grid-cols-2 gap-4 mb-8">
        <div className="p-4 border-2 border-primary bg-primary/10">
          <div className="text-3xl font-black text-primary">{data.critical_requests}</div>
          <div className="font-mono text-xs uppercase tracking-widest font-bold text-neutral">Критические заявки</div>
        </div>
        <div className="p-4 border-2 border-neutral bg-surface">
          <div className="text-3xl font-black text-neutral">{data.isolated_villages}</div>
          <div className="font-mono text-xs uppercase tracking-widest font-bold text-neutral">Изолированные сёла</div>
        </div>
        <div className="p-4 border-2 border-neutral bg-surface">
          <div className="text-3xl font-black text-neutral">{data.pending_requests}</div>
          <div className="font-mono text-xs uppercase tracking-widest font-bold text-neutral">Ожидают решения</div>
        </div>
        <div className="p-4 border-2 border-neutral bg-surface">
          <div className="text-3xl font-black text-neutral">{data.active_deliveries}</div>
          <div className="font-mono text-xs uppercase tracking-widest font-bold text-neutral">Активные доставки</div>
        </div>
      </div>

      <div className="border-l-4 border-primary bg-surface p-4 border-2 border-r-neutral border-y-neutral shadow-[4px_4px_0_0_#191512] mb-12">
        <div className="font-mono text-primary text-xs uppercase tracking-widest font-bold mb-2">🔴 Срочная заявка</div>
        <h3 className="text-xl font-bold mb-1">Инсулин нужен пациенту</h3>
        <p className="text-text-muted font-medium text-sm mb-4">Село: Горное село <br/>Статус: Создана</p>
        <button 
          onClick={() => navigate('/app/request/new')}
          className="bg-neutral text-surface px-6 py-2 font-mono font-bold tracking-widest uppercase hover:bg-primary transition-colors text-xs w-full text-center"
        >
          [Открыть заявку]
        </button>
      </div>

      <div className="flex flex-col gap-3 mt-auto">
        <button onClick={() => navigate('/app/request/new')} className="w-full bg-primary text-surface py-3 font-mono font-bold tracking-widest uppercase border-2 border-primary hover:bg-neutral hover:border-neutral transition-colors text-sm">
          Создать заявку
        </button>
        <button className="w-full bg-transparent text-neutral py-3 font-mono font-bold tracking-widest uppercase border-2 border-neutral hover:bg-neutral hover:text-surface transition-colors text-sm">
          Инвентарь LifePod
        </button>
        <button className="w-full text-text-muted py-3 font-mono font-bold tracking-widest uppercase border-b-2 border-transparent hover:border-neutral hover:text-neutral transition-colors text-sm">
          Сбросить демо
        </button>
      </div>
    </div>
  );
}

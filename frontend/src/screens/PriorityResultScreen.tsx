import { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { ApiService } from '../api/apiService';

export default function PriorityResultScreen() {
  const location = useLocation();
  const navigate = useNavigate();
  const priority = location.state?.priority;
  const [loading, setLoading] = useState(false);

  const handleMatch = async () => {
    setLoading(true);
    const match = await ApiService.matchRequest(priority.request_id);
    navigate('/app/request/match', { state: { match } });
  };

  if (!priority) return <div>No Date</div>;

  return (
    <div className="flex flex-col h-full">
      <h1 className="text-3xl font-black mb-8 border-b-2 border-neutral pb-4 tracking-tight uppercase">AI-ПРИОРИТИЗАЦИЯ</h1>
      
      <div className="bg-primary text-surface p-12 flex flex-col items-center justify-center border-2 border-primary mb-8 shadow-[8px_8px_0_0_#191512]">
        <div className="text-7xl font-black tracking-tighter mb-2 leading-none">{priority.priority_score}<span className="text-4xl opacity-50">/100</span></div>
        <div className="font-mono text-base tracking-widest font-bold uppercase">{priority.priority_level} ПРИОРИТЕТ</div>
      </div>

      <div className="border-l-4 border-neutral pl-4 mb-8">
        <p className="text-lg font-medium leading-relaxed font-sans">{priority.ai_summary}</p>
      </div>

      <div className="mb-8">
        <h3 className="font-mono text-xs uppercase tracking-widest font-bold mb-4 text-text-muted">РЕШЕНИЕ ОСНОВАНО НА:</h3>
        <ul className="space-y-3 font-medium">
          {priority.reasons.map((r: string, i: number) => (
            <li key={i} className="flex gap-2">
              <span className="text-primary font-bold">✓</span> {r}
            </li>
          ))}
        </ul>
      </div>

      <div className="mt-auto">
        <button 
          onClick={handleMatch}
          disabled={loading}
          className="w-full bg-neutral text-surface py-4 font-mono font-bold tracking-widest uppercase hover:bg-primary transition-colors text-lg border-2 border-neutral"
        >
          {loading ? 'ПОИСК РЕСУРСОВ...' : 'Найти ближайший ресурс'}
        </button>
      </div>
    </div>
  );
}

import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ApiService } from '../api/apiService';

export default function CreateRequestScreen() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);

  const handleSend = async () => {
    setLoading(true);
    const result = await ApiService.createRequest({});
    if(result.id) {
      const priority = await ApiService.prioritizeRequest(result.id);
      navigate('/app/request/priority', { state: { priority } });
    }
  };

  return (
    <div className="flex flex-col h-full">
      <h1 className="text-3xl font-black mb-6 border-b-2 border-neutral pb-4 tracking-tight">НОВАЯ EMERGENCY-ЗАЯВКА</h1>
      
      <div className="flex flex-col gap-6 font-medium">
        <div>
          <label className="font-mono text-xs uppercase tracking-widest font-bold mb-2 block">Что нужно?</label>
          <div className="flex flex-wrap gap-2">
            <span className="font-mono text-xs font-bold uppercase px-3 py-1 bg-neutral text-surface border-2 border-neutral">[Медицина]</span>
            <span className="font-mono text-xs font-bold uppercase px-3 py-1 border-2 border-neutral opacity-50">[Еда]</span>
            <span className="font-mono text-xs font-bold uppercase px-3 py-1 border-2 border-neutral opacity-50">[Вода]</span>
          </div>
        </div>

        <div>
          <label className="font-mono text-xs uppercase tracking-widest font-bold mb-2 block">Предмет</label>
          <div className="w-full border-2 border-neutral p-3 font-mono text-sm bg-surface">Инсулин</div>
        </div>

        <div>
          <label className="font-mono text-xs uppercase tracking-widest font-bold mb-2 block">Срочность</label>
          <div className="flex flex-wrap gap-2">
            <span className="font-mono text-xs font-bold uppercase px-3 py-1 bg-primary text-surface border-2 border-primary">[Критическая]</span>
            <span className="font-mono text-xs font-bold uppercase px-3 py-1 border-2 border-neutral opacity-50">[Высокая]</span>
          </div>
        </div>

        <div>
          <label className="font-mono text-xs uppercase tracking-widest font-bold mb-2 block">Описание поля и Пациент</label>
          <div className="w-full border-2 border-neutral p-3 font-mono text-sm bg-surface mb-2">Хронический пациент</div>
          <div className="w-full border-2 border-neutral p-3 font-mono text-sm bg-surface">Пациенту срочно нужен инсулин</div>
        </div>

        <div>
          <label className="font-mono text-xs uppercase tracking-widest font-bold mb-2 block">Локация</label>
          <div className="w-full border-2 border-primary text-primary font-bold p-3 font-mono text-sm bg-primary/5">Горное село (Изолировано)</div>
        </div>
      </div>

      <div className="mt-8">
        <button 
          onClick={handleSend}
          disabled={loading}
          className="w-full bg-neutral text-surface py-4 font-mono font-bold tracking-widest uppercase hover:bg-primary transition-colors text-lg border-2 border-neutral disabled:opacity-50"
        >
          {loading ? 'ОБРАБОТКА...' : 'Отправить заявку'}
        </button>
      </div>
    </div>
  );
}

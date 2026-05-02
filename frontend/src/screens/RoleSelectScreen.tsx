import { useNavigate } from 'react-router-dom';

export default function RoleSelectScreen() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col h-full justify-center">
      <div className="mb-12">
        <h1 className="text-4xl font-black tracking-tight mb-2">LifeMesh</h1>
        <p className="font-mono text-text-muted uppercase text-sm tracking-widest font-bold">
          Сеть выживания для изолированных территорий
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-12">
        <div className="p-4 border-2 border-primary bg-primary text-surface cursor-pointer hover:bg-neutral hover:border-neutral transition-colors">
          <h3 className="font-bold text-xl mb-1">Диспетчер</h3>
          <p className="text-sm font-medium">Приоритизация, маршруты и доставка</p>
        </div>
        <div className="p-4 border-2 border-neutral opacity-50 cursor-not-allowed">
          <h3 className="font-bold text-xl mb-1">Медик / рейнджер</h3>
          <p className="text-sm font-medium">Создание заявок</p>
        </div>
        <div className="p-4 border-2 border-neutral opacity-50 cursor-not-allowed">
          <h3 className="font-bold text-xl mb-1">Поставщик</h3>
          <p className="text-sm font-medium">Запасы аптеки, магазина</p>
        </div>
        <div className="p-4 border-2 border-neutral opacity-50 cursor-not-allowed">
          <h3 className="font-bold text-xl mb-1">Житель</h3>
          <p className="text-sm font-medium">Запрос еды, воды</p>
        </div>
      </div>

      <div className="mt-auto">
        <button 
          onClick={() => navigate('/app/dashboard')}
          className="w-full bg-neutral text-surface py-4 font-mono font-bold tracking-widest uppercase hover:bg-primary transition-colors text-lg border-2 border-neutral"
        >
          Начать демо
        </button>
      </div>
    </div>
  );
}

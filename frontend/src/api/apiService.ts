// Mock API based on BACKEND.md requirements
// Since we don't have a reliable running backend just yet, we use async delays to simulate network

export const V_G_VILLAGES = [
  { name: "Горное село", risk_level: "critical", is_isolated: true, lat: 43.24, lng: 76.91 },
  { name: "Аксу", risk_level: "stable", is_isolated: false, lat: 43.31, lng: 77.02 }
];

export const MOCK_INVENTORY = {
  "LifePod — Горное село": {
      type: "lifepod", village: "Горное село",
      items: { insulin: 0, water_kits: 42, food_packs: 120, antibiotics: 5, baby_food: 8 }
  },
  "Аптека Аксу": {
      type: "pharmacy", village: "Аксу",
      items: { insulin: 6, antibiotics: 14, paracetamol: 40 }
  },
  "Магазин Аксу": {
      type: "shop", village: "Аксу",
      items: { food_packs: 280, water_kits: 90, baby_food: 25 }
  }
};

const delay = (ms: number) => new Promise(res => setTimeout(res, ms));

export const ApiService = {
  getDemoState: async () => {
    await delay(300);
    return {
      villages: V_G_VILLAGES,
      inventory: MOCK_INVENTORY,
      requests: [],
      deliveries: []
    };
  },
  
  createRequest: async (body: any) => {
    await delay(500);
    return {
      id: 1,
      ...body,
      status: "created",
      priority_score: null
    };
  },

  prioritizeRequest: async (requestId: number) => {
    await delay(800);
    return {
      request_id: requestId,
      priority_score: 100,
      priority_level: "critical",
      ai_summary: "Заявка критическая: нужен инсулин для пациента с хроническим заболеванием, в локальном LifePod запас отсутствует, село изолировано.",
      reasons: [
        "Критически важная медицинская заявка",
        "Высокая срочность",
        "Пациент из уязвимой группы",
        "В локальном LifePod нет нужного ресурса",
        "Село временно изолировано"
      ],
      recommended_action: "Drone Medical Line"
    };
  },

  matchRequest: async (requestId: number) => {
    await delay(800);
    return {
      request_id: requestId,
      matched_node: "Аптека Аксу",
      available_units: 6,
      delivery_type: "drone",
      eta_minutes: 42,
      distance_km: 12.4,
      reason: "В локальном LifePod нет инсулина. Ближайший доступный запас найден в аптеке Аксу.",
      route: [
        { lat: 43.31, lng: 77.02 },
        { lat: 43.24, lng: 76.91 }
      ]
    };
  },

  approveDelivery: async (requestId: number) => {
    await delay(600);
    return {
      delivery_id: 1,
      request_id: requestId,
      status: "in_delivery",
      delivery_type: "drone",
      eta_minutes: 42,
      current_step: "Дрон вылетел из аптеки Аксу"
    };
  },

  completeDelivery: async (deliveryId: number) => {
    await delay(500);
    return {
      delivery_id: deliveryId,
      request_id: 1,
      status: "delivered",
      message: "Доставка завершена"
    };
  },

  getDashboard: async () => {
    await delay(300);
    return {
      critical_requests: 1,
      pending_requests: 0,
      isolated_villages: 1,
      active_deliveries: 1,
      low_stock_items: [
        { node: "LifePod — Горное село", item: "insulin", quantity: 0 }
      ]
    };
  }
};

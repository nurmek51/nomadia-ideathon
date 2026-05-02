String normalizeStatusCode(String raw) {
  return switch (raw) {
    'создана' => 'created',
    'подтверждена' => 'verified',
    'приоритет рассчитан' => 'prioritized',
    'ресурс найден' => 'matched',
    'поставщик подтвердил' => 'supplier_confirmed',
    'доставка запущена' => 'in_delivery',
    'доставлено' => 'delivered',
    'отклонена' => 'rejected',
    _ => raw,
  };
}

String statusLabel(String raw) {
  return switch (normalizeStatusCode(raw)) {
    'created' => 'создана',
    'verified' => 'подтверждена',
    'prioritized' => 'приоритет рассчитан',
    'matched' => 'ресурс найден',
    'supplier_confirmed' => 'поставщик подтвердил',
    'in_delivery' => 'доставка запущена',
    'delivered' => 'доставлено',
    'rejected' => 'отклонена',
    _ => raw,
  };
}

String priorityLevelLabel(String raw) {
  return switch (raw) {
    'critical' => 'критический',
    'high' => 'высокий',
    'medium' => 'средний',
    'low' => 'низкий',
    'критический' => 'критический',
    'высокий' => 'высокий',
    'средний' => 'средний',
    'низкий' => 'низкий',
    _ => raw,
  };
}

String priorityHeadlineLabel(String raw) {
  return switch (raw) {
    'critical' || 'критический' => 'КРИТИЧЕСКИЙ ПРИОРИТЕТ',
    'high' || 'высокий' => 'ВЫСОКИЙ ПРИОРИТЕТ',
    'medium' || 'средний' => 'СРЕДНИЙ ПРИОРИТЕТ',
    _ => 'НИЗКИЙ ПРИОРИТЕТ',
  };
}

String deliveryTypeLabel(String? raw) {
  return switch (raw) {
    'drone' => 'медицинская доставка дроном',
    'vehicle' => 'наземная доставка',
    'ranger_pickup' => 'выдача через рейнджера',
    'external_supply' => 'внешняя поставка',
    'Медицинская доставка дроном' => 'медицинская доставка дроном',
    'Наземная доставка' => 'наземная доставка',
    'Выдача через рейнджера' => 'выдача через рейнджера',
    'Внешняя поставка' => 'внешняя поставка',
    _ => 'операционная доставка Nomadia',
  };
}

String urgencyLabel(String raw) {
  return switch (raw) {
    'critical' => 'критическая',
    'high' => 'высокая',
    'medium' => 'средняя',
    'low' => 'низкая',
    _ => raw,
  };
}

String vulnerableGroupLabel(String raw) {
  return switch (raw) {
    'child' => 'ребёнок',
    'pregnant' => 'беременная',
    'elderly' => 'пожилой',
    'chronic_patient' => 'хронический пациент',
    'none' => 'нет',
    _ => raw,
  };
}

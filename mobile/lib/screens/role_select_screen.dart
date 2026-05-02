import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../widgets/role_card.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Text('Nomadia', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 12),
            Text(
              'Сеть выживания для изолированных территорий',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            RoleCard(
              title: 'Житель',
              description: 'Запросить еду, воду или медикаменты',
              icon: Icons.home_work_outlined,
              onPressed: () => context.go('/resident'),
            ).animate().fadeIn(duration: 220.ms),
            const SizedBox(height: 12),
            RoleCard(
              title: 'Медик / рейнджер',
              description: 'Подтвердить заявки и выдать LifePod-запасы',
              icon: Icons.medical_services_outlined,
              onPressed: () => context.go('/ranger'),
            ).animate().fadeIn(duration: 220.ms, delay: 40.ms),
            const SizedBox(height: 12),
            RoleCard(
              title: 'Поставщик',
              description: 'Обновить запасы аптеки, магазина или склада',
              icon: Icons.inventory_2_outlined,
              onPressed: () => context.go('/supplier'),
            ).animate().fadeIn(duration: 220.ms, delay: 80.ms),
            const SizedBox(height: 12),
            RoleCard(
              title: 'Диспетчер',
              description: 'Приоритизация, маршруты и доставка',
              icon: Icons.hub_outlined,
              onPressed: () => context.go('/dispatcher'),
            ).animate().fadeIn(duration: 220.ms, delay: 120.ms),
          ],
        ),
      ),
    );
  }
}

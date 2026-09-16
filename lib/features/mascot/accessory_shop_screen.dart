import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/widgets/status_bar.dart';
import '../progress/progress_cubit.dart';
import '../progress/progress_models.dart';
import 'mascot_mood.dart';
import 'mascot_widget.dart';

class AccessoryShopScreen extends StatelessWidget {
  const AccessoryShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopStatusBar(showBack: true),
          Text('Palsy Closet', style: AppTheme.fredoka(size: 28, color: AppColors.primary)),
          Text('Spend stars on hats!', style: AppTheme.nunito(size: 15)),
          const SizedBox(height: 8),
          BlocBuilder<ProgressCubit, ProgressState>(
            builder: (context, state) {
              return MascotWidget(
                size: 160,
                hatId: state.player.equippedHat,
                mood: MascotMood.idle,
              );
            },
          ),
          Expanded(
            child: BlocBuilder<ProgressCubit, ProgressState>(
              builder: (context, state) {
                return GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                  children: [
                    for (final hat in HatCatalog.items)
                      _HatCard(hat: hat, playerStars: state.player.stars, owned: state.player.ownedHats.contains(hat.id), equipped: state.player.equippedHat == hat.id),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HatCard extends StatelessWidget {
  const _HatCard({
    required this.hat,
    required this.playerStars,
    required this.owned,
    required this.equipped,
  });

  final HatItem hat;
  final int playerStars;
  final bool owned;
  final bool equipped;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: equipped ? AppColors.primary : const Color(0xFFE2E8F0),
          width: 3,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: FittedBox(
              child: MascotWidget(size: 72, hatId: hat.id),
            ),
          ),
          Text(hat.label, style: AppTheme.fredoka(size: 16)),
          Text(
            owned ? 'Owned' : '${hat.cost} stars',
            style: AppTheme.nunito(size: 13),
          ),
          const SizedBox(height: 6),
          KidButton(
            label: equipped
                ? 'Wearing'
                : owned
                    ? 'Wear'
                    : playerStars >= hat.cost
                        ? 'Buy'
                        : 'Need stars',
            wide: true,
            color: equipped ? AppColors.success : AppColors.secondary,
            onPressed: equipped
                ? null
                : () async {
                    final cubit = context.read<ProgressCubit>();
                    if (owned) {
                      await cubit.equipHat(hat.id);
                    } else {
                      final ok = await cubit.buyHat(hat.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Palsy loves it!' : 'Earn more stars first.'),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
    );
  }
}

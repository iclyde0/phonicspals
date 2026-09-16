import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/parent_portal/parent_gate.dart';
import '../../features/progress/progress_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class TopStatusBar extends StatelessWidget {
  const TopStatusBar({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            if (showBack)
              _RoundIcon(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              )
            else
              const SizedBox(width: 44),
            const Spacer(),
            BlocBuilder<ProgressCubit, ProgressState>(
              builder: (context, state) {
                return Row(
                  children: [
                    _Chip(
                      icon: Icons.star_rounded,
                      color: AppColors.accent,
                      label: '${state.player.stars}',
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.primary,
                      label: '${state.player.streakDays}',
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            _RoundIcon(
              icon: Icons.lock_rounded,
              onTap: () => ParentGate.open(context),
              onLongPress: () => ParentGate.open(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 4),
          Text(label, style: AppTheme.fredoka(size: 18, color: AppColors.navy)),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

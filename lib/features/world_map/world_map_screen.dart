import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/widgets/status_bar.dart';
import '../mascot/accessory_shop_screen.dart';
import '../mascot/mascot_mood.dart';
import '../mascot/mascot_widget.dart';
import '../progress/progress_cubit.dart';
import 'lesson_tutorial.dart';
import 'realm_data.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBAE6FD), AppColors.background],
          ),
        ),
        child: Column(
          children: [
            const TopStatusBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  BlocBuilder<ProgressCubit, ProgressState>(
                    builder: (context, state) {
                      return MascotWidget(
                        size: 92,
                        hatId: state.player.equippedHat,
                        mood: MascotMood.idle,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BrandTitle(size: 28),
                        Text(
                          'Pick a path and play!',
                          style: AppTheme.nunito(size: 15),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AccessoryShopScreen(),
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.checkroom_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProgressCubit, ProgressState>(
                builder: (context, state) {
                  final ids = WorldRealms.orderedLevelIds;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: WorldRealms.all.length,
                    itemBuilder: (context, index) {
                      final realm = WorldRealms.all[index];
                      return _RealmCard(
                        realm: realm,
                        orderedIds: ids,
                        alignRight: index.isOdd,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealmCard extends StatelessWidget {
  const _RealmCard({
    required this.realm,
    required this.orderedIds,
    required this.alignRight,
  });

  final RealmDef realm;
  final List<String> orderedIds;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<ProgressCubit>().state.player;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: realm.color.withValues(alpha: 0.45), width: 3),
      ),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(realm.title, style: AppTheme.fredoka(size: 24, color: realm.color)),
          Text(realm.subtitle, style: AppTheme.nunito(size: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: alignRight ? WrapAlignment.end : WrapAlignment.start,
            children: [
              for (var i = 0; i < realm.levels.length; i++)
                _LevelNode(
                  level: realm.levels[i],
                  index: i + 1,
                  color: realm.color,
                  stars: player.starsFor(realm.levels[i].id),
                  locked: !player.unlocked(realm.levels[i].id, orderedIds),
                  active: player.unlocked(realm.levels[i].id, orderedIds) &&
                      player.starsFor(realm.levels[i].id) == 0,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.level,
    required this.index,
    required this.color,
    required this.stars,
    required this.locked,
    required this.active,
  });

  final LevelDef level;
  final int index;
  final Color color;
  final int stars;
  final bool locked;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked
          ? null
          : () async {
              final player = context.read<ProgressCubit>().state.player;
              if (WorldRealms.shouldShowTutorial(player, level)) {
                final realm = WorldRealms.realmFor(level);
                if (realm == null) return;
                final play = await LessonTutorial.show(context, realm);
                if (!play || !context.mounted) return;
              }
              WorldRealms.open(context, level);
            },
      child: AnimatedScale(
        scale: active ? 1.08 : 1,
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: locked ? const Color(0xFFCBD5E1) : color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: locked ? 0.1 : 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: locked
                    ? const Icon(Icons.lock_rounded, color: Colors.white)
                    : Text(
                        '$index',
                        style: AppTheme.fredoka(size: 24, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var s = 1; s <= 3; s++)
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: s <= stars ? AppColors.accent : const Color(0xFFE2E8F0),
                  ),
              ],
            ),
            SizedBox(
              width: 72,
              child: Text(
                level.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.nunito(size: 11, color: AppColors.navy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

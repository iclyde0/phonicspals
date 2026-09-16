import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/phonics_engine.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/widgets/status_bar.dart';
import '../progress/progress_cubit.dart';

class ParentPortalScreen extends StatelessWidget {
  const ParentPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          final player = state.player;
          final stats = PhonicsCurriculum.stage1Letters
              .map((id) => (id: id, stat: player.stat(id)))
              .where((row) => row.stat.attempts > 0)
              .toList()
            ..sort((a, b) => a.stat.accuracy.compareTo(b.stat.accuracy));

          return Column(
            children: [
              const TopStatusBar(showBack: true),
              Text('Parent Portal', style: AppTheme.fredoka(size: 28, color: AppColors.secondaryDark)),
              Text(
                'Private · stored only on this device',
                style: AppTheme.nunito(size: 14),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _StatCard(label: 'Stars', value: '${player.stars}', color: AppColors.accent),
                    const SizedBox(width: 8),
                    _StatCard(label: 'Streak', value: '${player.streakDays}d', color: AppColors.primary),
                    const SizedBox(width: 8),
                    _StatCard(label: 'Sessions', value: '${player.sessionsCompleted}', color: AppColors.secondary),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Phoneme accuracy', style: AppTheme.fredoka(size: 18)),
                ),
              ),
              Expanded(
                child: stats.isEmpty
                    ? Center(child: Text('Play a game to see progress.', style: AppTheme.nunito(size: 16)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: stats.length,
                        itemBuilder: (context, index) {
                          final row = stats[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    row.id.toUpperCase(),
                                    style: AppTheme.fredoka(size: 18, color: AppColors.navy),
                                  ),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      minHeight: 12,
                                      value: row.stat.accuracy,
                                      color: row.stat.mastered ? AppColors.success : AppColors.primary,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(row.stat.accuracy * 100).round()}%',
                                  style: AppTheme.nunito(size: 13, color: AppColors.navy),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: KidButton(
                  label: 'Reset child progress',
                  color: AppColors.danger,
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset progress?'),
                        content: const Text('Stars, levels, and sound scores will be cleared on this device.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await context.read<ProgressCubit>().resetProgress();
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Text(value, style: AppTheme.fredoka(size: 22, color: color)),
            Text(label, style: AppTheme.nunito(size: 12)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kid_button.dart';
import '../../mascot/mascot_mood.dart';
import '../../mascot/mascot_widget.dart';

class SessionResultSheet {
  static int starsFor(int correct, int total) {
    if (total == 0) return 0;
    final ratio = correct / total;
    if (ratio >= 1) return 3;
    if (ratio >= 0.75) return 2;
    if (ratio >= 0.5) return 1;
    return 0;
  }

  static Future<void> show(
    BuildContext context, {
    required int correct,
    required int total,
    required int stars,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MascotWidget(size: 120, mood: MascotMood.celebrating),
              Text('Great work!', style: AppTheme.fredoka(size: 28, color: AppColors.primary)),
              Text(
                'You got $correct of $total',
                style: AppTheme.nunito(size: 16),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 3; i++)
                    Icon(
                      Icons.star_rounded,
                      size: 40,
                      color: i <= stars ? AppColors.accent : const Color(0xFFE2E8F0),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              KidButton(
                label: 'Back to map',
                icon: Icons.map_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}

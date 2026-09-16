import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/kid_button.dart';
import '../mascot/mascot_mood.dart';
import '../mascot/mascot_widget.dart';
import 'realm_data.dart';

class LessonTutorial {
  static Future<bool> show(BuildContext context, RealmDef realm) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LessonTutorialDialog(realm: realm),
    );
    return result ?? false;
  }
}

class _LessonTutorialDialog extends StatelessWidget {
  const _LessonTutorialDialog({required this.realm});

  final RealmDef realm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SizedBox(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MascotWidget(size: 120, mood: MascotMood.hinting),
              Text(
                realm.howToTitle,
                textAlign: TextAlign.center,
                style: AppTheme.fredoka(size: 22, color: realm.color),
              ),
              const SizedBox(height: 4),
              Text(
                realm.title,
                style: AppTheme.nunito(size: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < realm.howToSteps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: realm.color,
                        child: Text(
                          '${i + 1}',
                          style: AppTheme.fredoka(size: 14, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          realm.howToSteps[i],
                          style: AppTheme.nunito(size: 15, color: AppColors.navy),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              KidButton(
                label: "Let's play!",
                icon: Icons.play_arrow_rounded,
                color: realm.color,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

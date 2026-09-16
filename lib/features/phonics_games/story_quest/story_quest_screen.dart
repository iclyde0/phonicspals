import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/phonics_audio_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phonics_engine.dart';
import '../../../core/widgets/kid_button.dart';
import '../../../core/widgets/status_bar.dart';
import '../../mascot/mascot_mood.dart';
import '../../mascot/mascot_widget.dart';
import '../../progress/progress_cubit.dart';
import '../shared/session_result_sheet.dart';

class StoryQuestScreen extends StatefulWidget {
  const StoryQuestScreen({super.key, required this.levelId});

  final String levelId;

  @override
  State<StoryQuestScreen> createState() => _StoryQuestScreenState();
}

class _StoryQuestScreenState extends State<StoryQuestScreen> {
  late final List<StoryBeat> _beats;
  var _index = 0;
  var _correct = 0;
  var _mood = MascotMood.hinting;

  StoryBeat get _beat => _beats[_index];

  @override
  void initState() {
    super.initState();
    _beats = List<StoryBeat>.from(PhonicsCurriculum.storyBeats)..shuffle();
  }

  Future<void> _pick(String option) async {
    final ok = option == _beat.answer;
    final cubit = context.read<ProgressCubit>();
    final audio = context.read<PhonicsAudioService>();
    await cubit.recordAttempt(_beat.target, ok);
    if (ok) {
      _correct++;
      await audio.playSuccess();
      await audio.playWord(option);
      setState(() => _mood = MascotMood.celebrating);
    } else {
      await audio.playError();
      setState(() => _mood = MascotMood.encouraging);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (_index >= _beats.length - 1) {
      final stars = SessionResultSheet.starsFor(_correct, _beats.length);
      await cubit.completeLevel(
        levelId: widget.levelId,
        earnedStars: stars,
        correctCount: _correct,
      );
      if (!mounted) return;
      await SessionResultSheet.show(
        context,
        correct: _correct,
        total: _beats.length,
        stars: stars,
      );
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _mood = MascotMood.hinting;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hat = context.watch<ProgressCubit>().state.player.equippedHat;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDE68A), Color(0xFFFED7AA), Color(0xFFFEF3C7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const TopStatusBar(showBack: true),
            Text('Story Quest', style: AppTheme.fredoka(size: 26, color: AppColors.primaryDark)),
            MascotWidget(size: 130, mood: _mood, hatId: hat),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _beat.prompt,
                textAlign: TextAlign.center,
                style: AppTheme.fredoka(size: 22, color: AppColors.navy),
              ),
            ),
            for (final option in _beat.options)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: KidButton(
                  label: option,
                  color: AppColors.blockFor(option),
                  onPressed: () => _pick(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

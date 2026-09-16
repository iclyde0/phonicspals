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

class SpeedRunnerScreen extends StatefulWidget {
  const SpeedRunnerScreen({super.key, required this.levelId});

  final String levelId;

  @override
  State<SpeedRunnerScreen> createState() => _SpeedRunnerScreenState();
}

class _SpeedRunnerScreenState extends State<SpeedRunnerScreen> {
  late final List<SentenceItem> _items;
  var _index = 0;
  var _correct = 0;
  var _mood = MascotMood.idle;
  var _started = false;
  final _sw = Stopwatch();

  SentenceItem get _item => _items[_index];

  @override
  void initState() {
    super.initState();
    _items = List<SentenceItem>.from(PhonicsCurriculum.sentences)..shuffle();
  }

  void _begin() {
    setState(() => _started = true);
    _sw.start();
    context.read<PhonicsAudioService>().playWord(_item.focus);
  }

  Future<void> _pick(String option) async {
    final ok = option == _item.focus;
    final cubit = context.read<ProgressCubit>();
    final audio = context.read<PhonicsAudioService>();
    await cubit.recordAttempt(_item.focus, ok);
    if (ok) {
      _correct++;
      await audio.playSuccess();
      setState(() => _mood = MascotMood.celebrating);
    } else {
      await audio.playError();
      setState(() => _mood = MascotMood.encouraging);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (_index >= _items.length - 1) {
      _sw.stop();
      final stars = SessionResultSheet.starsFor(_correct, _items.length);
      await cubit.completeLevel(
        levelId: widget.levelId,
        earnedStars: stars,
        correctCount: _correct,
      );
      if (!mounted) return;
      await SessionResultSheet.show(
        context,
        correct: _correct,
        total: _items.length,
        stars: stars,
      );
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _mood = MascotMood.idle;
    });
    await audio.playWord(_item.focus);
  }

  @override
  Widget build(BuildContext context) {
    final hat = context.watch<ProgressCubit>().state.player.equippedHat;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFBAE6FD), Color(0xFFE0F2FE), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const TopStatusBar(showBack: true),
            Text('Speed Runner', style: AppTheme.fredoka(size: 26, color: AppColors.secondaryDark)),
            MascotWidget(size: 120, mood: _mood, hatId: hat),
            if (!_started)
              Padding(
                padding: const EdgeInsets.all(24),
                child: KidButton(
                  label: 'Start reading',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _begin,
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _item.text,
                  textAlign: TextAlign.center,
                  style: AppTheme.fredoka(size: 26, color: AppColors.navy),
                ),
              ),
              Text('Tap the matching word', style: AppTheme.nunito(size: 15)),
              const SizedBox(height: 12),
              for (final option in _item.options)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: KidButton(
                    label: option,
                    color: AppColors.blockFor(option),
                    onPressed: () => _pick(option),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

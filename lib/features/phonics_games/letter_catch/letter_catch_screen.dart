import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/phonics_audio_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_bar.dart';
import '../../mascot/mascot_mood.dart';
import '../../mascot/mascot_widget.dart';
import '../../progress/progress_cubit.dart';
import '../shared/session_result_sheet.dart';
import 'letter_catch_game.dart';

class LetterCatchScreen extends StatefulWidget {
  const LetterCatchScreen({super.key, required this.levelId});

  final String levelId;

  @override
  State<LetterCatchScreen> createState() => _LetterCatchScreenState();
}

class _LetterCatchScreenState extends State<LetterCatchScreen> {
  late final LetterCatchGame _game;
  late List<String> _targets;
  var _index = 0;
  var _correct = 0;
  var _mood = MascotMood.hinting;
  var _ready = false;

  String get _current => _targets[_index];

  @override
  void initState() {
    super.initState();
    _game = LetterCatchGame(onGuess: _onGuess);
    _targets = const ['s', 'a', 't', 'p', 'i', 'n', 'c', 'k'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _targets = context.read<ProgressCubit>().nextLetters(count: 8).targets;
      _startRound();
    });
  }

  Future<void> _startRound() async {
    final cubit = context.read<ProgressCubit>();
    final audio = context.read<PhonicsAudioService>();
    final options = cubit.engine.distractorsFor(_current);
    _game.loadRound(_current, options);
    setState(() {
      _mood = MascotMood.hinting;
      _ready = true;
    });
    await audio.playPhoneme(_current);
  }

  Future<void> _onGuess(String letter) async {
    if (!mounted) return;
    final cubit = context.read<ProgressCubit>();
    final audio = context.read<PhonicsAudioService>();
    final ok = letter.toLowerCase() == _current;
    await cubit.recordAttempt(_current, ok);
    if (ok) {
      _correct++;
      await audio.playSuccess();
      setState(() => _mood = MascotMood.celebrating);
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await _advance();
    } else {
      await audio.playError();
      setState(() => _mood = MascotMood.encouraging);
      await audio.playPhoneme(_current);
    }
  }

  Future<void> _advance() async {
    if (_index >= _targets.length - 1) {
      final stars = SessionResultSheet.starsFor(_correct, _targets.length);
      await context.read<ProgressCubit>().completeLevel(
            levelId: widget.levelId,
            earnedStars: stars,
            correctCount: _correct,
          );
      if (!mounted) return;
      await SessionResultSheet.show(
        context,
        correct: _correct,
        total: _targets.length,
        stars: stars,
      );
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() => _index++);
    await _startRound();
  }

  @override
  Widget build(BuildContext context) {
    final hat = context.watch<ProgressCubit>().state.player.equippedHat;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7DD3FC), Color(0xFFBBF7D0), Color(0xFFFEF9C3)],
          ),
        ),
        child: Column(
          children: [
            const TopStatusBar(showBack: true),
            Text('Letter Catch', style: AppTheme.fredoka(size: 26, color: AppColors.navy)),
            Text(
              'Drag the matching sound!',
              style: AppTheme.nunito(size: 15),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GameWidget(game: _game),
                  IgnorePointer(
                    child: Transform.translate(
                      offset: const Offset(0, 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MascotWidget(
                            size: 240,
                            mood: _mood,
                            hatId: hat,
                            showSlot: true,
                            slotLetter: _ready ? _current : '?',
                          ),
                          Text(
                            '${_index + 1} / ${_targets.length}',
                            style: AppTheme.fredoka(
                              size: 18,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

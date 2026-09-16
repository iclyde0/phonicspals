import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/phonics_audio_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phonics_engine.dart';
import '../../../core/widgets/status_bar.dart';
import '../../mascot/mascot_mood.dart';
import '../../mascot/mascot_widget.dart';
import '../../progress/progress_cubit.dart';
import '../shared/session_result_sheet.dart';
import 'word_builder_game.dart';

class WordBuilderScreen extends StatefulWidget {
  const WordBuilderScreen({
    super.key,
    required this.levelId,
    required this.wordSet,
  });

  final String levelId;
  final String wordSet;

  @override
  State<WordBuilderScreen> createState() => _WordBuilderScreenState();
}

class _WordBuilderScreenState extends State<WordBuilderScreen> {
  late final CvcWordGame _game;
  late List<String> _words;
  var _index = 0;
  var _correct = 0;
  var _mood = MascotMood.idle;
  var _busy = false;

  String get _current => _words[_index];

  @override
  void initState() {
    super.initState();
    _game = CvcWordGame(
      onPhoneme: _playPhoneme,
      onWordComplete: _onWordComplete,
    );
    _words = List<String>.from(
      PhonicsCurriculum.cvcSets[widget.wordSet] ?? PhonicsCurriculum.cvcSets['satpin']!,
    )..shuffle();
    if (_words.length > 6) _words = _words.take(6).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startRound();
    });
  }

  void _playPhoneme(String phoneme) {
    if (!mounted) return;
    context.read<PhonicsAudioService>().playPhoneme(phoneme);
  }

  void _startRound() {
    final extras = context.read<ProgressCubit>().engine.distractorsFor(
          _current[0],
          count: 2,
        );
    _game.loadRound(_current, extras);
    setState(() {
      _mood = MascotMood.idle;
      _busy = false;
    });
    context.read<PhonicsAudioService>().playWord(_current);
  }

  Future<void> _onWordComplete(bool correct, String built) async {
    if (_busy || !mounted) return;
    _busy = true;
    final cubit = context.read<ProgressCubit>();
    final audio = context.read<PhonicsAudioService>();
    for (final letter in _current.split('')) {
      await cubit.recordAttempt(letter, correct);
    }
    if (correct) {
      _correct++;
      await audio.playSuccess();
      await audio.playWord(_current);
      setState(() => _mood = MascotMood.celebrating);
    } else {
      await audio.playError();
      setState(() => _mood = MascotMood.encouraging);
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (_index >= _words.length - 1) {
      final stars = SessionResultSheet.starsFor(_correct, _words.length);
      await cubit.completeLevel(
        levelId: widget.levelId,
        earnedStars: stars,
        correctCount: _correct,
      );
      if (!mounted) return;
      await SessionResultSheet.show(
        context,
        correct: _correct,
        total: _words.length,
        stars: stars,
      );
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() => _index++);
    _startRound();
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
            colors: [Color(0xFFFED7AA), Color(0xFFFEF3C7), Color(0xFFE0F2FE)],
          ),
        ),
        child: Column(
          children: [
            const TopStatusBar(showBack: true),
            Text('Word Builder Blocks', style: AppTheme.fredoka(size: 24, color: AppColors.primaryDark)),
            Text('Snap the sounds together', style: AppTheme.nunito(size: 15)),
            const SizedBox(height: 20),
            MascotWidget(size: 180, mood: _mood, hatId: hat),
            const SizedBox(height: 8),
            Text(
              _current.toUpperCase().split('').join(' · '),
              style: AppTheme.fredoka(size: 22, color: AppColors.navy),
            ),
            Text(
              '${_index + 1} / ${_words.length}',
              style: AppTheme.nunito(size: 14),
            ),
            Expanded(child: GameWidget(game: _game)),
          ],
        ),
      ),
    );
  }
}

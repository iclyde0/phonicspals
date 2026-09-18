import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:phonics_pals/core/utils/phonics_engine.dart';
import 'package:phonics_pals/core/widgets/kid_button.dart';
import 'package:phonics_pals/features/phonics_games/shared/session_result_sheet.dart';
import 'package:phonics_pals/features/progress/progress_models.dart';
import 'package:phonics_pals/features/progress/progress_repository.dart';
import 'package:phonics_pals/features/world_map/realm_data.dart';

void main() {
  test('adaptive lesson prefers review once sounds are mastered', () {
    final engine = PhonicsEngine(random: Random(4));
    final stats = <String, PhonemeStat>{
      for (final letter in ['s', 'a', 't', 'p', 'i', 'n'])
        letter: const PhonemeStat(attempts: 5, correct: 5),
    };

    final lesson = engine.getNextPhonemeLesson(stats, count: 20);
    expect(lesson.reviewRatio, greaterThan(0.5));
    expect(lesson.targets, isNotEmpty);
  });

  test('tricky phonemes stay in the mix before mastery', () {
    final engine = PhonicsEngine(random: Random(1));
    final stats = {
      's': const PhonemeStat(attempts: 4, correct: 1),
    };
    final lesson = engine.getNextPhonemeLesson(stats, count: 8);
    expect(lesson.targets, contains('s'));
  });

  test('letter pools stay inside each forest lesson', () {
    expect(PhonicsCurriculum.letterPoolFor('forest_1'), ['s', 'a', 't', 'p', 'i', 'n']);
    expect(PhonicsCurriculum.letterPoolFor('forest_2'), containsAll(['c', 'k', 'e']));
    expect(PhonicsCurriculum.letterPoolFor('forest_5'), PhonicsCurriculum.stage1Letters);
    final mixed = PhonicsCurriculum.letterPoolFor('forest_1');
    expect(mixed, isNot(contains('q')));
  });

  test('story quest and speed runner banks differ by level', () {
    final shCh = PhonicsCurriculum.storyBeatsFor('desert_1');
    expect(shCh.every((beat) => beat.target == 'sh' || beat.target == 'ch'), isTrue);
    expect(shCh.length, greaterThanOrEqualTo(4));

    final thWh = PhonicsCurriculum.storyBeatsFor('desert_2');
    expect(thWh.every((beat) => beat.target == 'th' || beat.target == 'wh'), isTrue);

    final mix = PhonicsCurriculum.storyBeatsFor('desert_3');
    expect(mix.map((beat) => beat.target), containsAll(['ck', 'ng']));

    expect(PhonicsCurriculum.timeLimitFor('falls_1'), isNull);
    expect(PhonicsCurriculum.timeLimitFor('falls_2'), const Duration(seconds: 8));
    expect(
      PhonicsCurriculum.sentencesFor('falls_2').map((item) => item.focus),
      containsAll(['look', 'duck', 'king']),
    );
  });

  test('wallet stars only increase when the best score improves', () {
    expect(walletStarsFor(previousBest: 0, earnedStars: 2), 2);
    expect(walletStarsFor(previousBest: 2, earnedStars: 3), 1);
    expect(walletStarsFor(previousBest: 3, earnedStars: 2), 0);
    expect(walletStarsFor(previousBest: 3, earnedStars: 3), 0);
  });

  test('star scoring matches session thresholds', () {
    expect(SessionResultSheet.starsFor(8, 8), 3);
    expect(SessionResultSheet.starsFor(6, 8), 2);
    expect(SessionResultSheet.starsFor(4, 8), 1);
    expect(SessionResultSheet.starsFor(2, 8), 0);
  });

  test('daily streak increments and resets', () {
    final repo = ProgressRepository(_FakeBox());
    var player = const PlayerProgress();
    player = repo.applyStreak(player, DateTime(2026, 8, 24));
    expect(player.streakDays, 1);
    player = repo.applyStreak(player, DateTime(2026, 8, 25));
    expect(player.streakDays, 2);
    player = repo.applyStreak(player, DateTime(2026, 8, 27));
    expect(player.streakDays, 1);
  });

  test('tutorial only shows on a fresh first lesson', () {
    const first = LevelDef(
      id: 'forest_1',
      title: 's a t p i n',
      kind: LevelKind.letterCatch,
    );
    const second = LevelDef(
      id: 'forest_2',
      title: 'c k e h r m d',
      kind: LevelKind.letterCatch,
    );
    const fresh = PlayerProgress();
    expect(WorldRealms.shouldShowTutorial(fresh, first), isTrue);
    expect(WorldRealms.shouldShowTutorial(fresh, second), isFalse);

    const started = PlayerProgress(levelStars: {'forest_1': 1});
    expect(WorldRealms.shouldShowTutorial(started, first), isFalse);
  });

  testWidgets('brand title paints PhonicsPals', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BrandTitle()),
      ),
    );
    expect(find.text('PhonicsPals'), findsOneWidget);
    expect(find.byType(BrandTitle), findsOneWidget);
  });
}

class _FakeBox extends Fake implements Box<dynamic> {}

import '../../core/theme/app_colors.dart';
import '../phonics_games/letter_catch/letter_catch_screen.dart';
import '../phonics_games/speed_runner/speed_runner_screen.dart';
import '../phonics_games/story_quest/story_quest_screen.dart';
import '../phonics_games/word_builder/word_builder_screen.dart';
import '../progress/progress_models.dart';
import 'package:flutter/material.dart';

class RealmDef {
  const RealmDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.levels,
    required this.howToTitle,
    required this.howToSteps,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final List<LevelDef> levels;
  final String howToTitle;
  final List<String> howToSteps;
}

class LevelDef {
  const LevelDef({
    required this.id,
    required this.title,
    required this.kind,
    this.wordSet,
  });

  final String id;
  final String title;
  final LevelKind kind;
  final String? wordSet;
}

enum LevelKind { letterCatch, wordBuilder, storyQuest, speedRunner }

abstract final class WorldRealms {
  static const all = [
    RealmDef(
      id: 'forest',
      title: 'Alphabet Forest',
      subtitle: 'Letter Catch · sounds A–Z',
      color: AppColors.forest,
      howToTitle: 'How to play Letter Catch',
      howToSteps: [
        'Palsy holds a letter sound.',
        'Drag the matching letter block onto Palsy.',
        'Listen, then do it again!',
      ],
      levels: [
        LevelDef(id: 'forest_1', title: 's a t p i n', kind: LevelKind.letterCatch),
        LevelDef(id: 'forest_2', title: 'c k e h r m d', kind: LevelKind.letterCatch),
        LevelDef(id: 'forest_3', title: 'g o u l f b', kind: LevelKind.letterCatch),
        LevelDef(id: 'forest_4', title: 'j z w v y x q', kind: LevelKind.letterCatch),
        LevelDef(id: 'forest_5', title: 'Mixed letters', kind: LevelKind.letterCatch),
        LevelDef(id: 'forest_6', title: 'Sound review', kind: LevelKind.letterCatch),
      ],
    ),
    RealmDef(
      id: 'canyon',
      title: 'CVC Canyon',
      subtitle: 'Word Builder Blocks',
      color: AppColors.primary,
      howToTitle: 'How to play Word Builder',
      howToSteps: [
        'Look at the word Palsy wants to build.',
        'Drag each sound block into an empty slot.',
        'Snap them together to make the word!',
      ],
      levels: [
        LevelDef(id: 'canyon_1', title: 'sat · pin', kind: LevelKind.wordBuilder, wordSet: 'satpin'),
        LevelDef(id: 'canyon_2', title: 'cat · hat', kind: LevelKind.wordBuilder, wordSet: 'cat_hat'),
        LevelDef(id: 'canyon_3', title: 'pig · dig', kind: LevelKind.wordBuilder, wordSet: 'pig_dig'),
        LevelDef(id: 'canyon_4', title: 'dog · hop', kind: LevelKind.wordBuilder, wordSet: 'dog_hop'),
        LevelDef(id: 'canyon_5', title: 'sun · run', kind: LevelKind.wordBuilder, wordSet: 'sun_run'),
        LevelDef(id: 'canyon_6', title: 'bed · red', kind: LevelKind.wordBuilder, wordSet: 'bed_red'),
      ],
    ),
    RealmDef(
      id: 'desert',
      title: 'Digraph Desert',
      subtitle: 'Story Quests',
      color: AppColors.accent,
      howToTitle: 'How to play Story Quest',
      howToSteps: [
        'Read Palsy’s clue.',
        'Tap the word with the special sound, like sh or ch.',
        'The right word helps Palsy continue the story!',
      ],
      levels: [
        LevelDef(id: 'desert_1', title: 'sh · ch', kind: LevelKind.storyQuest),
        LevelDef(id: 'desert_2', title: 'th · wh', kind: LevelKind.storyQuest),
        LevelDef(id: 'desert_3', title: 'Quest mix', kind: LevelKind.storyQuest),
      ],
    ),
    RealmDef(
      id: 'falls',
      title: 'Fluency Falls',
      subtitle: 'Speed Runner',
      color: AppColors.secondary,
      howToTitle: 'How to play Speed Runner',
      howToSteps: [
        'Tap Start, then read the sentence.',
        'Tap the word that matches what you read.',
        'On Faster sentences, tap before the timer runs out!',
        'Go as quickly as you can — Palsy is cheering!',
      ],
      levels: [
        LevelDef(id: 'falls_1', title: 'Read and match', kind: LevelKind.speedRunner),
        LevelDef(id: 'falls_2', title: 'Faster sentences', kind: LevelKind.speedRunner),
      ],
    ),
  ];

  static List<String> get orderedLevelIds => [
        for (final realm in all)
          for (final level in realm.levels) level.id,
      ];

  static RealmDef? realmFor(LevelDef level) {
    for (final realm in all) {
      if (realm.levels.any((item) => item.id == level.id)) return realm;
    }
    return null;
  }

  /// First lesson of a block, and every other lesson in that block is still locked.
  static bool shouldShowTutorial(PlayerProgress player, LevelDef level) {
    final realm = realmFor(level);
    if (realm == null || realm.levels.first.id != level.id) return false;
    return realm.levels.every((item) => player.starsFor(item.id) == 0);
  }

  static void open(BuildContext context, LevelDef level) {
    final page = switch (level.kind) {
      LevelKind.letterCatch => LetterCatchScreen(levelId: level.id),
      LevelKind.wordBuilder => WordBuilderScreen(
          levelId: level.id,
          wordSet: level.wordSet ?? 'satpin',
        ),
      LevelKind.storyQuest => StoryQuestScreen(levelId: level.id),
      LevelKind.speedRunner => SpeedRunnerScreen(levelId: level.id),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

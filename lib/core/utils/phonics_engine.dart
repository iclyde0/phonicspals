import 'dart:math';

/// Synthetic phonics progression used by adaptive lesson selection.
abstract final class PhonicsCurriculum {
  /// Stage 1: letter-sound correspondence (Letters and Sounds order).
  static const stage1Letters = [
    's', 'a', 't', 'p', 'i', 'n',
    'c', 'k', 'e', 'h', 'r', 'm', 'd',
    'g', 'o', 'u', 'l', 'f', 'b',
    'j', 'z', 'w', 'v', 'y', 'x', 'q',
  ];

  static const letterSets = <String, List<String>>{
    'forest_1': ['s', 'a', 't', 'p', 'i', 'n'],
    'forest_2': ['c', 'k', 'e', 'h', 'r', 'm', 'd'],
    'forest_3': ['g', 'o', 'u', 'l', 'f', 'b'],
    'forest_4': ['j', 'z', 'w', 'v', 'y', 'x', 'q'],
  };

  static const cvcSets = <String, List<String>>{
    'satpin': [
      'sat', 'pin', 'tin', 'tap', 'pat', 'sit', 'pan', 'nap', 'sip', 'nit', 'tip', 'pit',
    ],
    'cat_hat': [
      'cat', 'hat', 'mat', 'bat', 'rat', 'cap', 'map', 'man', 'can', 'tan', 'ham', 'ram',
    ],
    'pig_dig': [
      'pig', 'dig', 'big', 'wig', 'pin', 'win', 'pit', 'sit', 'fig', 'dip', 'hid', 'bit',
    ],
    'dog_hop': [
      'dog', 'fog', 'log', 'hop', 'top', 'mop', 'pot', 'hot', 'dot', 'got', 'pop', 'lot',
    ],
    'sun_run': [
      'sun', 'bun', 'run', 'cup', 'pup', 'bus', 'mug', 'fun', 'nut', 'cut', 'gum', 'rug',
    ],
    'bed_red': [
      'bed', 'red', 'hen', 'pen', 'ten', 'net', 'wet', 'leg', 'peg', 'den', 'pet', 'beg',
    ],
  };

  static const digraphs = ['sh', 'ch', 'th', 'wh', 'ck', 'ng'];

  static const sightWords = [
    'the', 'and', 'see', 'look', 'you', 'me', 'we', 'to',
  ];

  static const sentencesEasy = [
    SentenceItem('The cat sat on the mat.', 'cat', ['cat', 'sun', 'pig']),
    SentenceItem('A big red bus is here.', 'bus', ['bus', 'hat', 'dog']),
    SentenceItem('The pig can dig in mud.', 'pig', ['pig', 'cup', 'map']),
    SentenceItem('The sun is hot today.', 'sun', ['sun', 'pen', 'log']),
    SentenceItem('Look at the big dog.', 'dog', ['dog', 'bat', 'cup']),
    SentenceItem('I can hop to the top.', 'hop', ['hop', 'red', 'fan']),
    SentenceItem('See the red hen.', 'hen', ['hen', 'mop', 'bus']),
    SentenceItem('We can sit on the mat.', 'sit', ['sit', 'cup', 'fog']),
  ];

  static const sentencesFast = [
    SentenceItem('Look at me on the bus.', 'look', ['look', 'ship', 'chop']),
    SentenceItem('You and me can run.', 'you', ['you', 'hot', 'leg']),
    SentenceItem('We see the big sun.', 'see', ['see', 'pan', 'dig']),
    SentenceItem('The duck can swim.', 'duck', ['duck', 'ship', 'when']),
    SentenceItem('A king has a ring.', 'king', ['king', 'chop', 'that']),
    SentenceItem('Then the ship can go.', 'then', ['then', 'shop', 'chip']),
    SentenceItem('When can we hop?', 'when', ['when', 'that', 'shop']),
    SentenceItem('The chick can peck.', 'chick', ['chick', 'this', 'song']),
  ];

  /// All fluency sentences (easy + faster banks).
  static List<SentenceItem> get sentences => [...sentencesEasy, ...sentencesFast];

  static const storyBeats = [
    StoryBeat(
      prompt: 'Help Palsy find the ship. Tap the word with sh.',
      target: 'sh',
      options: ['ship', 'chop', 'that'],
      answer: 'ship',
    ),
    StoryBeat(
      prompt: 'Palsy wants to shop. Tap the word with sh.',
      target: 'sh',
      options: ['shop', 'when', 'then'],
      answer: 'shop',
    ),
    StoryBeat(
      prompt: 'A fish is in the pond. Tap the word with sh.',
      target: 'sh',
      options: ['fish', 'chop', 'this'],
      answer: 'fish',
    ),
    StoryBeat(
      prompt: 'A chick is hungry. Tap the word with ch.',
      target: 'ch',
      options: ['this', 'chop', 'when'],
      answer: 'chop',
    ),
    StoryBeat(
      prompt: 'The chick says peep. Tap the word with ch.',
      target: 'ch',
      options: ['chick', 'shop', 'that'],
      answer: 'chick',
    ),
    StoryBeat(
      prompt: 'Sit in a chair. Tap the word with ch.',
      target: 'ch',
      options: ['chair', 'ship', 'then'],
      answer: 'chair',
    ),
    StoryBeat(
      prompt: 'Point to the word with th.',
      target: 'th',
      options: ['then', 'shop', 'chip'],
      answer: 'then',
    ),
    StoryBeat(
      prompt: 'This is Palsy’s path. Tap the word with th.',
      target: 'th',
      options: ['this', 'chop', 'when'],
      answer: 'this',
    ),
    StoryBeat(
      prompt: 'That hat is red. Tap the word with th.',
      target: 'th',
      options: ['that', 'ship', 'chip'],
      answer: 'that',
    ),
    StoryBeat(
      prompt: 'Which word has wh?',
      target: 'wh',
      options: ['when', 'that', 'shop'],
      answer: 'when',
    ),
    StoryBeat(
      prompt: 'Palsy asks which way. Tap the word with wh.',
      target: 'wh',
      options: ['which', 'then', 'chop'],
      answer: 'which',
    ),
    StoryBeat(
      prompt: 'A whale is in the sea. Tap the word with wh.',
      target: 'wh',
      options: ['whale', 'this', 'ship'],
      answer: 'whale',
    ),
    StoryBeat(
      prompt: 'Find the duck. Tap the word with ck.',
      target: 'ck',
      options: ['duck', 'ship', 'when'],
      answer: 'duck',
    ),
    StoryBeat(
      prompt: 'Palsy wants a snack. Tap the word with ck.',
      target: 'ck',
      options: ['snack', 'then', 'shop'],
      answer: 'snack',
    ),
    StoryBeat(
      prompt: 'Kick the ball. Tap the word with ck.',
      target: 'ck',
      options: ['kick', 'that', 'chop'],
      answer: 'kick',
    ),
    StoryBeat(
      prompt: 'Hear the song. Tap the word with ng.',
      target: 'ng',
      options: ['song', 'ship', 'when'],
      answer: 'song',
    ),
    StoryBeat(
      prompt: 'Find the king. Tap the word with ng.',
      target: 'ng',
      options: ['king', 'chop', 'that'],
      answer: 'king',
    ),
    StoryBeat(
      prompt: 'A ring for Palsy. Tap the word with ng.',
      target: 'ng',
      options: ['ring', 'this', 'shop'],
      answer: 'ring',
    ),
  ];

  static List<String> letterPoolFor(String levelId) =>
      letterSets[levelId] ?? List<String>.from(stage1Letters);

  static List<StoryBeat> storyBeatsFor(String levelId) {
    final filter = switch (levelId) {
      'desert_1' => const ['sh', 'ch'],
      'desert_2' => const ['th', 'wh'],
      'desert_3' => digraphs,
      _ => digraphs,
    };
    final beats = storyBeats.where((beat) => filter.contains(beat.target)).toList();
    return beats;
  }

  static List<SentenceItem> sentencesFor(String levelId) => switch (levelId) {
        'falls_2' => List<SentenceItem>.from(sentencesFast),
        _ => List<SentenceItem>.from(sentencesEasy),
      };

  /// Per-item time limit for Speed Runner. Null means untimed (Read and match).
  static Duration? timeLimitFor(String levelId) => switch (levelId) {
        'falls_2' => const Duration(seconds: 8),
        _ => null,
      };
}

class SentenceItem {
  const SentenceItem(this.text, this.focus, this.options);
  final String text;
  final String focus;
  final List<String> options;
}

class StoryBeat {
  const StoryBeat({
    required this.prompt,
    required this.target,
    required this.options,
    required this.answer,
  });

  final String prompt;
  final String target;
  final List<String> options;
  final String answer;
}

class PhonemeStat {
  const PhonemeStat({
    this.attempts = 0,
    this.correct = 0,
  });

  final int attempts;
  final int correct;

  double get accuracy => attempts == 0 ? 0 : correct / attempts;

  bool get mastered => attempts >= 4 && accuracy >= 0.8;

  PhonemeStat record(bool isCorrect) => PhonemeStat(
        attempts: attempts + 1,
        correct: correct + (isCorrect ? 1 : 0),
      );

  Map<String, dynamic> toMap() => {
        'attempts': attempts,
        'correct': correct,
      };

  factory PhonemeStat.fromMap(Map<dynamic, dynamic> map) => PhonemeStat(
        attempts: (map['attempts'] as num?)?.toInt() ?? 0,
        correct: (map['correct'] as num?)?.toInt() ?? 0,
      );
}

class LessonRequest {
  const LessonRequest({
    required this.targets,
    required this.reviewRatio,
  });

  final List<String> targets;
  final double reviewRatio;
}

/// Adaptive picker: ~70% mastered review, 30% new or tricky sounds.
class PhonicsEngine {
  PhonicsEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  LessonRequest getNextPhonemeLesson(
    Map<String, PhonemeStat> stats, {
    int count = 8,
    List<String> pool = PhonicsCurriculum.stage1Letters,
  }) {
    final mastered = <String>[];
    final tricky = <String>[];
    final unseen = <String>[];

    for (final id in pool) {
      final stat = stats[id] ?? const PhonemeStat();
      if (stat.mastered) {
        mastered.add(id);
      } else if (stat.attempts == 0) {
        unseen.add(id);
      } else {
        tricky.add(id);
      }
    }

    tricky.sort((a, b) {
      final sa = stats[a] ?? const PhonemeStat();
      final sb = stats[b] ?? const PhonemeStat();
      return sa.accuracy.compareTo(sb.accuracy);
    });

    final newPool = [...tricky, ...unseen];
    final targets = <String>[];
    var reviewCount = 0;

    for (var i = 0; i < count; i++) {
      final canReview = mastered.isNotEmpty;
      final canIntroduce = newPool.isNotEmpty;
      final preferReview = canReview && _random.nextDouble() < 0.70;

      if (preferReview || !canIntroduce) {
        targets.add(mastered.isEmpty ? pool[i % pool.length] : _pick(mastered));
        if (canReview) reviewCount++;
      } else {
        targets.add(newPool[i % newPool.length]);
      }
    }

    return LessonRequest(
      targets: targets,
      reviewRatio: count == 0 ? 0 : reviewCount / count,
    );
  }

  List<String> distractorsFor(
    String target, {
    int count = 3,
    List<String>? pool,
  }) {
    final letters = pool ?? PhonicsCurriculum.stage1Letters;
    final options = letters
        .where((letter) => letter != target.toLowerCase())
        .toList()
      ..shuffle(_random);
    return options.take(count).toList();
  }

  List<String> lettersOf(String word) => word.toLowerCase().split('');

  String _pick(List<String> items) => items[_random.nextInt(items.length)];
}

/// Wallet stars are the improvement over the previous best for that lesson.
int walletStarsFor({required int previousBest, required int earnedStars}) {
  if (earnedStars <= previousBest) return 0;
  return earnedStars - previousBest;
}

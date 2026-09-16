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

  static const cvcSets = <String, List<String>>{
    'satpin': ['sat', 'pin', 'tin', 'tap', 'pat', 'sit', 'pan', 'nap'],
    'cat_hat': ['cat', 'hat', 'mat', 'bat', 'rat', 'cap', 'map', 'man'],
    'pig_dig': ['pig', 'dig', 'big', 'wig', 'pin', 'win', 'pit', 'sit'],
    'dog_hop': ['dog', 'fog', 'log', 'hop', 'top', 'mop', 'pot', 'hot'],
    'sun_run': ['sun', 'bun', 'run', 'cup', 'pup', 'bus', 'mug', 'fun'],
    'bed_red': ['bed', 'red', 'hen', 'pen', 'ten', 'net', 'wet', 'leg'],
  };

  static const digraphs = ['sh', 'ch', 'th', 'wh', 'ck', 'ng'];

  static const sightWords = [
    'the', 'and', 'see', 'look', 'you', 'me', 'we', 'to',
  ];

  static const sentences = [
    SentenceItem('The cat sat on the mat.', 'cat', ['cat', 'sun', 'pig']),
    SentenceItem('A big red bus is here.', 'bus', ['bus', 'hat', 'dog']),
    SentenceItem('The pig can dig in mud.', 'pig', ['pig', 'cup', 'map']),
    SentenceItem('The sun is hot today.', 'sun', ['sun', 'pen', 'log']),
    SentenceItem('Look at the big dog.', 'dog', ['dog', 'bat', 'cup']),
    SentenceItem('I can hop to the top.', 'hop', ['hop', 'red', 'fan']),
  ];

  static const storyBeats = [
    StoryBeat(
      prompt: 'Help Palsy find the ship. Tap the word with sh.',
      target: 'sh',
      options: ['ship', 'chop', 'that'],
      answer: 'ship',
    ),
    StoryBeat(
      prompt: 'A chick is hungry. Tap the word with ch.',
      target: 'ch',
      options: ['this', 'chop', 'when'],
      answer: 'chop',
    ),
    StoryBeat(
      prompt: 'Point to the word with th.',
      target: 'th',
      options: ['then', 'shop', 'chip'],
      answer: 'then',
    ),
    StoryBeat(
      prompt: 'Which word has wh?',
      target: 'wh',
      options: ['when', 'that', 'shop'],
      answer: 'when',
    ),
  ];
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

  List<String> distractorsFor(String target, {int count = 3}) {
    final pool = PhonicsCurriculum.stage1Letters
        .where((letter) => letter != target.toLowerCase())
        .toList()
      ..shuffle(_random);
    return pool.take(count).toList();
  }

  List<String> lettersOf(String word) => word.toLowerCase().split('');

  String _pick(List<String> items) => items[_random.nextInt(items.length)];
}

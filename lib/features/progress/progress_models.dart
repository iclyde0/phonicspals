import '../../core/utils/phonics_engine.dart';

class PlayerProgress {
  const PlayerProgress({
    this.stars = 0,
    this.streakDays = 0,
    this.lastPlayedDate,
    this.equippedHat = 'none',
    this.ownedHats = const ['none'],
    this.phonemes = const {},
    this.levelStars = const {},
    this.parentPin,
    this.sessionsCompleted = 0,
  });

  final int stars;
  final int streakDays;
  final DateTime? lastPlayedDate;
  final String equippedHat;
  final List<String> ownedHats;
  final Map<String, PhonemeStat> phonemes;
  final Map<String, int> levelStars;
  final String? parentPin;
  final int sessionsCompleted;

  PhonemeStat stat(String id) => phonemes[id] ?? const PhonemeStat();

  int starsFor(String levelId) => levelStars[levelId] ?? 0;

  bool unlocked(String levelId, List<String> orderedIds) {
    final index = orderedIds.indexOf(levelId);
    if (index <= 0) return true;
    return starsFor(orderedIds[index - 1]) >= 1;
  }

  PlayerProgress copyWith({
    int? stars,
    int? streakDays,
    DateTime? lastPlayedDate,
    String? equippedHat,
    List<String>? ownedHats,
    Map<String, PhonemeStat>? phonemes,
    Map<String, int>? levelStars,
    String? parentPin,
    bool clearPin = false,
    int? sessionsCompleted,
  }) {
    return PlayerProgress(
      stars: stars ?? this.stars,
      streakDays: streakDays ?? this.streakDays,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      equippedHat: equippedHat ?? this.equippedHat,
      ownedHats: ownedHats ?? this.ownedHats,
      phonemes: phonemes ?? this.phonemes,
      levelStars: levelStars ?? this.levelStars,
      parentPin: clearPin ? parentPin : (parentPin ?? this.parentPin),
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
    );
  }

  Map<String, dynamic> toMap() => {
        'stars': stars,
        'streakDays': streakDays,
        'lastPlayedDate': lastPlayedDate?.toIso8601String(),
        'equippedHat': equippedHat,
        'ownedHats': ownedHats,
        'phonemes': phonemes.map((key, value) => MapEntry(key, value.toMap())),
        'levelStars': levelStars,
        'parentPin': parentPin,
        'sessionsCompleted': sessionsCompleted,
      };

  factory PlayerProgress.fromMap(Map<dynamic, dynamic> map) {
    final phonemeRaw = Map<dynamic, dynamic>.from(map['phonemes'] as Map? ?? {});
    final levelRaw = Map<dynamic, dynamic>.from(map['levelStars'] as Map? ?? {});
    return PlayerProgress(
      stars: (map['stars'] as num?)?.toInt() ?? 0,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      lastPlayedDate: map['lastPlayedDate'] is String
          ? DateTime.tryParse(map['lastPlayedDate'] as String)
          : null,
      equippedHat: map['equippedHat'] as String? ?? 'none',
      ownedHats: List<String>.from(map['ownedHats'] as List? ?? const ['none']),
      phonemes: phonemeRaw.map(
        (key, value) => MapEntry(
          key.toString(),
          PhonemeStat.fromMap(Map<dynamic, dynamic>.from(value as Map)),
        ),
      ),
      levelStars: levelRaw.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      ),
      parentPin: map['parentPin'] as String?,
      sessionsCompleted: (map['sessionsCompleted'] as num?)?.toInt() ?? 0,
    );
  }
}

class HatItem {
  const HatItem({
    required this.id,
    required this.label,
    required this.cost,
  });

  final String id;
  final String label;
  final int cost;
}

abstract final class HatCatalog {
  static const items = [
    HatItem(id: 'none', label: 'No hat', cost: 0),
    HatItem(id: 'flower', label: 'Flower', cost: 10),
    HatItem(id: 'party', label: 'Party hat', cost: 15),
    HatItem(id: 'crown', label: 'Crown', cost: 20),
    HatItem(id: 'headphones', label: 'Headphones', cost: 30),
    HatItem(id: 'wizard', label: 'Wizard hat', cost: 40),
  ];

  static HatItem byId(String id) =>
      items.firstWhere((item) => item.id == id, orElse: () => items.first);
}

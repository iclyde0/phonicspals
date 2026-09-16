import 'package:hive/hive.dart';

import '../../core/utils/hive_boxes.dart';
import '../../core/utils/phonics_engine.dart';
import 'progress_models.dart';

class ProgressRepository {
  ProgressRepository(this._box);

  final Box _box;

  PlayerProgress load() {
    final raw = _box.get(HiveBoxes.playerKey);
    if (raw is Map) {
      return PlayerProgress.fromMap(raw);
    }
    return const PlayerProgress();
  }

  Future<void> save(PlayerProgress progress) {
    return _box.put(HiveBoxes.playerKey, progress.toMap());
  }

  Future<void> clear() => _box.delete(HiveBoxes.playerKey);

  PlayerProgress applyStreak(PlayerProgress current, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final last = current.lastPlayedDate;
    if (last == null) {
      return current.copyWith(streakDays: 1, lastPlayedDate: today);
    }
    final lastDay = DateTime(last.year, last.month, last.day);
    final diff = today.difference(lastDay).inDays;
    if (diff == 0) return current.copyWith(lastPlayedDate: today);
    if (diff == 1) {
      return current.copyWith(
        streakDays: current.streakDays + 1,
        lastPlayedDate: today,
      );
    }
    return current.copyWith(streakDays: 1, lastPlayedDate: today);
  }

  PlayerProgress recordAttempt(
    PlayerProgress current,
    String phoneme,
    bool correct,
  ) {
    final next = Map<String, PhonemeStat>.from(current.phonemes);
    final key = phoneme.toLowerCase();
    next[key] = current.stat(key).record(correct);
    return current.copyWith(phonemes: next);
  }
}

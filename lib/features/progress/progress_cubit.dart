import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/phonics_engine.dart';
import 'progress_models.dart';
import 'progress_repository.dart';

class ProgressState extends Equatable {
  const ProgressState({required this.player});

  final PlayerProgress player;

  @override
  List<Object?> get props => [player.stars, player.streakDays, player.equippedHat, player.sessionsCompleted, player.levelStars, player.ownedHats, player.parentPin, player.phonemes];
}

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(this._repository)
      : super(ProgressState(player: _repository.load())) {
    tickStreak();
  }

  final ProgressRepository _repository;
  final PhonicsEngine engine = PhonicsEngine();

  Future<void> _persist(PlayerProgress player) async {
    emit(ProgressState(player: player));
    await _repository.save(player);
  }

  Future<void> tickStreak() async {
    await _persist(_repository.applyStreak(state.player, DateTime.now()));
  }

  Future<void> recordAttempt(String phoneme, bool correct) async {
    await _persist(_repository.recordAttempt(state.player, phoneme, correct));
  }

  Future<void> awardStars(int amount) async {
    if (amount <= 0) return;
    await _persist(state.player.copyWith(stars: state.player.stars + amount));
  }

  Future<void> completeLevel({
    required String levelId,
    required int earnedStars,
    required int correctCount,
  }) async {
    final previous = state.player.starsFor(levelId);
    final best = earnedStars > previous ? earnedStars : previous;
    final levels = Map<String, int>.from(state.player.levelStars);
    levels[levelId] = best;
    await _persist(
      state.player.copyWith(
        stars: state.player.stars +
            walletStarsFor(previousBest: previous, earnedStars: earnedStars),
        levelStars: levels,
        sessionsCompleted: state.player.sessionsCompleted + 1,
      ),
    );
  }

  Future<bool> buyHat(String hatId) async {
    final hat = HatCatalog.byId(hatId);
    final player = state.player;
    if (player.ownedHats.contains(hatId)) {
      await _persist(player.copyWith(equippedHat: hatId));
      return true;
    }
    if (player.stars < hat.cost) return false;
    await _persist(
      player.copyWith(
        stars: player.stars - hat.cost,
        ownedHats: [...player.ownedHats, hatId],
        equippedHat: hatId,
      ),
    );
    return true;
  }

  Future<void> equipHat(String hatId) async {
    if (!state.player.ownedHats.contains(hatId)) return;
    await _persist(state.player.copyWith(equippedHat: hatId));
  }

  Future<void> setPin(String pin) async {
    await _persist(state.player.copyWith(parentPin: pin));
  }

  Future<void> resetProgress() async {
    final pin = state.player.parentPin;
    await _persist(PlayerProgress(parentPin: pin));
  }

  LessonRequest nextLetters({int count = 8, List<String>? pool}) {
    return engine.getNextPhonemeLesson(
      state.player.phonemes,
      count: count,
      pool: pool ?? PhonicsCurriculum.stage1Letters,
    );
  }
}

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../shared/letter_block_component.dart';

class LetterCatchGame extends FlameGame {
  LetterCatchGame({
    required this.onGuess,
  });

  final void Function(String letter) onGuess;

  String _target = 'a';
  final List<GlossyBlockComponent> _blocks = [];
  String? _queuedTarget;
  List<String> _queuedOptions = const [];

  @override
  Color backgroundColor() => const Color(0x00000000);

  void _pinCamera() {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
  }

  @override
  Future<void> onLoad() async {
    _pinCamera();
    if (_queuedTarget != null) {
      final target = _queuedTarget!;
      final options = _queuedOptions;
      _queuedTarget = null;
      loadRound(target, options);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _pinCamera();
  }

  void loadRound(String target, List<String> options) {
    if (size.x <= 0 || size.y <= 0) {
      _queuedTarget = target;
      _queuedOptions = options;
      return;
    }
    _target = target.toLowerCase();
    for (final block in _blocks) {
      block.removeFromParent();
    }
    _blocks.clear();

    final letters = [...options.map((e) => e.toLowerCase())];
    if (!letters.contains(_target)) letters.insert(0, _target);
    letters.shuffle();

    final gap = size.x / (letters.length + 1);
    final y = size.y - 90;
    for (var i = 0; i < letters.length; i++) {
      final home = Vector2(gap * (i + 1), y);
      final block = GlossyBlockComponent(
        letter: letters[i],
        color: AppColors.blockFor(letters[i]),
        position: home.clone(),
        home: home,
        onReleased: _handleDrop,
      );
      _blocks.add(block);
      world.add(block);
    }
  }

  void _handleDrop(GlossyBlockComponent block) {
    final mascot = Vector2(size.x / 2, size.y * 0.48);
    final onMascot = block.position.distanceTo(mascot) < 150;
    if (!onMascot) {
      block.position = block.home.clone();
      return;
    }
    onGuess(block.letter);
    block.position = block.home.clone();
  }
}

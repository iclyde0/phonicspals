import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../shared/letter_block_component.dart';

class CvcWordGame extends FlameGame {
  CvcWordGame({
    required this.onPhoneme,
    required this.onWordComplete,
  });

  final void Function(String phoneme) onPhoneme;
  final void Function(bool correct, String built) onWordComplete;

  String _word = 'cat';
  final List<SlotComponent> _slots = [];
  final List<GlossyBlockComponent> _tiles = [];
  bool _checking = false;
  String? _queuedWord;
  List<String> _queuedExtras = const [];

  @override
  Color backgroundColor() => const Color(0x00000000);

  void _pinCamera() {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
  }

  @override
  Future<void> onLoad() async {
    _pinCamera();
    if (_queuedWord != null) {
      final word = _queuedWord!;
      final extras = _queuedExtras;
      _queuedWord = null;
      loadRound(word, extras);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _pinCamera();
  }

  void loadRound(String word, List<String> extras) {
    if (size.x <= 0 || size.y <= 0) {
      _queuedWord = word;
      _queuedExtras = extras;
      return;
    }
    _word = word.toLowerCase();
    _checking = false;
    for (final c in [..._slots, ..._tiles]) {
      c.removeFromParent();
    }
    _slots.clear();
    _tiles.clear();

    final letters = _word.split('');
    final slotY = size.y * 0.28;
    final slotGap = size.x / (letters.length + 1);
    for (var i = 0; i < letters.length; i++) {
      final slot = SlotComponent(
        position: Vector2(slotGap * (i + 1), slotY),
        label: '_',
      );
      _slots.add(slot);
      world.add(slot);
    }

    final pool = [...letters, ...extras.map((e) => e.toLowerCase())]..shuffle();
    final tileGap = size.x / (pool.length + 1);
    for (var i = 0; i < pool.length; i++) {
      final home = Vector2(tileGap * (i + 1), size.y - 90);
      final tile = GlossyBlockComponent(
        letter: pool[i],
        color: AppColors.blockFor(pool[i]),
        position: home.clone(),
        home: home,
        onReleased: _handleDrop,
      );
      _tiles.add(tile);
      world.add(tile);
    }
  }

  void _handleDrop(GlossyBlockComponent tile) {
    if (_checking) {
      tile.position = tile.home.clone();
      return;
    }

    SlotComponent? closest;
    var best = 64.0;
    for (final slot in _slots) {
      if (slot.filled) continue;
      final d = tile.position.distanceTo(slot.position);
      if (d < best) {
        best = d;
        closest = slot;
      }
    }

    if (closest == null) {
      tile.position = tile.home.clone();
      return;
    }

    tile.position = closest.position.clone();
    tile.locked = true;
    closest.filled = true;
    closest.accepted = tile.letter;
    onPhoneme(tile.letter);

    if (_slots.every((slot) => slot.filled)) {
      _checking = true;
      final built = _slots.map((slot) => slot.accepted!).join();
      onWordComplete(built == _word, built);
    }
  }
}

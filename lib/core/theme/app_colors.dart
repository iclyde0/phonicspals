import 'package:flutter/material.dart';

/// Brand palette from the PhonicsPals development plan.
abstract final class AppColors {
  static const primary = Color(0xFFF97316);
  static const primaryDark = Color(0xFFEA580C);
  static const secondary = Color(0xFF0284C7);
  static const secondaryDark = Color(0xFF0369A1);
  static const accent = Color(0xFFF59E0B);
  static const background = Color(0xFFF8FAFC);
  static const canvas = Color(0xFFFFF7ED);
  static const navy = Color(0xFF1E3A8A);
  static const forest = Color(0xFF15803D);
  static const meadow = Color(0xFF86EFAC);
  static const pink = Color(0xFFF472B6);
  static const mascotBody = Color(0xFFF97316);
  static const mascotEarInner = Color(0xFFF9A8D4);
  static const mascotLegs = Color(0xFF38BDF8);
  static const mascotShoes = Color(0xFFFACC15);
  static const mascotHair = Color(0xFF4ADE80);
  static const text = Color(0xFF0F172A);
  static const textMuted = Color(0xFF475569);
  static const card = Color(0xFFFFFFFF);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);

  static const titleLetters = [
    Color(0xFF38BDF8),
    Color(0xFF7DD3FC),
    Color(0xFFF97316),
    Color(0xFFFACC15),
    Color(0xFF1E3A8A),
    Color(0xFF7DD3FC),
    Color(0xFF15803D),
    Color(0xFF22C55E),
    Color(0xFF86EFAC),
    Color(0xFF4ADE80),
    Color(0xFF16A34A),
  ];

  static const blockPalette = [
    Color(0xFFEF4444),
    Color(0xFF22C55E),
    Color(0xFFF472B6),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  static Color blockFor(String glyph) {
    final code = glyph.toLowerCase().codeUnitAt(0);
    return blockPalette[code % blockPalette.length];
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class KidButton extends StatelessWidget {
  const KidButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.icon,
    this.wide = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wide ? double.infinity : null,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: AppTheme.fredoka(size: 20, color: Colors.white),
        ),
        child: Row(
          mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 26),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class GlossyLetter extends StatelessWidget {
  const GlossyLetter({
    super.key,
    required this.letter,
    this.size = 72,
    this.color,
    this.selected = false,
  });

  final String letter;
  final double size;
  final Color? color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? AppColors.blockFor(letter);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(fill, Colors.white, 0.25)!,
            fill,
            Color.lerp(fill, Colors.black, 0.12)!,
          ],
        ),
        border: Border.all(color: Colors.white, width: selected ? 4 : 3),
        boxShadow: [
          BoxShadow(
            color: fill.withValues(alpha: 0.4),
            blurRadius: selected ? 16 : 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: AppTheme.fredoka(size: size * 0.46, color: Colors.white),
        ),
      ),
    );
  }
}

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    const name = 'PhonicsPals';
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < name.length; i++)
            TextSpan(
              text: name[i],
              style: AppTheme.fredoka(
                size: size,
                color: AppColors.titleLetters[i % AppColors.titleLetters.length],
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'mascot_mood.dart';

class MascotWidget extends StatefulWidget {
  const MascotWidget({
    super.key,
    this.mood = MascotMood.idle,
    this.size = 180,
    this.hatId = 'none',
    this.slotLetter,
    this.showSlot = false,
  });

  final MascotMood mood;
  final double size;
  final String hatId;
  final String? slotLetter;
  final bool showSlot;

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _burst;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncMood();
  }

  @override
  void didUpdateWidget(covariant MascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) _syncMood();
  }

  void _syncMood() {
    if (widget.mood == MascotMood.celebrating) {
      _burst.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idle, _burst]),
      builder: (context, _) {
        final idle = sin(_idle.value * pi) * 6;
        final jump = widget.mood == MascotMood.celebrating
            ? -sin(_burst.value * pi) * 18
            : 0.0;
        final tilt = widget.mood == MascotMood.encouraging
            ? sin(_idle.value * pi) * 0.08
            : widget.mood == MascotMood.hinting
                ? 0.12
                : 0.0;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Transform.translate(
            offset: Offset(0, idle + jump),
            child: Transform.rotate(
              angle: tilt,
              child: CustomPaint(
                painter: _MascotPainter(
                  mood: widget.mood,
                  hatId: widget.hatId,
                  slotLetter: widget.showSlot ? widget.slotLetter : null,
                  burst: _burst.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter({
    required this.mood,
    required this.hatId,
    required this.slotLetter,
    required this.burst,
  });

  final MascotMood mood;
  final String hatId;
  final String? slotLetter;
  final double burst;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;
    final bodyW = size.width * 0.52;
    final bodyH = size.height * 0.46;

    if (mood == MascotMood.celebrating) {
      _stars(canvas, size);
    }

    _ear(canvas, Offset(cx - bodyW * 0.28, cy - bodyH * 0.85), true);
    _ear(canvas, Offset(cx + bodyW * 0.28, cy - bodyH * 0.85), false);

    final hair = Path()
      ..moveTo(cx - 10, cy - bodyH * 0.62)
      ..quadraticBezierTo(cx, cy - bodyH * 0.92, cx + 12, cy - bodyH * 0.6);
    canvas.drawPath(
      hair,
      Paint()..color = AppColors.mascotHair,
    );

    _hat(canvas, Offset(cx, cy - bodyH * 0.78), size);

    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: bodyW,
      height: bodyH,
    );
    canvas.drawOval(bodyRect, Paint()..color = AppColors.mascotBody);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - bodyW * 0.12, cy - bodyH * 0.12),
        width: bodyW * 0.42,
        height: bodyH * 0.28,
      ),
      Paint()..color = const Color(0xFFFFEDD5).withValues(alpha: 0.45),
    );

    _face(canvas, Offset(cx, cy - bodyH * 0.08), size);
    _arm(canvas, Offset(cx - bodyW * 0.48, cy), waving: mood != MascotMood.hinting);
    _arm(canvas, Offset(cx + bodyW * 0.42, cy), waving: true, right: true);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 16, cy + bodyH * 0.42),
        width: 18,
        height: 22,
      ),
      Paint()..color = AppColors.mascotLegs,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 16, cy + bodyH * 0.42),
        width: 18,
        height: 22,
      ),
      Paint()..color = AppColors.mascotLegs,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 16, cy + bodyH * 0.54),
        width: 22,
        height: 12,
      ),
      Paint()..color = AppColors.mascotShoes,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 16, cy + bodyH * 0.54),
        width: 22,
        height: 12,
      ),
      Paint()..color = AppColors.mascotShoes,
    );

    if (slotLetter != null && slotLetter!.isNotEmpty) {
      final slot = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + bodyH * 0.08),
          width: size.width * 0.28,
          height: size.width * 0.28,
        ),
        const Radius.circular(16),
      );
      canvas.drawRRect(slot, Paint()..color = const Color(0xFFFACC15));
      canvas.drawRRect(
        slot,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: slotLetter!.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w700,
            fontSize: size.width * 0.16,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(cx - tp.width / 2, cy + bodyH * 0.08 - tp.height / 2),
      );
    }
  }

  void _ear(Canvas canvas, Offset origin, bool left) {
    final ear = Rect.fromCenter(center: origin, width: 28, height: 72);
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(left ? -0.18 : 0.18);
    canvas.translate(-origin.dx, -origin.dy);
    canvas.drawOval(ear, Paint()..color = AppColors.mascotBody);
    canvas.drawOval(
      Rect.fromCenter(center: origin, width: 14, height: 46),
      Paint()..color = AppColors.mascotEarInner,
    );
    canvas.restore();
  }

  void _face(Canvas canvas, Offset center, Size size) {
    final eyePaint = Paint()
      ..color = AppColors.navy
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (mood == MascotMood.celebrating) {
      canvas.drawArc(
        Rect.fromCenter(center: center + const Offset(-16, -4), width: 16, height: 12),
        pi,
        pi,
        false,
        eyePaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: center + const Offset(16, -4), width: 16, height: 12),
        pi,
        pi,
        false,
        eyePaint,
      );
    } else {
      canvas.drawCircle(center + const Offset(-16, -2), 5, Paint()..color = AppColors.navy);
      canvas.drawCircle(center + const Offset(16, -2), 5, Paint()..color = AppColors.navy);
      canvas.drawCircle(center + const Offset(-14, -4), 1.8, Paint()..color = Colors.white);
      canvas.drawCircle(center + const Offset(18, -4), 1.8, Paint()..color = Colors.white);
    }
    canvas.drawCircle(center + const Offset(-18, 10), 6, Paint()..color = const Color(0xFFF9A8D4));
    canvas.drawCircle(center + const Offset(18, 10), 6, Paint()..color = const Color(0xFFF9A8D4));
    canvas.drawArc(
      Rect.fromCenter(center: center + const Offset(0, 8), width: 22, height: 16),
      0.15,
      pi - 0.3,
      false,
      Paint()
        ..color = AppColors.navy
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _arm(Canvas canvas, Offset origin, {required bool waving, bool right = false}) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(right ? (waving ? -0.7 : 0.4) : (waving ? 0.7 : -0.2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -8, 16, 36),
        const Radius.circular(10),
      ),
      Paint()..color = AppColors.mascotBody,
    );
    canvas.drawCircle(const Offset(0, 30), 11, Paint()..color = const Color(0xFFFFEDD5));
    canvas.restore();
  }

  void _hat(Canvas canvas, Offset tip, Size size) {
    switch (hatId) {
      case 'crown':
        final path = Path()
          ..moveTo(tip.dx - 28, tip.dy + 8)
          ..lineTo(tip.dx - 18, tip.dy - 16)
          ..lineTo(tip.dx - 8, tip.dy + 4)
          ..lineTo(tip.dx, tip.dy - 20)
          ..lineTo(tip.dx + 8, tip.dy + 4)
          ..lineTo(tip.dx + 18, tip.dy - 16)
          ..lineTo(tip.dx + 28, tip.dy + 8)
          ..close();
        canvas.drawPath(path, Paint()..color = AppColors.accent);
        break;
      case 'wizard':
        final path = Path()
          ..moveTo(tip.dx, tip.dy - 34)
          ..lineTo(tip.dx - 24, tip.dy + 10)
          ..lineTo(tip.dx + 24, tip.dy + 10)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFF7C3AED));
        canvas.drawCircle(tip + const Offset(6, -8), 4, Paint()..color = AppColors.accent);
        break;
      case 'party':
        final path = Path()
          ..moveTo(tip.dx, tip.dy - 28)
          ..lineTo(tip.dx - 20, tip.dy + 10)
          ..lineTo(tip.dx + 20, tip.dy + 10)
          ..close();
        canvas.drawPath(path, Paint()..color = AppColors.pink);
        canvas.drawCircle(tip + const Offset(0, -28), 6, Paint()..color = AppColors.accent);
        break;
      case 'headphones':
        canvas.drawArc(
          Rect.fromCenter(center: tip + const Offset(0, 18), width: 70, height: 50),
          pi,
          pi,
          false,
          Paint()
            ..color = AppColors.secondary
            ..strokeWidth = 6
            ..style = PaintingStyle.stroke,
        );
        canvas.drawCircle(tip + const Offset(-28, 22), 10, Paint()..color = AppColors.navy);
        canvas.drawCircle(tip + const Offset(28, 22), 10, Paint()..color = AppColors.navy);
        break;
      case 'flower':
        for (var i = 0; i < 5; i++) {
          final angle = i * (2 * pi / 5);
          canvas.drawCircle(
            tip + Offset(cos(angle) * 10, sin(angle) * 10 - 6),
            7,
            Paint()..color = AppColors.pink,
          );
        }
        canvas.drawCircle(tip + const Offset(0, -6), 5, Paint()..color = AppColors.accent);
        break;
    }
  }

  void _stars(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.accent.withValues(alpha: 1 - burst);
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final r = 20 + burst * size.width * 0.38;
      final p = Offset(size.width / 2 + cos(angle) * r, size.height * 0.35 + sin(angle) * r);
      _star(canvas, p, 7 + burst * 5, paint);
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? r : r / 2.3;
      final angle = -pi / 2 + i * pi / 5;
      final p = Offset(c.dx + cos(angle) * radius, c.dy + sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.hatId != hatId ||
        oldDelegate.slotLetter != slotLetter ||
        oldDelegate.burst != burst;
  }
}

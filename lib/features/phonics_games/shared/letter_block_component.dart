import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class GlossyBlockComponent extends PositionComponent with DragCallbacks {
  GlossyBlockComponent({
    required this.letter,
    required this.color,
    required Vector2 position,
    required this.home,
    required this.onReleased,
    Vector2? size,
  }) : super(
          position: position,
          size: size ?? Vector2.all(72),
          anchor: Anchor.center,
        );

  final String letter;
  final Color color;
  Vector2 home;
  final void Function(GlossyBlockComponent block) onReleased;
  bool locked = false;

  @override
  void onDragStart(DragStartEvent event) {
    if (locked) return;
    super.onDragStart(event);
    priority = 20;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (locked) return;
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (locked) return;
    priority = 0;
    onReleased(this);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (!locked) position = home.clone();
  }

  @override
  void render(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));
    canvas.drawRRect(
      rrect.shift(const Offset(0, 5)),
      Paint()..color = color.withValues(alpha: 0.35),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.28)!,
            color,
            Color.lerp(color, Colors.black, 0.12)!,
          ],
        ).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 6, size.x * 0.55, size.y * 0.22),
        const Radius.circular(12),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: letter.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontWeight: FontWeight.w700,
          fontSize: size.x * 0.46,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }

  @override
  bool containsLocalPoint(Vector2 point) =>
      !locked && super.containsLocalPoint(point);
}

class SlotComponent extends PositionComponent {
  SlotComponent({
    required Vector2 position,
    this.label,
    Vector2? size,
  }) : super(
          position: position,
          size: size ?? Vector2.all(78),
          anchor: Anchor.center,
        );

  String? label;
  bool filled = false;
  String? accepted;

  @override
  void render(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = filled
            ? const Color(0xFFFDE68A)
            : Colors.white.withValues(alpha: 0.7),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
    if (label != null && !filled) {
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 28,
            color: Color(0xFF94A3B8),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
    }
  }
}

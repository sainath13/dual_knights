import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class RoundedBackgroundComponent extends PositionComponent {
  final Paint backgroundPaint;
  final double borderRadius;

  RoundedBackgroundComponent({
    required Vector2 size,
    required this.backgroundPaint,
    this.borderRadius = 16.0,
    super.position,
    super.anchor,
  }) {
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Define the rectangle bounds
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Create a rounded rectangle
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Draw the rounded rectangle
    canvas.drawRRect(rrect, backgroundPaint);
  }
}

// lib/components/level_button_component.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class LevelButtonComponent extends PositionComponent with TapCallbacks {
  final String levelName;
  final void Function(String) onPressed;
  final int starsEarned;
  late final TextComponent textComponent;
  late final List<SpriteComponent> stars;
  late final SpriteComponent background;

  LevelButtonComponent({
    required this.levelName,
    required this.onPressed,
    required Vector2 position,
    required Vector2 size,
    this.starsEarned = 0,
  }) {
    this.position = position;
    this.size = size;
  }

  String _formatLevelName(String levelName) {
    final numbers = RegExp(r'\d+').firstMatch(levelName)?.group(0) ?? '';
    return numbers.padLeft(2, '0');
  }

  @override
  Future<void> onLoad() async {
    // Background
    final bgSprite = await Sprite.load('UI/Banners/Banner_Horizontal.png');
    background = SpriteComponent(
      sprite: bgSprite,
      size: size,
      position: Vector2.zero(),
    );
    add(background);

    // Responsive text size based on button width
    final fontSize = size.x * 0.3; // 30% of button width
    textComponent = TextComponent(
      text: _formatLevelName(levelName),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.5),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(textComponent);

    // Stars
    final starSprite = await Sprite.load('UI/Ribbons/Ribbon_Yellow_Connection_Up.png');
    stars = [];
    
    // Responsive star size (15% of button width)
    final starSize = Vector2(size.x * 0.15, size.x * 0.15);
    // Spacing between stars (5% of button width)
    final starSpacing = size.x * 0.05;
    // Total width of all stars and spacing
    final totalStarsWidth = (starSize.x * 3) + (starSpacing * 2);
    // Starting X position to center stars
    final startX = (size.x - totalStarsWidth) / 2;
    
    for (var i = 0; i < 3; i++) {
      if (i < starsEarned) {
        final star = SpriteComponent(
          sprite: starSprite,
          size: starSize,
          position: Vector2(
            startX + (i * (starSize.x + starSpacing)),
            size.y - starSize.y + (size.y * 0.05), // 10% padding from bottom
          ),
        );
        stars.add(star);
        add(star);
      }
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    onPressed(levelName);
    return true;
  }
}
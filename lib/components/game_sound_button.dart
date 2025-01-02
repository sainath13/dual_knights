import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class GameSoundButton extends PositionComponent with TapCallbacks, HasGameReference {
  final Sprite spriteOn; // Sprite for the "ON" state
  final Sprite spriteOff; // Sprite for the "OFF" state
  final ValueChanged<bool>? onToggle; // Callback when toggled
  final String buttonText; // Text to display below the button
  bool isSoundOn; // Tracks current state (true for ON, false for OFF)

  late SpriteComponent _spriteComponent;
  late TextComponent _textComponent;

  GameSoundButton({
    required this.spriteOn,
    required this.spriteOff,
    required this.onToggle,
    required this.isSoundOn,
    required this.buttonText,
    required Vector2 size,
    required Vector2 position,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // Initialize the button sprite based on the current state
    _spriteComponent = SpriteComponent(
      sprite: isSoundOn ? spriteOn : spriteOff,
      size: size,
    );
    add(_spriteComponent);

    // Add text below the sprite
    _textComponent = TextComponent(
      text: buttonText,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, size.y + 5), // Position below the sprite
    );
    add(_textComponent);
  }

  @override
  bool onTapDown(TapDownEvent info) {
    // Toggle the state
    isSoundOn = !isSoundOn;

    // Update the sprite based on the new state
    _spriteComponent.sprite = isSoundOn ? spriteOn : spriteOff;

    // Trigger the callback with the new state
    if (onToggle != null) {
      onToggle!(isSoundOn);
    }
    return true;
  }
}

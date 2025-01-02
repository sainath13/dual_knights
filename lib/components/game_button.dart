import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class GameButton extends PositionComponent with  TapCallbacks, HasGameReference {
  final Sprite? normalSprite;
  final Sprite? onTapSprite;
  final VoidCallback? onClick;
  final String buttonText;
  late TextComponent _textComponent;

  SpriteComponent? _spriteComponent;

  GameButton({
    this.normalSprite,
    this.onTapSprite,
    required this.onClick,
    required Vector2 size,
    required Vector2 position,
    required this.buttonText,
  }) {
    this.size = size;
    this.position = position;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // If sprites are provided, use them; otherwise, render only the text
    if (normalSprite != null && onTapSprite != null) {
      _spriteComponent = SpriteComponent(
        sprite: normalSprite,
        size: size,
      );
      add(_spriteComponent!);
    }

    // Add the text component
    _textComponent = TextComponent(
      text: buttonText,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_textComponent);
  }

  @override
  bool onTapDown(TapDownEvent info) {
 

      // Change sprite if provided
    if (onTapSprite != null && _spriteComponent != null) {
      _spriteComponent!.sprite = onTapSprite;
    }
    
    return true;
  }



  @override
  void onTapCancel(TapCancelEvent event) {
    // Revert back to the normal sprite if provided
    if (normalSprite != null && _spriteComponent != null) {
      _spriteComponent!.sprite = normalSprite;
    }
    onClick!();

  }
}

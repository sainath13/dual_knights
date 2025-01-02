import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

class GameButton extends PositionComponent with TapCallbacks, HasGameReference {
  final Sprite normalSprite;
  final Sprite onTapSprite;
  final Function() onClick;
  final String buttonText; // Button text

  late SpriteComponent _spriteComponent;
  late TextComponent _textComponent;

  GameButton({
    required this.normalSprite,
    required this.onTapSprite,
    required this.onClick,
    required Vector2 size,
    required Vector2 position,
    required this.buttonText, // Optional custom text style
  })  : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // Initialize the button sprite
    _spriteComponent = SpriteComponent(
      sprite: normalSprite,
      size: size,
    );
    add(_spriteComponent);

    // Initialize the button text
    _textComponent = TextComponent(
      text: buttonText,
      
      anchor: Anchor.center,
      position: size / 2, // Center the text within the button
    );
    add(_textComponent);
  }

  @override
  bool onTapDown(TapDownEvent info) {
    // Change to the onTap sprite when clicked
    _spriteComponent.sprite = onTapSprite;
    return true;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // Revert to the normal sprite if the tap is canceled
    _spriteComponent.sprite = normalSprite;
     onClick();
  }
}

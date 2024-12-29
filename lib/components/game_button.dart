import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';

class GameButton extends PositionComponent with HasGameRef, TapCallbacks {
  // Button properties
  final String baseImagePath;
  final String tapImagePath;
  final String buttonText;
  final Vector2 buttonSize;
  final Function() onTap;

  // Components
  late SpriteComponent _baseImage;
  late SpriteComponent _tapImage;
  late TextComponent _textComponent;
  bool _isTapped = false;

  GameButton({
    required this.baseImagePath,
    required this.tapImagePath,
    required this.buttonText,
    required this.buttonSize,
    required this.onTap,
    required Vector2 position,
  }) : super(position: position, size: buttonSize);

  @override
  Future<void> onLoad() async {
    // Load base image
    final baseSprite = await game.images.load(baseImagePath);
    _baseImage = SpriteComponent(
      sprite: Sprite(baseSprite),
      size: size,
    );
    add(_baseImage);

    // Load tap effect image
    final tapSprite = await game.images.load(tapImagePath);
    _tapImage = SpriteComponent(
      sprite: Sprite(tapSprite),
      size: size,
      // opacity: 0,  // Initially invisible
    );
    add(_tapImage);

    // Create text component
    final regular = TextPaint(
      style: const TextStyle(
        fontSize: 32.0,
        // color: Color(0xFFFFFFFF),  // White color
      ),
    );

    _textComponent = TextComponent(
      text: buttonText,
      textRenderer: regular,
      anchor: Anchor.center,
    );

    // Center the text on the button
    _textComponent.position = Vector2(
      size.x / 2,
      size.y / 2,
    );

    add(_textComponent);
  }

  @override
  bool onTapDown(TapDownEvent event) {
    log("Buttons is tapped");
    _isTapped = true;
    _tapImage.opacity = 1.0;  // Show tap effect
    return true;
  }

  // @override
  // bool onTapUp(TapUpEvent event) {
  //   log("Buttons is tapped up");
  //   _isTapped = false;
  //   _tapImage.opacity = 0.0;  // Hide tap effect
  //   onTap();  // Execute tap callback
  //   return true;
  // }

  // @override
  // void onTapUp(TapUpEvent event) {
  //   log("Buttons is tapped up");
  //     _isTapped = false;
  //     _tapImage.opacity = 0.0;  // Hide tap effect
  //     onTap();
  // }
  @override
  void onTapCancel(TapCancelEvent event) {
    log("Tap is canceld");
    _isTapped = false;
    _tapImage.opacity = 0.0;  // Hide tap effect
    onTap();
  }
}
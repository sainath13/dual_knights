import 'dart:ui';

import 'package:dual_knights/dual_knights.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class ArrowKeysComponent extends PositionComponent with HasGameRef<DualKnights>, TapCallbacks {



  final void Function(String direction)? onDirectionPressed;
  late Sprite upSprite;
  late Sprite downSprite;
  late Sprite leftSprite;
  late Sprite rightSprite;
  late Sprite pressedSprite;

  late double buttonSize;
  late double spacing;

  ArrowKeysComponent({
    required this.onDirectionPressed,
    this.buttonSize = 50,
    this.spacing = 10,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    upSprite = Sprite(await gameRef.images.load('UI/Buttons/UpArrow.png'));
    downSprite = Sprite(await gameRef.images.load('UI/Buttons/DownArrow.png'));
    leftSprite = Sprite(await gameRef.images.load('UI/Buttons/LeftArrow.png'));
    rightSprite = Sprite(await gameRef.images.load('UI/Buttons/RightArrow.png'));
    pressedSprite = Sprite(await gameRef.images.load('UI/Buttons/ArrowPressed.png'));

    // Add directional buttons
    add(_createArrowButton(Vector2(0, -1), "up", upSprite, pressedSprite));
    add(_createArrowButton(Vector2(0, 1), "down", downSprite, pressedSprite));
    add(_createArrowButton(Vector2(-1, 0), "left", leftSprite, pressedSprite));
    add(_createArrowButton(Vector2(1, 0), "right", rightSprite, pressedSprite));
  }

  PositionComponent _createArrowButton(
    Vector2 offset,
    String direction,
    Sprite normalSprite,
    Sprite pressedSprite,
  ) {
    return _ArrowButton(
      size: Vector2(buttonSize, buttonSize),
      position: Vector2((buttonSize + spacing) * offset.x, (buttonSize + spacing) * offset.y),
      normalSprite: normalSprite,
      pressedSprite: pressedSprite,
      anchor: Anchor.center,
      onPressed: () => onDirectionPressed?.call(direction),
    );
  }
}

class _ArrowButton extends SpriteComponent with TapCallbacks {
  final Sprite normalSprite;
  final Sprite pressedSprite;
  final VoidCallback onPressed;

  _ArrowButton({
    required Vector2 size,
    required Vector2 position,
    required this.normalSprite,
    required this.pressedSprite,
    required Anchor anchor,
    required this.onPressed,
  }) : super(
          size: size,
          position: position,
          sprite: normalSprite,
          anchor: anchor,
        );

  @override
  bool onTapDown(TapDownEvent event) {
    sprite = pressedSprite; // Switch to pressed sprite
    onPressed();
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    sprite = normalSprite; // Revert to normal sprite
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    sprite = normalSprite; // Revert to normal sprite if tap is canceled
    return true;
  }
}

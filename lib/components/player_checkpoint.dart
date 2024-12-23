import 'dart:developer';

import 'package:dual_knights/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class PlayerCheckpoint extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  static const double gridSize = 64.0;

  late SpriteAnimation pressedAnimation;
  late SpriteAnimation unpressedAnimation;

  bool isPressed = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Define the hitbox
    final hitbox = RectangleHitbox(
      size: Vector2(64-2, 64-2),
      position: Vector2.all(1),
    )..debugMode = true;
    await add(hitbox);

    // Load button animations
    final buttonPressedImage = await gameRef.images.load('UI/Buttons/Button_Blue_Pressed.png');
    final buttonUnpressedImage = await gameRef.images.load('UI/Buttons/Button_Blue.png');

    pressedAnimation = SpriteAnimation.fromFrameData(
      buttonPressedImage,
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(gridSize),
        stepTime: 0.1,
        loop: true,
      ),
    );

    unpressedAnimation = SpriteAnimation.fromFrameData(
      buttonUnpressedImage,
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(gridSize),
        stepTime: 0.1,
        loop: true,
      ),
    );

    // Set the default animation
    animation = unpressedAnimation;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      isPressed = true;
      animation = pressedAnimation;
      log("PlayerCheckpoint: Player reached checkpoint");
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    if (other is Player) {
      isPressed = false;
      animation = unpressedAnimation;
      log("PlayerCheckpoint: Player left checkpoint");
    }
  }
}

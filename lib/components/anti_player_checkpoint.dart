import 'dart:developer';

import 'package:dual_knights/components/anti_player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class AntiPlayerCheckpoint extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  static const double gridSize = 64.0;

  late SpriteAnimation pressedAnimation;
  late SpriteAnimation unpressedAnimation;
  late SpriteAnimation artifactAnimation;
  late SpriteAnimationComponent artifactComponent;


  bool isPressed = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Define the hitbox
    final hitbox = RectangleHitbox(
      size: Vector2(64-2, 64-2),
      position: Vector2.all(1),
    );//..debugMode = true;
    await add(hitbox);

    // Load button animations
    final buttonPressedImage = await gameRef.images.load('UI/Buttons/Button_Red_Pressed.png');
    final buttonUnpressedImage = await gameRef.images.load('UI/Buttons/Button_Red.png');
    final wakeRangeArtifactImage = await gameRef.images.load('Effects/Checkpoint/Obelisk_Blue_Effects.png');

    pressedAnimation = SpriteAnimation.fromFrameData(
      buttonPressedImage,
      SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2.all(gridSize),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, -7)
      ),
    );

    unpressedAnimation = SpriteAnimation.fromFrameData(
      buttonUnpressedImage,
      SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2.all(gridSize),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, -7)
      ),
    );

    artifactAnimation = SpriteAnimation.fromFrameData(
      wakeRangeArtifactImage,
      SpriteAnimationData.sequenced(
        amount: 14,
        textureSize: Vector2(190,380),
        stepTime: 0.1,
        loop: true,
      ),
    );

    artifactComponent = SpriteAnimationComponent(
      animation: artifactAnimation,
      size: Vector2(47.5,60),
      position: this.position + Vector2(8,-16),
      priority: 14, // Position above the checkpoint
    );
    // artifactComponent.opacity = 0;
    await parent?.add(artifactComponent);
    // Set the default animation
    animation = unpressedAnimation;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is AntiPlayer) {
      isPressed = true;
      animation = pressedAnimation;
      log("AntiPlayerCheckpoint: AntiPlayer reached checkpoint");
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    if (other is AntiPlayer) {
      isPressed = false;
      animation = unpressedAnimation;
      log("AntiPlayerCheckpoint: AntiPlayer left checkpoint");
    }
  }
}

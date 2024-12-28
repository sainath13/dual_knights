import 'dart:developer';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Gold extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  static const double gridSize = 128.0;

  late SpriteAnimation idleAnimation;
  late SpriteAnimation collectedAnimation;
  bool isCollected = false;

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
    final idleImage = await gameRef.images.load('Deco/06.png');
    final collectedImage = await gameRef.images.load('Resources/Resources/G_Spawn.png');

    // idleAnimation = SpriteAnimation.fromFrameData(
    //   idleImage,
    //   SpriteAnimationData.sequenced(
    //       amount: 1,
    //       textureSize: Vector2.all(gridSize),
    //       stepTime: 0.1,
    //       loop: false,
    //       texturePosition: Vector2(768+32, 32+10)
    //   ),
    // );

    idleAnimation = SpriteAnimation.fromFrameData(
      idleImage,
      SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2.all(64),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0,0)
      ),
    );

    collectedAnimation = SpriteAnimation.fromFrameData(
      collectedImage,
      SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: Vector2.all(gridSize),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(32, 32+10)
      ),
    );
    animation = idleAnimation;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is AntiPlayer || other is Player) {
      animation = collectedAnimation;
      isCollected = true;
      log("Gold: AntiPlayer reached checkpoint");
      //TODO SARVESH : Add gold to stats
      // parent?.remove(this);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check if the collected animation has finished
    if (isCollected &&
        animationTicker != null &&
        animationTicker!.currentIndex == animation!.frames.length - 1) {
      // Remove the component once the animation completes
      removeFromParent();
    }
  }

}

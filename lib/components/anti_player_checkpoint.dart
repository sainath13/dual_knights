import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class AntiPlayerCheckpoint extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  static const double frameWidth = 64;
  static const double frameHeight = 192;
  static const double gridSize = 64.0;

  late SpriteAnimation idleAnimation;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final hitbox = RectangleHitbox(
          size: Vector2(gridSize, gridSize),
          position: Vector2(
            (frameWidth - gridSize) / 2,
            (frameHeight - gridSize) / 2,
          ),
        );
    await add(hitbox);
    final antiPlayerCheckpointSheet = await gameRef.images.load('UI/Buttons/Button_Blue.png');

    idleAnimation = SpriteAnimation.fromFrameData(
      antiPlayerCheckpointSheet,
      SpriteAnimationData.sequenced(
        // texturePosition: Vector2.all(10),
        amount: 1,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
      ),
    );

    animation = idleAnimation;
  }
}
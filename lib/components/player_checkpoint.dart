import 'dart:developer';
import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/anti_player_checkpoint.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/routes/gameplay.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class PlayerCheckpoint extends SpriteAnimationComponent
    with HasGameRef<DualKnights>,CollisionCallbacks, HasAncestor<Gameplay>{
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
    );//..debugMode = true;
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

    // Set the default animation
    animation = unpressedAnimation;
  }

@override
  void update(double dt) {
      // Check if both checkpoints are pressed
      if (isPressed) {
        final antiPlayerCheckpoint = parent?.children.whereType<AntiPlayerCheckpoint>().firstOrNull;
        final player = parent?.children.whereType<Player>().firstOrNull;
        final antiPlayer = parent?.children.whereType<AntiPlayer>().firstOrNull;
        if(player?.isMoving==false && antiPlayer?.isMoving==false && isPressed == true && antiPlayerCheckpoint?.isPressed == true){
          ancestor.input.movementAllowed = false;
          Future.delayed(Duration(milliseconds: 800), () {
            ancestor.onLevelCompleted(3);
          });
          
        }
      }
    super.update(dt);
    
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

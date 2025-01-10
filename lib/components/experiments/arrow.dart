import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/dual_knights.dart';

// enum ArrowState {
//   flying,
//   stuck
// }

// class Arrow extends SpriteAnimationComponent with HasGameRef<DualKnights>, CollisionCallbacks {
//   static const double arrowSpeed = 300.0;
//   static const double frameWidth = 64; // Adjust based on your sprite size
//   static const double frameHeight = 64; // Adjust based on your sprite size
  
//   late final Vector2 direction;
//   late final double angle;
//   bool _hasHit = false;
//   late final SpriteAnimation flyingAnimation;
//   late final SpriteAnimation stuckAnimation;
  
//   Arrow({
//     required Vector2 startPosition,
//     required Vector2 targetPosition,
//   }) : super(
//     size: Vector2(frameWidth, frameHeight),
//     position: startPosition,  priority: 50
//   ) {
//     // Calculate direction and angle
//     direction = (targetPosition - startPosition)..normalize();
//     angle = math.atan2(direction.y, direction.x);
    
//     // Set the rotation of the arrow
//     // angle = angle;
//   }

//   @override
//   Future<void> onLoad() async {
//     // Load sprite sheet
//     final spriteSheet = await gameRef.images.load('Factions/Knights/Troops/Archer/Arrow/Arrow.png'); // Update with your asset path
    
//     // Create flying animation (first frame)
//     flyingAnimation = SpriteAnimation.fromFrameData(
//       spriteSheet,
//       SpriteAnimationData.sequenced(
//         amount: 1,
//         textureSize: Vector2(frameWidth, frameHeight),
//         stepTime: 1,
//         loop: false,
//       ),
//     );
    
//     // Create stuck animation (second frame)
//     stuckAnimation = SpriteAnimation.fromFrameData(
//       spriteSheet,
//       SpriteAnimationData.sequenced(
//         amount: 1,
//         textureSize: Vector2(frameWidth, frameHeight),
//         stepTime: 1,
//         loop: false,
//         texturePosition: Vector2(0, frameHeight),
//       ),
//     );
    
//     // Set initial animation
//     animation = flyingAnimation;
    
//     // Add hitbox
//     final hitbox = RectangleHitbox(
//       size: Vector2(frameWidth * 0.8, frameHeight * 0.3), // Smaller than sprite for better collision
//       position: Vector2(frameWidth * 0.1, frameHeight * 0.35), // Center the hitbox
//     );
//     add(hitbox);
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     if (!_hasHit) {
//       // Move the arrow
//       position += direction * arrowSpeed * dt;
      
//       // Remove arrow if it goes too far off screen
//       if (position.x < -100 || position.x > gameRef.size.x + 100 ||
//           position.y < -100 || position.y > gameRef.size.y + 100) {
//         removeFromParent();
//       }
//     }
//   }

//   @override
//   void onCollisionStart(
//     Set<Vector2> intersectionPoints,
//     PositionComponent other,
//   ) {
//     super.onCollisionStart(intersectionPoints, other);
    
//     if (!_hasHit && (other is Player || other is AntiPlayer)) {
//       _hasHit = true;
//       animation = stuckAnimation;
//       // Optionally deal damage to the player here
      
//       // Remove arrow after a delay
//       Future.delayed(const Duration(seconds: 1), () {
//         removeFromParent();
//       });
//     }
//   }
// }



class Arrow extends SpriteAnimationComponent with HasGameRef<DualKnights>, CollisionCallbacks {
  static const double arrowSpeed = 700.0;
  static const double frameWidth = 64;
  static const double frameHeight = 64;
  
  late final Vector2 direction;
  bool _hasHit = false;
  late final SpriteAnimation flyingAnimation;
  late final SpriteAnimation stuckAnimation;
  
  Arrow({
    required Vector2 startPosition,
    required Vector2 targetPosition,
  }) : super(
    size: Vector2(frameWidth, frameHeight),
    position: startPosition,
    priority : 10,
    anchor: Anchor.center, // Set anchor to center for better rotation
  ) {
    // Calculate direction and angle
    direction = (targetPosition - startPosition)..normalize();
    
    // Calculate angle in radians for the arrow rotation
    // Subtract π/2 because our arrow sprite points right (0 degrees),
    // but Flame's 0 degrees points up
    angle = math.atan2(direction.y, direction.x);
  }

  @override
  Future<void> onLoad() async {
        final spriteSheet = await gameRef.images.load('Factions/Knights/Troops/Archer/Arrow/Arrow.png'); // Update with your asset path
    
    flyingAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 1,
        loop: false,
      ),
    );
    
    stuckAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 1,
        loop: false,
        texturePosition: Vector2(0, frameHeight),
      ),
    );
    
    animation = flyingAnimation;
    
    // Add hitbox with center anchor to match sprite
    final hitbox = RectangleHitbox(
      size: Vector2(frameWidth * 0.8, frameHeight * 0.3),
      position: Vector2(frameWidth * 0.1, frameHeight * 0.35),
      anchor: Anchor.center,
    );
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_hasHit) {
      // Move the arrow
      position += direction * arrowSpeed * dt;
      
      // Remove arrow if it goes too far off screen
      if (position.x < -100 || position.x > gameRef.size.x + 100 ||
          position.y < -100 || position.y > gameRef.size.y + 100) {
        removeFromParent();
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (!_hasHit && (other is Player || other is AntiPlayer)) {
      _hasHit = true;
      animation = stuckAnimation;
      
      // // Remove arrow after a delay
      // Future.delayed(const Duration(seconds: 1), () {
      //   removeFromParent();
      // });
    }
  }
}
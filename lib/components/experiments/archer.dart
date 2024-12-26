import 'dart:developer' as developer;
import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/experiments/arrow.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'dart:math' as math;


enum ArcherState {
  idle,
  shootUp,
  shootDiagonalUp,
  shootFront,
  shootDiagonalDown,
  shootDown,
}

class Archer extends SpriteAnimationComponent with HasGameRef<DualKnights>, CollisionCallbacks {
  static const double frameWidth = 192;
  static const double frameHeight = 192;
  static const double gridSize = 64.0;
  // late final Map<ArcherState, SpriteAnimation> animations;
  ArcherState state = ArcherState.idle;
  Vector2 currentPosition = Vector2.zero();
  Vector2? targetPosition;
  bool _facingLeft = false;

  static const double shootCooldown = 1.5; // Seconds between shots
  double _timeSinceLastShot = 0;
  bool _canShoot = true;

  Archer() : super(size: Vector2(frameWidth, frameHeight), priority: 5) {
    currentPosition = position.clone();
  }
  late SpriteAnimation idleAnimation;
  late SpriteAnimation shootUpAnimation;
  late SpriteAnimation shootDiagonalUpAnimation;
  late SpriteAnimation shootFrontAnimation;
  late SpriteAnimation shootDiagonalDownAnimation;
  late SpriteAnimation shootDownAnimation;

  bool hasCollided = false;
  @override
  Future<void> onLoad() async {
    super.onLoad();
    //note for postion
            // Archer archer = Archer()..debugMode = true;
            // archer.position = Vector2(spawnPoint.x + 32, spawnPoint.y + 32);
            // archer.anchor = Anchor.center;
            // add(archer);
    final newHitbox = RectangleHitbox(
      size: Vector2(64*4, 64*4),
      position: Vector2(currentPosition.x-64, currentPosition.y-64),
    )..debugMode = true;
    add(newHitbox);
    // Load the sprite sheet
    final spriteSheet = await gameRef.images.load('Factions/Knights/Troops/Archer/Purple/Archer_Purple.png');

    // Define animations
    idleAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        texturePosition: Vector2.all(0),
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
      ),
    );

    shootUpAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, frameHeight * 2),
      ),
    );

    shootDiagonalUpAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, frameHeight * 3),
      ),
    );
    shootFrontAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, frameHeight * 4),
      ),
    );
    shootDiagonalDownAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, frameHeight * 5),
      ),
    );

    shootDownAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, frameHeight * 6),
      ),
    );
    animation = idleAnimation;
    }//onload

  SpriteAnimation _getAnimationForState(ArcherState state) {
    switch (state) {
      case ArcherState.idle:
        return idleAnimation;
      case ArcherState.shootUp:
        return shootUpAnimation;
      case ArcherState.shootDiagonalUp:
        return shootDiagonalUpAnimation;
      case ArcherState.shootFront:
        return shootFrontAnimation;
      case ArcherState.shootDiagonalDown:
        return shootDiagonalDownAnimation;
      case ArcherState.shootDown:
        return shootDownAnimation;
    }
  }

  // void _shoot() {
  //   if (!_canShoot || targetPosition == null) return;
    
  //   // Calculate arrow spawn position (adjust these offsets based on your sprite)
  //   final arrowOffset = Vector2(-196, -196);
  //   if (_facingLeft) {
  //     arrowOffset.x *= -1;
  //   }
    
  //   final arrowSpawnPos = position + arrowOffset;
  //   developer.log("when archer posiont is $position Arrow spawn position: $arrowSpawnPos", name: "Archer");
    
  //   // Create and add arrow
  //   final arrow = Arrow(
  //     startPosition: arrowSpawnPos,
  //     targetPosition: targetPosition!,
  //   );
    
  //   gameRef.add(arrow);
    
  //   // Start cooldown
  //   _canShoot = false;
  //   _timeSinceLastShot = 0;
  // }

void _shoot() {
  if (!_canShoot || targetPosition == null) return;
  
  // Calculate spawn position based on archer state and direction
  final Vector2 arrowSpawnPos = position.clone();
  
  // // Center offset (since position is at top-left of sprite)
  // arrowSpawnPos.x += frameWidth / 2;  // 96 pixels from left
  // arrowSpawnPos.y += frameHeight / 2; // 96 pixels from top
  
  // Adjust based on shooting direction
  // switch (state) {
  //   case ArcherState.shootUp:
  //     arrowSpawnPos.y -= 60; // Spawn above
  //     break;
  //   case ArcherState.shootDiagonalUp:
  //     arrowSpawnPos.x += _facingLeft ? -40 : 40;
  //     arrowSpawnPos.y -= 40;
  //     break;
  //   case ArcherState.shootFront:
  //     arrowSpawnPos.x += _facingLeft ? -60 : 60; // Spawn left/right based on facing
  //     break;
  //   case ArcherState.shootDiagonalDown:
  //     arrowSpawnPos.x += _facingLeft ? -40 : 40;
  //     arrowSpawnPos.y += 40;
  //     break;
  //   case ArcherState.shootDown:
  //     arrowSpawnPos.y += 60; // Spawn below
  //     break;
  //   case ArcherState.idle:
  //     return; // Don't shoot while idle
  // }
  
  // Create and add arrow
  final arrow = Arrow(
    startPosition: arrowSpawnPos - Vector2(-320,32),
    targetPosition: targetPosition!,
  );
  
  gameRef.add(arrow);
  
  // Start cooldown
  _canShoot = false;
  _timeSinceLastShot = 0;
}

  void _updateState() {
    if (!hasCollided || targetPosition == null) return;

    // Calculate the angle between archer and target
    final deltaX = targetPosition!.x - position.x;
    final deltaY = targetPosition!.y - position.y;
    double angle = math.atan2(deltaY, deltaX) * (180 / math.pi);

    // Normalize angle to 0-360 range
    if (angle < 0) angle += 360;

    // Update facing direction
    _facingLeft = deltaX < 0;
    // Use the proper way to flip the sprite
    if (_facingLeft) {
      transform.scale.x = -1;
    } else {
      transform.scale.x = 1;
    }

    // Determine animation based on angle
    ArcherState newState;
    if (angle >= 337.5 || angle < 22.5) {
      developer.log("Archer is shooting up with $_facingLeft");
      newState = ArcherState.shootFront;
    } else if (angle >= 22.5 && angle < 67.5) {
      developer.log("Archer is shooting diagonal down with $_facingLeft");
      newState = ArcherState.shootDiagonalDown;
    } else if (angle >= 67.5 && angle < 112.5) {
      developer.log("Archer is shooting Down with $_facingLeft");
      newState = ArcherState.shootDown;
    } else if (angle >= 112.5 && angle < 157.5) {
      developer.log("Archer is shooting diagonal down with $_facingLeft");
      newState = ArcherState.shootDiagonalDown;
    } else if (angle >= 157.5 && angle < 202.5) {
      developer.log("Archer is shooting front with $_facingLeft");
      newState = ArcherState.shootFront;
    } else if (angle >= 202.5 && angle < 247.5) {
      developer.log("Archer is shooting diagonal up with $_facingLeft");
      newState = ArcherState.shootDiagonalUp;
    } else if (angle >= 247.5 && angle < 292.5) {
            developer.log("Archer is shooting up with $_facingLeft");
      newState = ArcherState.shootUp;
    } else {
      developer.log("Archer is ELSE shootDiagonalUp with $_facingLeft");
      newState = ArcherState.shootDiagonalUp;
    }

    // Only update animation if state changed
    if (state != newState) {
      state = newState;
      animation = _getAnimationForState(state);
      animationTicker?.reset();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is AntiPlayer || other is Player) {
      hasCollided = true;
      targetPosition = intersectionPoints.first;
      developer.log("Archer detected collision with ${other.runtimeType}");
    } else {
      developer.log("Archer detected useless collision");
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateState();

    if (!_canShoot) {
      _timeSinceLastShot += dt;
      if (_timeSinceLastShot >= shootCooldown) {
        _canShoot = true;
      }
    }
    
    // Shoot if we can and have a target
    if (_canShoot && hasCollided && targetPosition != null) {
      _shoot();
    }

  }

}
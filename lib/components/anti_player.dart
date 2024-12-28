import 'package:dual_knights/components/anti_player_checkpoint.dart';
import 'package:dual_knights/components/collision_block.dart';
import 'package:dual_knights/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

class AntiPlayer extends SpriteAnimationComponent with HasGameRef, KeyboardHandler, CollisionCallbacks {
  static const double frameWidth = 192;
  static const double frameHeight = 192;
  static const double gridSize = 64.0;
  
  bool isMoving = false;
  Vector2 targetPosition = Vector2.zero();

  List<CollisionBlock> collisionBlocks = [];

  void setCollisionBlocks(List<CollisionBlock> blocks) {
    collisionBlocks = blocks;
  }
  // Animations
  late SpriteAnimation idleAnimation;
  late SpriteAnimation moveUpAnimation;
  late SpriteAnimation moveDownAnimation;
  late SpriteAnimation moveLeftAnimation;
  late SpriteAnimation moveRightAnimation;
  late SpriteAnimation fightAnimation;
  late SpriteAnimation glowAnimation;

  final double speed = 150.0;
  Vector2 direction = Vector2.zero();

  final Set<LogicalKeyboardKey> _pressedKeys = {};

  AntiPlayer() : super(size: Vector2(frameWidth, frameHeight), priority: 5) {
    targetPosition = position.clone();
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final hitbox = RectangleHitbox(
      size: Vector2(64-4, 64-4),
      position: Vector2(
        64,
        64
      ),
    );//..debugMode = true;
    add(hitbox);
    final spriteSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red.png');
    final idleSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_Idle.png');
    final downSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_walk_down.png');
    final leftSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_walk_left.png');
    final upSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_walk_up.png');
    final explosionSheet = await gameRef.images.load('Effects/Explosion/Explosions.png');
    final glowSheet =  await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_Glow.png');
  
  
    log("Keeping animations loaded");
    idleAnimation = SpriteAnimation.fromFrameData(
      idleSheet,
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0,16),
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
      ),
    );

    moveUpAnimation = SpriteAnimation.fromFrameData(
      upSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, 16),
      ),
    );

    moveDownAnimation = SpriteAnimation.fromFrameData(
      downSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, 16),
      ),
    );

    moveLeftAnimation = SpriteAnimation.fromFrameData(
      leftSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, 16),
      ),
    );

    moveRightAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, frameHeight + 16),
      ),
    );
    // Set initial animation
    
    fightAnimation = SpriteAnimation.fromFrameData(
      explosionSheet,
      SpriteAnimationData.sequenced(
        amount: 9,
        textureSize: Vector2(192, 192),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, 16),
      ),
    );
    glowAnimation = SpriteAnimation.fromFrameData(
      glowSheet,
      SpriteAnimationData.sequenced(
        amount: 9,
        textureSize: Vector2(192, 192),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, 16),
      ),
    );

    animation = idleAnimation;
  }
  
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // if(true) return true; //TODO : Remove this line
    if (isMoving) return true;
    _pressedKeys.clear();
    _pressedKeys.addAll(keysPressed);
    if (keysPressed.contains(LogicalKeyboardKey.keyW) || 
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      startGridMove(Vector2(0, 1));  // Player goes up, AntiPlayer goes down
    } else if (keysPressed.contains(LogicalKeyboardKey.keyS) || 
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      startGridMove(Vector2(0, -1));  // Player goes down, AntiPlayer goes up
    } else if (keysPressed.contains(LogicalKeyboardKey.keyA) || 
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      startGridMove(Vector2(1, 0));  // Player goes left, AntiPlayer goes right
    } else if (keysPressed.contains(LogicalKeyboardKey.keyD) || 
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      startGridMove(Vector2(-1, 0));  // Player goes right, AntiPlayer goes left
    }

    return true;
  }


  void startGridMove(Vector2 dir) {
    if (!isMoving) {
      direction = dir;
      Vector2 potentialTarget = position + (direction * gridSize);
      if (!wouldCollide(potentialTarget)) {
        targetPosition = potentialTarget;
        isMoving = true;
        if (direction.y < 0) {
          animation = moveUpAnimation;
        } else if (direction.y > 0) {
          animation = moveDownAnimation;
        } else if (direction.x < 0) {
          animation = moveLeftAnimation;
        } else if (direction.x > 0) {
          animation = moveRightAnimation;
        }
      }
    }
  }
  
  bool wouldCollide(Vector2 newPosition) {  
    double futureX = newPosition.x;
    double futureY = newPosition.y;
    for (final block in collisionBlocks) {
      double blockLeft = block.position.x;
      if(futureX < blockLeft) {continue;}
      double blockRight = blockLeft + block.size.x;
      if(futureX > blockRight) {continue;}
      double blockTop = block.position.y;
      if(futureY < blockTop) {continue;}
      double blockBottom = blockTop + block.size.y;
      if(futureY > blockBottom) {continue;}
      return true;
    }
    
    return false;
  }


  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      log("Player collided with AntiPlayer");
      animation = fightAnimation;  
    }
    else if(other is AntiPlayerCheckpoint ){
      log("Player collided with Checkpoint.");
      animation = glowAnimation;
    }
    
  }


  @override
  void update(double dt) {
    super.update(dt);
    // log("AntiPlayer priority is $priority");

    if (isMoving) {
      final movement = direction * speed * dt;
      final distanceToTarget = targetPosition - position;
      final distanceThisFrame = movement.length;
      
      if (distanceThisFrame >= distanceToTarget.length) {
        position = targetPosition;
        isMoving = false;
        direction = Vector2.zero();
        animation = idleAnimation;
      } else {
        position += movement;
      }
    }
  }
}
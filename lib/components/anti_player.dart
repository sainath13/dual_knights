import 'package:dual_knights/components/collision_block.dart';
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

// Add a list to store collision blocks
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

  final double speed = 150.0;
  Vector2 direction = Vector2.zero();
  // Keep track of pressed keys
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  AntiPlayer() : super(size: Vector2(frameWidth, frameHeight)) {
    targetPosition = position.clone();
    // log("Antiplayer is created");
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
    )..debugMode = true;
    add(hitbox);
    final spriteSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red.png');
    // Use the same animation setup as Player but with red warrior sprites
    
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

    moveUpAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, frameHeight * 1),
      ),
    );

    moveDownAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, frameHeight * 2),
      ),
    );

    moveLeftAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, frameHeight * 3),
      ),
    );

    moveRightAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, frameHeight * 4),
      ),
    );
    // Set initial animation

    animation = idleAnimation;
  }
  
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (isMoving) return true;
    _pressedKeys.clear();
    _pressedKeys.addAll(keysPressed);
    // Use the same keys as Player but move in opposite direction
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
      // Calculate the potential target position
      Vector2 potentialTarget = position + (direction * gridSize);
      
      // Check if the move would result in a collision
      if (!wouldCollide(potentialTarget)) {
        targetPosition = potentialTarget;
        isMoving = true;
        
        // Set appropriate animation
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
    // Calculate the future bounds of the player
    // log("new position would be $newPosition");
    double futureX = newPosition.x;
    double futureY = newPosition.y;
  
    // log("position of future is $futureLeft $futureRight $futureTop $futureBottom");
    // Check collision with all collision blocks
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
      // log("Block size is bounded by $blockLeft $blockRight $blockTop $blockBottom");
      // Basic rectangle collision detection
      // if (futureX < blockRight &&
      //     futureX > blockLeft &&
      //     futureY < blockBottom &&
      //     futureY > blockTop) {
      //       // log("You can not move here");
      //   return true;
      // }
    }
    
    return false;
  }
  @override
  void update(double dt) {
    super.update(dt);

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
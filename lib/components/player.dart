import 'dart:developer';

import 'package:dual_knights/components/collision_block.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationComponent with HasGameRef, KeyboardHandler, CollisionCallbacks {
  // Define the size of each frame
  static const double frameWidth = 192;
  static const double frameHeight = 192;

  // Grid movement settings
  static const double gridSize = 64.0; // Size of each grid cell
  bool isMoving = false; // Flag to track if player is currently moving
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

  // Movement speed
  final double speed = 150.0;
  Vector2 direction = Vector2.zero();
  

  // Keep track of pressed keys
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  Player() : super(size: Vector2(frameWidth, frameHeight)) {
    targetPosition = position.clone();
  }
  
  @override
  Future<void> onLoad() async {
    super.onLoad();

    final hitbox = RectangleHitbox(
      size: Vector2(gridSize*1.2, gridSize*1.2),
      position: Vector2(
        (frameWidth - gridSize) / 2.5,
        (frameHeight - gridSize) / 2.5
      ),
    );
    add(hitbox);
    // Load the sprite sheet
    final spriteSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Blue/Warrior_Blue.png');

    // Define animations
    idleAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        texturePosition: Vector2.all(10), ////TODO WHAT IS THIS SAINATH
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
    if (isMoving) return true; // Ignore input if already moving

    _pressedKeys.clear();
    _pressedKeys.addAll(keysPressed);
    
    // Handle only one direction at a time
    if (keysPressed.contains(LogicalKeyboardKey.keyW) || 
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      startGridMove(Vector2(0, -1));
    } else if (keysPressed.contains(LogicalKeyboardKey.keyS) || 
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      startGridMove(Vector2(0, 1));
    } else if (keysPressed.contains(LogicalKeyboardKey.keyA) || 
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      startGridMove(Vector2(-1, 0));
    } else if (keysPressed.contains(LogicalKeyboardKey.keyD) || 
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      startGridMove(Vector2(1, 0));
    }

    return true;
  }
  // void startGridMove(Vector2 dir) {
  //   // log("Player : Starting grid movement");
  //   if (!isMoving) {
  //     // log("Player : startGridMove -> Player is not moving currently, Lets move him");
  //     direction = dir;
  //     targetPosition = position + (direction * gridSize);
  //     isMoving = true;
      
  //     // Set appropriate animation
  //     if (direction.y < 0) {
  //       animation = moveUpAnimation;
  //     } else if (direction.y > 0) {
  //       animation = moveDownAnimation;
  //     } else if (direction.x < 0) {
  //       animation = moveLeftAnimation;
  //     } else if (direction.x > 0) {
  //       animation = moveRightAnimation;
  //     }
  //   }
  // }

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
    // Get the player's hitbox
    final playerHitbox = children.query<RectangleHitbox>().first;
    
    // Calculate the future bounds of the player
    double futureLeft = newPosition.x + (frameWidth - gridSize) / 2.5;
    double futureRight = futureLeft + gridSize * 1.2;
    double futureTop = newPosition.y + (frameHeight - gridSize) / 2.5;
    double futureBottom = futureTop + gridSize * 1.2;

    // Check collision with all collision blocks
    for (final block in collisionBlocks) {
      double blockLeft = block.position.x;
      double blockRight = blockLeft + block.size.x;
      double blockTop = block.position.y;
      double blockBottom = blockTop + block.size.y;

      // Basic rectangle collision detection
      if (futureLeft < blockRight &&
          futureRight > blockLeft &&
          futureTop < blockBottom &&
          futureBottom > blockTop) {
        return true;
      }
    }
    
    return false;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is CollisionBlock) {
      // Handle collision start if needed
      log("Player : COllision detected with colliion block");
    }
  }


  @override
  void update(double dt) {
    super.update(dt);
    // log("Player : Update is called ");
    if (isMoving) {
      // log("Player : Update -> player is moving");
      // Calculate distance to move this frame
      final movement = direction * speed * dt;
      
      // Check if we would overshoot the target
      final distanceToTarget = targetPosition - position;
      final distanceThisFrame = movement.length;
      
      if (distanceThisFrame >= distanceToTarget.length) {
        // Snap to target position and stop moving
        position = targetPosition;
        isMoving = false;
        direction = Vector2.zero();
        animation = idleAnimation;
      } else {
        // Continue moving towards target
        position += movement;
      }
    }
    }
}
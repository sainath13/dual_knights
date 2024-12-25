import 'dart:developer';

import 'package:dual_knights/components/collision_block.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationComponent with HasGameRef, KeyboardHandler, CollisionCallbacks {
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

  // Movement speed
  final double speed = 150.0;
  Vector2 direction = Vector2.zero();
  

  // Keep track of pressed keys
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  Player() : super(size: Vector2(frameWidth, frameHeight), priority: 5) {
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
    // Load the sprite sheet
    final spriteSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Blue/Warrior_Blue.png');

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
    // log("Key press is detected");
    // if (true) return true; //
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
      if(futureX < blockLeft){ continue;}
      double blockRight = blockLeft + block.size.x;
      if(futureX > blockRight){ continue;}
      double blockTop = block.position.y;
      if(futureY < blockTop){ continue;}
      double blockBottom = blockTop + block.size.y;
      if(futureY > blockBottom){ continue;}
      return true;
    }
    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // log("Player priority is $priority");
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
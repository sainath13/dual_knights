import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationComponent with HasGameRef, KeyboardHandler {
  // Define the size of each frame
  static const double frameWidth = 192;
  static const double frameHeight = 192;

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

  Player() : super(size: Vector2(frameWidth, frameHeight));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load the sprite sheet
    final spriteSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Blue/Warrior_Blue.png');

    // Define animations
    idleAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        texturePosition: Vector2.all(10),
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
    _pressedKeys.clear();
    _pressedKeys.addAll(keysPressed);
    log("Player : Key is pressed");

    // Update direction based on pressed keys
    direction = Vector2.zero();
    
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      direction.y = -100;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      direction.y = 100;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      direction.x = -100;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      direction.x = 100;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (direction != Vector2.zero()) {
      position += direction.normalized() * speed * dt;

      // Switch animation based on direction
      if (direction.y < 0) {
        animation = moveUpAnimation;
      } else if (direction.y > 0) {
        animation = moveDownAnimation;
      } else if (direction.x < 0) {
        animation = moveLeftAnimation;
      } else if (direction.x > 0) {
        animation = moveRightAnimation;
      }
    } else {
      animation = idleAnimation;
    }
  }
}
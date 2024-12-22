import 'dart:math';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
// import 'dart:developer';

import 'package:flutter/material.dart';

enum BarrelState {
  idle,
  wakingUp,
  randomLooking,
  goingBackToIdle,
  awakeWaiting,
  readyToExplode
}

class Barrel extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  static const double frameWidth = 128;
  static const double frameHeight = 128;
  static const double gridSize = 64.0;  
  
  // Animation states
  late final Map<BarrelState, SpriteAnimation> animations;
  BarrelState currentState = BarrelState.idle;
  
  // Track knights in different ranges
  final Set<Component> knightsInWakeRange = {};
  final Set<Component> knightsInExplodeRange = {};

  // Store hitbox references
  late final RectangleHitbox wakeRangeHitbox;
  late final RectangleHitbox explodeRangeHitbox;
  // Timer for random looking state
  double randomLookTimer = 0;
  static const double randomLookInterval = 3.0; // Seconds between random looks
  
  Barrel({required Vector2 position}) : super(size: Vector2(frameWidth, frameHeight)) {
    this.position = position;
  }

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('Factions/Goblins/Troops/Barrel/Red/Barrel_Red.png');
    // Load all animations
    animations = {
      BarrelState.idle: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, 0), // First row
        ),
      ),
      BarrelState.wakingUp: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false, // Don't loop waking animation
          texturePosition: Vector2(0, frameHeight), // Second row
        ),
      ),
      BarrelState.randomLooking: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 2), // Third row
        ),
      ),
      BarrelState.goingBackToIdle: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight * 3), // Fourth row
        ),
      ),
      BarrelState.awakeWaiting: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 4), // Fifth row
        ),
      ),
      BarrelState.readyToExplode: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 5), // Sixth row
        ),
      ),
    };
    
    animation = animations[BarrelState.idle];

    // Create and store hitbox references
    wakeRangeHitbox = RectangleHitbox(
    size: Vector2(gridSize * 6, gridSize * 6), // 3 grid detection range on each side
    position: Vector2(frameWidth/2 - gridSize * 3, frameHeight/2 - gridSize * 3),
    isSolid: false,
    collisionType: CollisionType.passive,
  );
  
  explodeRangeHitbox = RectangleHitbox(
    size: Vector2(gridSize * 2, gridSize * 2), // 1 grid explosion range on each side
    position: Vector2(frameWidth/2 - gridSize, frameHeight/2 - gridSize),
    isSolid: false,
    collisionType: CollisionType.passive,
  );

    // Add debug colors
    wakeRangeHitbox.debugColor = Color(0x8800FF00);  // Semi-transparent green
    explodeRangeHitbox.debugColor = Color(0x88FF0000);  // Semi-transparent red
    
    // Add hitboxes to component
    await add(wakeRangeHitbox);
    await add(explodeRangeHitbox);
    // Make sure the component itself has a hitbox for general collisions
    add(RectangleHitbox(
      size: Vector2(frameWidth, frameHeight),
      collisionType: CollisionType.passive,
    ));
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Player || other is AntiPlayer) {
      final Vector2 otherCenter = other.position + (other.size / 2);
      final Vector2 barrelCenter = position + (size / 2);
      
      // Calculate distance between centers
      final double distance = (otherCenter - barrelCenter).length;
      
      // Check wake range
      if (distance <= gridSize * 3) {
        //log("Barrel: Knight entered wake range. Distance: $distance");
        knightsInWakeRange.add(other);
      }
      
      // Check explode range
      if (distance <= gridSize) {
        //log("Barrel: Knight entered explode range. Distance: $distance");
        knightsInExplodeRange.add(other);
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    
    if (other is Player || other is AntiPlayer) {
      knightsInWakeRange.remove(other);
      knightsInExplodeRange.remove(other);
    }
  }
void _updateState() {
  BarrelState newState = currentState;  // Start with current state
  
  // Check if we're in a transition animation that needs to complete
  if ((currentState == BarrelState.wakingUp || currentState == BarrelState.goingBackToIdle) 
      && animationTicker?.done() != true) {
    return;  // Don't change state until animation completes
  }
  
  // Handle explode range - highest priority
  if (knightsInExplodeRange.isNotEmpty) {
    newState = BarrelState.readyToExplode;
  }
  // Handle wake range
  else if (knightsInWakeRange.isNotEmpty) {
    if (currentState == BarrelState.idle) {
      newState = BarrelState.wakingUp;  // Start waking up animation
    }
    else if (currentState == BarrelState.wakingUp && animationTicker?.done() == true) {
      newState = BarrelState.awakeWaiting;  // Move to waiting after wake animation
    }
    else if (currentState == BarrelState.readyToExplode) {
      newState = BarrelState.awakeWaiting;  // Coming back from explode range
    }
    else if (currentState != BarrelState.awakeWaiting) {
      newState = BarrelState.awakeWaiting;
    }
  }
  // No knights in any range
  else {
    if (currentState == BarrelState.awakeWaiting || 
        currentState == BarrelState.readyToExplode) {
      newState = BarrelState.goingBackToIdle;  // Start going back animation
    }
    else if (currentState == BarrelState.goingBackToIdle && 
             animationTicker?.done() == true) {
      newState = BarrelState.idle;  // Return to idle after animation
    }
  }
  
  // Update animation if state changed
  if (newState != currentState) {
    currentState = newState;
    animation = animations[currentState];
    // Reset animation ticker for non-looping animations
    if (currentState == BarrelState.wakingUp || 
        currentState == BarrelState.goingBackToIdle) {
      animationTicker?.reset();
    }
  }
}
  
  @override
  void update(double dt) {
    super.update(dt);
    //log("Barrel : update is called");
    // if (currentState == BarrelState.idle) {
    //   randomLookTimer += dt;
    //   if (randomLookTimer >= randomLookInterval) {
    //     randomLookTimer = 0;
    //     if (Random().nextBool()) {
    //     // if (false) {
    //       currentState = BarrelState.randomLooking;
    //       animation = animations[currentState];
    //     }
    //   }
    // } else if (currentState == BarrelState.randomLooking && 
    //            animationTicker?.done() == true) {
    //   currentState = BarrelState.idle;
    //   animation = animations[currentState];
    // }
    
    _updateState();
  }
  
}
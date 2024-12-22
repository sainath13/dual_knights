import 'dart:math';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'dart:developer' as developer;


enum BarrelState {
  idle,
  wakingUp,
  randomLooking,
  goingBackToIdle,
  awakeWaiting,
  readyToExplode,
  dying,
  vanishing,
  dead
}

class Barrel extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  static const double frameWidth = 128;
  static const double frameHeight = 128;
  static const double gridSize = 64.0;  
  
  late final Map<BarrelState, SpriteAnimation> animations;
  BarrelState currentState = BarrelState.idle;
  
  final Set<Component> knightsInWakeRange = {};
  final Set<Component> knightsInExplodeRange = {};

  late final RectangleHitbox wakeRangeHitbox;
  late final RectangleHitbox explodeRangeHitbox;
  double randomLookTimer = 0;
  static const double randomLookInterval = 3.0;
  
  bool isExploding = false;
  
  Barrel({required Vector2 position}) : super(size: Vector2(frameWidth, frameHeight)) {
    this.position = position;
  }

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('Factions/Goblins/Troops/Barrel/Red/Barrel_Red.png');
    final deathSheet = await gameRef.images.load('Factions/Knights/Troops/Dead/Dead.png');
    
    // Load all animations
    animations = {
      BarrelState.idle: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, 0),
        ),
      ),
      BarrelState.wakingUp: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight),
        ),
      ),
      BarrelState.randomLooking: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 2),
        ),
      ),
      BarrelState.goingBackToIdle: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight * 3),
        ),
      ),
      BarrelState.awakeWaiting: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 4),
        ),
      ),
      BarrelState.readyToExplode: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 5),
        ),
      ),
      // Add death animations
      BarrelState.dying: SpriteAnimation.fromFrameData(
        deathSheet,
        SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, 0),
        ),
      ),
      BarrelState.vanishing: SpriteAnimation.fromFrameData(
        deathSheet,
        SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight),
        ),
      ),
    };
    
    animation = animations[BarrelState.idle];

    wakeRangeHitbox = RectangleHitbox(
      size: Vector2(gridSize * 6, gridSize * 6),
      position: Vector2(frameWidth/2 - gridSize * 3, frameHeight/2 - gridSize * 3),
      isSolid: false,
      collisionType: CollisionType.passive,
    );
    
    explodeRangeHitbox = RectangleHitbox(
      size: Vector2(gridSize * 2, gridSize * 2),
      position: Vector2(frameWidth/2 - gridSize, frameHeight/2 - gridSize),
      isSolid: false,
      collisionType: CollisionType.passive,
    );

    wakeRangeHitbox.debugColor = Color(0x8800FF00);
    explodeRangeHitbox.debugColor = Color.fromARGB(135, 0, 0, 0);
    
    await add(wakeRangeHitbox);
    await add(explodeRangeHitbox);
    await add(RectangleHitbox(
      size: Vector2(frameWidth, frameHeight),
      collisionType: CollisionType.passive,
    ));
  }

  void explode() {
    if (!isExploding) {
      isExploding = true;
      currentState = BarrelState.dying;
      animation = animations[currentState];
      animationTicker?.reset();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    developer.log("Barrel : Collision is started");
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Player || other is AntiPlayer) {
      developer.log("Barrel : other is player or antiplayer");
      final Vector2 otherCenter = other.position + (other.size / 2);
      final Vector2 barrelCenter = position + (size / 2);
      final double distance = (otherCenter - barrelCenter).length;
      developer.log("Barrel : distance is $distance");
      if (distance <= gridSize * 3) {
        knightsInWakeRange.add(other);
      }
      
      if (distance <= gridSize) {
        developer.log("Barrel : distance is less than gridSize");
        knightsInExplodeRange.add(other);
        developer.log("Barrel : Current state is $currentState");
        if (currentState == BarrelState.readyToExplode) {
          explode();
        }
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
    if (currentState == BarrelState.dead) return;
    
    if (isExploding) {
      if (currentState == BarrelState.dying && animationTicker?.done() == true) {
        currentState = BarrelState.vanishing;
        animation = animations[currentState];
        animationTicker?.reset();
      } else if (currentState == BarrelState.vanishing && animationTicker?.done() == true) {
        currentState = BarrelState.dead;
        // You might want to remove the barrel from the game here
        // gameRef.remove(this);
      }
      return;
    }

    BarrelState newState = currentState;
    
    if ((currentState == BarrelState.wakingUp || currentState == BarrelState.goingBackToIdle) 
        && animationTicker?.done() != true) {
      return;
    }
    
    if (knightsInExplodeRange.isNotEmpty) {
      newState = BarrelState.readyToExplode;
    }
    else if (knightsInWakeRange.isNotEmpty) {
      if (currentState == BarrelState.idle) {
        newState = BarrelState.wakingUp;
      }
      else if (currentState == BarrelState.wakingUp && animationTicker?.done() == true) {
        newState = BarrelState.awakeWaiting;
      }
      else if (currentState == BarrelState.readyToExplode) {
        newState = BarrelState.awakeWaiting;
      }
      else if (currentState != BarrelState.awakeWaiting) {
        newState = BarrelState.awakeWaiting;
      }
    }
    else {
      if (currentState == BarrelState.awakeWaiting || 
          currentState == BarrelState.readyToExplode) {
        newState = BarrelState.goingBackToIdle;
      }
      else if (currentState == BarrelState.goingBackToIdle && 
               animationTicker?.done() == true) {
        newState = BarrelState.idle;
      }
    }
    
    if (newState != currentState) {
      currentState = newState;
      animation = animations[currentState];
      if (currentState == BarrelState.wakingUp || 
          currentState == BarrelState.goingBackToIdle) {
        animationTicker?.reset();
      }
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    _updateState();
  }
}
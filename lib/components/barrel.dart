import 'dart:math';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'dart:developer' as developer;

import 'package:flutter/material.dart';


enum BarrelState {
  idle,
  wakingUp,
  randomLooking,
  goingBackToIdle,
  awakeWaiting,
  readyToExplode,
  exploding,
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
  Vector2 currentPosition = Vector2.zero();
  
  final Set<Component> knightsInWakeRange = {};
  final Set<Component> knightsInExplodeRange = {};

  late final RectangleHitbox wakeRangeHitbox;
  late final RectangleHitbox explodeRangeHitbox;
  late final RectangleHitbox deadRangeHitbox;
  double randomLookTimer = 0;
  static const double randomLookInterval = 3.0;
  
  bool isExploding = false;
  
  Barrel({required Vector2 position}) : super(size: Vector2(frameWidth, frameHeight)) {
    developer.log("Barrel is created");
    this.position = position;
    currentPosition = position.clone();
  }

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('Factions/Goblins/Troops/Barrel/Red/Barrel_Red.png');
    final deathSheet = await gameRef.images.load('Factions/Knights/Troops/Dead/Dead.png');
    final explosionSheet = await gameRef.images.load('Effects/Explosion/Explosions.png');
    
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
      BarrelState.exploding: SpriteAnimation.fromFrameData(
        explosionSheet,
        SpriteAnimationData.sequenced(
          amount: 9,
          textureSize: Vector2(192,192),
          stepTime: 0.1,
          loop: false,
          // texturePosition: Vector2(0, 0),
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
      position: Vector2(-96, -96),
      size: Vector2(gridSize * 5, gridSize * 5),
      isSolid: false,
      collisionType: CollisionType.passive,
    )..debugColor = Colors.deepOrange
    ..debugMode = true;
    
    explodeRangeHitbox = RectangleHitbox(
      position: Vector2(-32,-32),
      size: Vector2(gridSize * 3, gridSize * 3),
      isSolid: false,
      collisionType: CollisionType.passive,
    )..debugColor = Colors.yellowAccent
    ..debugMode = true;

    // deadRangeHitbox = RectangleHitbox(
    //   size: Vector2(gridSize, gridSize),
    //   position: Vector2(32,32),
    //   isSolid: false,
    //   collisionType: CollisionType.passive,
    // )..debugColor = Colors.black
    // ..debugMode = true;
    deadRangeHitbox = RectangleHitbox(
      size: Vector2(gridSize, gridSize),
      position: Vector2(frameWidth/2 - gridSize/2, frameHeight/2 - gridSize/2), // Center the hitbox
      isSolid: false,
      collisionType: CollisionType.passive,
    )..debugColor = Colors.black
    ..debugMode = true;

    // wakeRangeHitbox.debugColor = Color(0x8800FF00);
    // explodeRangeHitbox.debugColor = Color(0x88FF0000);
    // deadRangeHitbox.debugColor = Colors.black38;
    
    await add(wakeRangeHitbox);
    await add(explodeRangeHitbox);
    await add(deadRangeHitbox);
    // await add(RectangleHitbox(
    //   size: Vector2(frameWidth, frameHeight),
    //   collisionType: CollisionType.passive,
    // ));
  }

  // void explode() {
  //   if (!isExploding) {
  //     isExploding = true;
  //     currentState = BarrelState.dying;
  //     animation = animations[currentState];
  //     animationTicker?.reset();
  //   }
//   // }
// @override
// void onCollisionStart(
//   Set<Vector2> intersectionPoints,
//   PositionComponent other,
// ) {
//   super.onCollisionStart(intersectionPoints, other);
  
//   if (other is Player || other is AntiPlayer) {
//     // Check which hitbox is colliding using containsPoint
//     for (Vector2 point in intersectionPoints) {
//       if (wakeRangeHitbox.containsPoint(point)) {
//         developer.log('Collision with wake range hitbox');
//         knightsInWakeRange.add(other);
//       }
      
//       if (explodeRangeHitbox.containsPoint(point)) {
//         developer.log('Collision with explode range hitbox');
//         knightsInExplodeRange.add(other);
//       }
      
//       if (deadRangeHitbox.containsPoint(point)) {
//         developer.log('Collision with dead range hitbox');
//         if (currentState != BarrelState.exploding) {
//           currentState = BarrelState.exploding;
//           animation = animations[BarrelState.exploding];
//           isExploding = true;
//         }
//         if (other.parent != null) {
//           other.parent!.remove(other);
//         }
//       }
//     }
//   }
// }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    developer.log("collision happened at is ${other.position}");
// Create a red circle at each collision point
  for (final point in intersectionPoints) {
    final collisionMarker = CircleComponent(
      position: other.position,
      radius: 3.0,
      paint: Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill,
    );
    
    // Add to game world
    gameRef.add(collisionMarker);}
  
    final Vector2 barrelCenter = position+ Vector2.all(64);
    final Vector2 otherCenter = other.position + Vector2.all(32);
    developer.log("Barrel center position is $barrelCenter");
    developer.log("other center position is $otherCenter");
    if (other is Player || other is AntiPlayer) {
      //developer.log("Barrel : other is player or antiplayer");
      
      
      final double distance = (otherCenter - barrelCenter).length;
      // developer.log("Barrel : distance is $distance");
      // developer.log("Barrel : distance is $distance, "
        // "gridSize is $gridSize, "
        // "gridSize * 3 is ${gridSize * 3}, "
        // "gridSize * 2 is ${gridSize * 2}");

      if (distance <= gridSize * 3) {
        // developer.log('${other.runtimeType} added to wake range');
        knightsInWakeRange.add(other);
      }else{
        knightsInWakeRange.remove(other);
      }
      
      if (distance <= gridSize *2) {
        // developer.log('${other.runtimeType} added to explode range');
        knightsInExplodeRange.add(other);
      }
      else{
        knightsInExplodeRange.remove(other);
      }
      // if (distance <= gridSize) {
        // developer.log('${other.runtimeType} exploding');
      // Vector2 deadCenter = deadRangeHitbox.aabb.center;
      final Vector2 deadCenter = position + Vector2.all(64);
      double deadDistance = (deadCenter - otherCenter).length;
      developer.log("deadCenter $deadCenter  otherCenter is $otherCenter deadDistance $deadDistance");
      if (deadDistance <= deadRangeHitbox.size.x) {
        // developer.log("Barrel : Dead Distance-based check passed!");
        if (currentState != BarrelState.exploding) {
          currentState = BarrelState.exploding;
          animation = animations[BarrelState.goingBackToIdle];
          isExploding = true;
        }
        if (other.parent != null) {
         other.parent!.remove(other);
        }
      }
    }
  }

// @override
//   void onCollisionStart(
//     Set<Vector2> intersectionPoints,
//     PositionComponent other,
//   ) {
//     super.onCollisionStart(intersectionPoints, other);
    
//     if (other is Player || other is AntiPlayer) {
//       final Vector2 barrelCenter = position + Vector2(frameWidth/2, frameHeight/2);
//       final Vector2 otherCenter = other.position + Vector2(other.width/2, other.height/2);
      
//       final double distance = (otherCenter - barrelCenter).length;
      
//       // Wake range check
//       if (distance <= gridSize * 3) {
//         knightsInWakeRange.add(other);
//       } else {
//         knightsInWakeRange.remove(other);
//       }
      
//       // Explode range check
//       if (distance <= gridSize * 2) {
//         knightsInExplodeRange.add(other);
//       } else {
//         knightsInExplodeRange.remove(other);
//       }
      
//       // Dead range check - simplified and more reliable
//       if (distance <= gridSize/2) {  // Reduced range for more precise collision
//         if (currentState != BarrelState.exploding) {
//           currentState = BarrelState.exploding;
//           animation = animations[BarrelState.goingBackToIdle];
//           isExploding = true;
//         }
//         if (other.parent != null) {
//           other.parent!.remove(other);
//         }
//       }
//     }
//   }


  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    // developer.log("Barrel : collision ended--------");
    if (other is Player || other is AntiPlayer) {
      knightsInWakeRange.remove(other);
      knightsInExplodeRange.remove(other);
      // developer.log("Barrel : other is player or antiplayer");
      // final Vector2 otherCenter = other.position + (other.size / 2);
      // final Vector2 barrelCenter = position+ (size / 2);
      // final double distance = (otherCenter - barrelCenter).length;
      // developer.log("Barrel : distance is $distance");
      // developer.log("Barrel : distance is $distance, "
      //   "gridSize is $gridSize, "
      //   "gridSize * 3 is ${gridSize * 3}, "
      //   "gridSize * 2 is ${gridSize * 2}");

      // if (distance <= gridSize * 3) {
      //   developer.log('${other.runtimeType} added to wake range');
      //   knightsInWakeRange.add(other);
      // }
      
      // if (distance <= gridSize *2) {
      //   developer.log('${other.runtimeType} added to explode range');
      //   knightsInExplodeRange.add(other);
      // }
    }
  }



  // @override
  // void onCollisionEnd(PositionComponent other) {
  //   super.onCollisionEnd(other);
    
  //   if (other is Player || other is AntiPlayer) {
  //     developer.log("Barrel : other is player or antiplayer");
  //     final Vector2 otherCenter = other.position + Vector2.all(32);
  //     final Vector2 barrelCenter = position + Vector2.all(32);
  //     final double xdistance = (otherCenter.x - barrelCenter.x).abs();
  //     final double ydistance = (otherCenter.y - barrelCenter.y).abs();
  //     developer.log("Barrel : xdistance is $xdistance, ydistance is $ydistance");
  //     final double distance = max(xdistance, ydistance);
  //     // final double distance = (otherCenter - barrelCenter).length;
  //     developer.log("Barrel : distance is $distance, "
  //       "gridSize is $gridSize, "
  //       "gridSize * 3 is ${gridSize * 3}, "
  //       "gridSize * 2 is ${gridSize * 2}");
  //     developer.log("Barrel : distance is $distance");

  //     if (distance >= gridSize) {
  //       developer.log("Barrel : ------Remove Explode Range-based check passed!");
  //       // knightsInExplodeRange.add(other);
  //       knightsInExplodeRange.remove(other);
  //     }

  //     if (distance >= gridSize * 1.8) {
  //       developer.log("Barrel : Remove Wake Range-based check passed!");
  //       // knightsInWakeRange.add(other);
  //       knightsInWakeRange.remove(other);
  //     }      
  //   }
  // }

  void _updateState() {
    if (currentState == BarrelState.dead) return;
    
    if (isExploding) {
      // developer.log("isExploding is $isExploding with state $currentState");
      // developer.log("animationTicker is ${animationTicker?.isLastFrame}");
      if (animationTicker?.isLastFrame ?? false) {
      // Handle transitions between animation states
        switch (currentState) {
          case BarrelState.goingBackToIdle:
            // developer.log("Handling for goingBackToIdle state");
            currentState = BarrelState.exploding;
            animation = animations[BarrelState.exploding];
            animationTicker?.reset();
            break;

          case BarrelState.exploding:
            // developer.log("Handling for exploding state");
            currentState = BarrelState.dying;
            animation = animations[BarrelState.dying];
            animationTicker?.reset();
            // // currentState = BarrelState.goingBackToIdle;
            // animation = animations[BarrelState.exploding];
            // animationTicker?.reset();
            break;

          case BarrelState.dying:
            // developer.log("Handling for vanishing state");
            currentState = BarrelState.vanishing;
            animation = animations[BarrelState.vanishing];
            animationTicker?.reset();
            break;

          case BarrelState.vanishing:
            currentState = BarrelState.dead;
            removeFromParent(); // Remove the entity
            break;

          default:
            break;
        }
        return;
      }
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
      if (currentState == BarrelState.awakeWaiting 
      || currentState == BarrelState.readyToExplode
          ) {
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
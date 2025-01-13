import 'dart:math';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/routes/gameplay.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'dart:developer' as developer;

import 'package:flutter/material.dart';


enum MovingBarrelState {
  silent,
  wakingUp,
  randomLooking,
  goingBackToSleep,
  awakeWaiting,
  readyToExplode,
  exploding,
  dying,
  vanishing,
  dead
}

enum KnightRangeStatus{
  inWakeRange,
  inExplodeRange,
  notInRange,
  readyToExplode,
}

class MovingBarrel extends SpriteAnimationComponent with HasGameRef<DualKnights>, CollisionCallbacks ,HasAncestor<Gameplay>{
  final int leftOffset;
  final int  rightOffset;
  final int upOffset;
  final int downOffset;
  final bool isVertical;
  static const double frameWidth = 128;
  static const double frameHeight = 128;
  static const double gridSize = 64.0;  
  final Player player;
  final AntiPlayer antiPlayer;
  late final Map<MovingBarrelState, SpriteAnimation> animations;
  MovingBarrelState currentState = MovingBarrelState.silent;
  Vector2 currentPosition = Vector2.zero();
  Vector2 startPosition = Vector2.zero();

  static const double moveSpeed = 100.0; // pixels per second
  bool isMovingPositive = true; // true = right/down, false = left/up
  double distanceMoved = 0.0;
  KnightRangeResult collisionResult = KnightRangeResult(KnightRangeStatus.notInRange);
  bool hasCollided = false;
  bool isAnyoneInWakeRange = false;
  MovingBarrel({required Vector2 position,
  required this.player, required this.antiPlayer,
  this.isVertical = false,
  this.leftOffset = 0,
    this.rightOffset = 0,
    this.upOffset = 0,
    this.downOffset = 0,
  }) : super(size: Vector2(frameWidth, frameHeight)) {
    this.position = position;
    currentPosition = position.clone();
    startPosition = position.clone();
  }

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('Factions/Goblins/Troops/Barrel/Blue/Barrel_Blue.png');
    final deathSheet = await gameRef.images.load('Factions/Knights/Troops/Dead/Dead.png');
    final explosionSheet = await gameRef.images.load('Effects/Explosion/Explosions.png');
    
    final hitbox = RectangleHitbox(
      size: Vector2(64-4, 64-4),
      collisionType: CollisionType.passive,
      position: Vector2(
        32,
        32
      ),
    );//..debugColor = Colors.red
      // ..debugMode = true;
    add(hitbox);
    // Load all animations
    animations = {
      MovingBarrelState.silent: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 4 + 16),
        ),
      ),
      MovingBarrelState.wakingUp: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight + 16),
        ),
      ),
      MovingBarrelState.randomLooking: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 2 + 16),
        ),
      ),
      MovingBarrelState.goingBackToSleep: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight * 3 + 16),
        ),
      ),
      MovingBarrelState.awakeWaiting: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 4 + 16),
        ),
      ),
      MovingBarrelState.readyToExplode: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 5 + 16),
        ),
      ),
      MovingBarrelState.exploding: SpriteAnimation.fromFrameData(
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
      MovingBarrelState.dying: SpriteAnimation.fromFrameData(
        deathSheet,
        SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, 16),
        ),
      ),
      MovingBarrelState.vanishing: SpriteAnimation.fromFrameData(
        deathSheet,
        SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight + 16),
        ),
      ),
    };
    
    animation = animations[MovingBarrelState.silent];

  }
  
  KnightRangeResult getKnightRangeStatus() {
    // developer.log("Checking Knight Range");
  double playerDistanceX = (player.position.x - position.x - 64).abs();
  double playerDistanceY = (player.position.y - position.y - 64).abs();
  double antiPlayerDistanceX = (antiPlayer.position.x - position.x - 64).abs();
  double antiPlayerDistanceY = (antiPlayer.position.y - position.y - 64).abs();

  double minDistanceX = min(playerDistanceX, antiPlayerDistanceX);
  double minDistanceY = min(playerDistanceY, antiPlayerDistanceY);

  // if (minDistanceX <= 10 && minDistanceY <= 10) {
  //   String triggeredBy = (playerDistanceX <= 10 && playerDistanceY <= 10) ? "player" : "antiPlayer";
  //   return KnightRangeResult(KnightRangeStatus.readyToExplode, triggeredBy: triggeredBy);
  // }

  if (minDistanceX <= 64 && minDistanceY <= 64) {
    return KnightRangeResult(KnightRangeStatus.inExplodeRange);
  }

  if (minDistanceX <= 128 && minDistanceY <= 128) {
    return KnightRangeResult(KnightRangeStatus.inWakeRange);
  }

  return KnightRangeResult(KnightRangeStatus.notInRange);
}


double get maxDistance {
    if (isVertical) {
      return (upOffset + downOffset) * gridSize;
    } else {
      return (leftOffset + rightOffset) * gridSize;
    }
  }

void _updateMovement(double dt) {
    if (currentState == MovingBarrelState.dead || currentState == MovingBarrelState.exploding || currentState == MovingBarrelState.vanishing || 
        currentState == MovingBarrelState.dying) {
      return;
    }

    double moveAmount = moveSpeed * dt;
    
    if (isVertical) {
      // Vertical movement
      if (isMovingPositive) {
        // Moving down
        if (position.y < startPosition.y + (downOffset * gridSize)) {
          position.y += moveAmount;
          distanceMoved += moveAmount;
        } else {
          isMovingPositive = false;
        }
      } else {
        // Moving up
        if (position.y > startPosition.y - (upOffset * gridSize)) {
          position.y -= moveAmount;
          distanceMoved += moveAmount;
        } else {
          isMovingPositive = true;
        }
      }
    } else {
      // Horizontal movement
      if (isMovingPositive) {
        // Moving right
        if (position.x < startPosition.x + (rightOffset * gridSize)) {
          position.x += moveAmount;
          distanceMoved += moveAmount;
        } else {
          isMovingPositive = false;
        }
      } else {
        // Moving left
        if (position.x > startPosition.x - (leftOffset * gridSize)) {
          position.x -= moveAmount;
          distanceMoved += moveAmount;
        } else {
          isMovingPositive = true;
        }
      }
    }
    
    currentPosition = position.clone();
  }

  
  void _updateState() {
    if (currentState == MovingBarrelState.dead) return;
    // developer.log("hasCollided is $hasCollided");
    MovingBarrelState newState = currentState;
    KnightRangeResult knightRangeResult = hasCollided ? collisionResult : getKnightRangeStatus();
    KnightRangeStatus knightRangeStatus = knightRangeResult.status;
    // developer.log("current state is $currentState");
    if (knightRangeStatus == KnightRangeStatus.readyToExplode) {
      // developer.log("Moving barrel is ready to explode");
      ancestor.input.movementAllowed = false;
      if(knightRangeResult.triggeredBy == "player") {
        // developer.log("Moving barrel triggered by player");
        if (player.parent != null) {
         player.parent!.remove(player);
        }
      }
      else {
        // developer.log("Moving barrel triggered by antiplayer");
        if (antiPlayer.parent != null) {
          antiPlayer.parent!.remove(antiPlayer);
        }
      }
      
      if (animationTicker?.isLastFrame ?? false) {
        switch (currentState) {
          case MovingBarrelState.readyToExplode:
            currentState = MovingBarrelState.exploding;
            animation = animations[MovingBarrelState.exploding];
            animationTicker?.reset();
            break;

          case MovingBarrelState.goingBackToSleep:
            currentState = MovingBarrelState.exploding;
            animation = animations[MovingBarrelState.exploding];
            animationTicker?.reset();
            break;

          case MovingBarrelState.exploding:
            ancestor.input.movementAllowed = false;
            currentState = MovingBarrelState.dying;
            animation = animations[MovingBarrelState.dying];
            animationTicker?.reset();
            break;

          case MovingBarrelState.dying:
            currentState = MovingBarrelState.vanishing;
            animation = animations[MovingBarrelState.vanishing];
            animationTicker?.reset();
            break;

          case MovingBarrelState.vanishing:
            currentState = MovingBarrelState.dead;
            removeFromParent();
            ancestor.onGameOver();
            break;

          default:
            break;
        }
        return;
      }
    }
    if ((currentState == MovingBarrelState.wakingUp || currentState == MovingBarrelState.goingBackToSleep) 
        && animationTicker?.done() != true) {
      return;
    }
    
    if (knightRangeStatus == KnightRangeStatus.inExplodeRange) {
      newState = MovingBarrelState.readyToExplode;
    }
    else if (knightRangeStatus == KnightRangeStatus.inWakeRange) {
      if (currentState == MovingBarrelState.silent) {
        newState = MovingBarrelState.wakingUp;
      }
      else if (currentState == MovingBarrelState.wakingUp && animationTicker?.done() == true) {
        newState = MovingBarrelState.awakeWaiting;
      }
      else if (currentState == MovingBarrelState.readyToExplode) {
        newState = MovingBarrelState.awakeWaiting;
      }
      else if (currentState != MovingBarrelState.awakeWaiting) {
        newState = MovingBarrelState.awakeWaiting;
      }
    }
    else {
      if (currentState == MovingBarrelState.awakeWaiting 
      || currentState == MovingBarrelState.readyToExplode
          ) {
        newState = MovingBarrelState.goingBackToSleep;
      }
      else if (currentState == MovingBarrelState.goingBackToSleep && 
               animationTicker?.done() == true) {
        newState = MovingBarrelState.silent;
      }
    }
    if (newState != currentState) {
      currentState = newState;
      animation = animations[currentState];
      if (currentState == MovingBarrelState.wakingUp 
      || currentState == MovingBarrelState.goingBackToSleep
          ) {
        animationTicker?.reset();
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is AntiPlayer) {
      hasCollided = true;
      collisionResult = KnightRangeResult(KnightRangeStatus.readyToExplode, triggeredBy: "antiPlayer");
      // developer.log("Moving Barrel : AntiPlayer collied with Moving Barrel");
    }
    else if(other is Player){
      hasCollided = true;
      collisionResult = KnightRangeResult(KnightRangeStatus.readyToExplode, triggeredBy: "player");
      // developer.log("Moving Barrel : Player collied with Moving Barrel");
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    _updateMovement(dt);
    _updateState();
  }
}


class KnightRangeResult {
  final KnightRangeStatus status;
  final String? triggeredBy;

  KnightRangeResult(this.status, {this.triggeredBy});
}

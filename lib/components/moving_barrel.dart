import 'dart:math';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/dual_knights.dart';
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

class MovingBarrel extends SpriteAnimationComponent with HasGameRef<DualKnights>, CollisionCallbacks {
  final int leftOffset;
  final int  rightOffset;
  final int upOffset;
  final int downOffset;
  final bool isVertical;
  static const double frameWidth = 128;
  static const double frameHeight = 128;
  static const double gridSize = 64.0;  
  late final Player player;
  late final AntiPlayer antiPlayer;
  late final Map<MovingBarrelState, SpriteAnimation> animations;
  MovingBarrelState currentState = MovingBarrelState.silent;
  Vector2 currentPosition = Vector2.zero();
  Vector2 startPosition = Vector2.zero();

  static const double moveSpeed = 100.0; // pixels per second
  bool isMovingPositive = true; // true = right/down, false = left/up
  double distanceMoved = 0.0;


  bool isExploding = false;
  bool isAnyoneInWakeRange = false;
  MovingBarrel({required Vector2 position,
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
    player = game.player;
    antiPlayer = game.antiPlayer;
    final spriteSheet = await gameRef.images.load('Factions/Goblins/Troops/Barrel/Blue/Barrel_Blue.png');
    final deathSheet = await gameRef.images.load('Factions/Knights/Troops/Dead/Dead.png');
    final explosionSheet = await gameRef.images.load('Effects/Explosion/Explosions.png');
    
    // Load all animations
    animations = {
      MovingBarrelState.silent: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 4),
        ),
      ),
      MovingBarrelState.wakingUp: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight),
        ),
      ),
      MovingBarrelState.randomLooking: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 2),
        ),
      ),
      MovingBarrelState.goingBackToSleep: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight * 3),
        ),
      ),
      MovingBarrelState.awakeWaiting: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 4),
        ),
      ),
      MovingBarrelState.readyToExplode: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 5),
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
          texturePosition: Vector2(0, 0),
        ),
      ),
      MovingBarrelState.vanishing: SpriteAnimation.fromFrameData(
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
    
    animation = animations[MovingBarrelState.silent];

  }
  
  KnightRangeResult getKnightRangeStatus() {
  double playerDistanceX = (player.position.x - position.x - 64).abs();
  double playerDistanceY = (player.position.y - position.y - 64).abs();
  double antiPlayerDistanceX = (antiPlayer.position.x - position.x - 64).abs();
  double antiPlayerDistanceY = (antiPlayer.position.y - position.y - 64).abs();

  double minDistanceX = min(playerDistanceX, antiPlayerDistanceX);
  double minDistanceY = min(playerDistanceY, antiPlayerDistanceY);

  if (minDistanceX <= 10 && minDistanceY <= 10) {
    String triggeredBy = (playerDistanceX <= 10 && playerDistanceY <= 10) ? "player" : "antiPlayer";
    return KnightRangeResult(KnightRangeStatus.readyToExplode, triggeredBy: triggeredBy);
  }

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
    if (currentState == MovingBarrelState.dead || currentState == MovingBarrelState.exploding) {
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

    MovingBarrelState newState = currentState;
    KnightRangeResult knightRangeResult = getKnightRangeStatus();
    KnightRangeStatus knightRangeStatus = knightRangeResult.status;
    
    if (knightRangeStatus == KnightRangeStatus.readyToExplode) {
      if(knightRangeResult.triggeredBy == "player") {
        if (player.parent != null) {
         player.parent!.remove(player);
        }
      }
      else {
        if (antiPlayer.parent != null) {
          antiPlayer.parent!.remove(antiPlayer);
        }
      }
      
      if (animationTicker?.isLastFrame ?? false) {
        switch (currentState) {
          case MovingBarrelState.goingBackToSleep:
            currentState = MovingBarrelState.exploding;
            animation = animations[MovingBarrelState.exploding];
            animationTicker?.reset();
            break;

          case MovingBarrelState.exploding:
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

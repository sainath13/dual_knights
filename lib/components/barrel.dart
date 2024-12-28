import 'dart:math';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'dart:developer' as developer;

import 'package:flutter/material.dart';


enum BarrelState {
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

class Barrel extends SpriteAnimationComponent with HasGameRef<DualKnights>, CollisionCallbacks {
  static const double frameWidth = 128;
  static const double frameHeight = 128;
  static const double gridSize = 64.0;  
  late final Player player;
  late final AntiPlayer antiPlayer;
  late final Map<BarrelState, SpriteAnimation> animations;
  BarrelState currentState = BarrelState.silent;
  Vector2 currentPosition = Vector2.zero();
  
  bool isExploding = false;
  bool isAnyoneInWakeRange = false;
  Barrel({required Vector2 position}) : super(size: Vector2(frameWidth, frameHeight)) {
    this.position = position;
    currentPosition = position.clone();
  }

  @override
  Future<void> onLoad() async {
    player = game.player;
    antiPlayer = game.antiPlayer;
    final spriteSheet = await gameRef.images.load('Factions/Goblins/Troops/Barrel/Red/Barrel_Red.png');
    final deathSheet = await gameRef.images.load('Factions/Knights/Troops/Dead/Dead.png');
    final explosionSheet = await gameRef.images.load('Effects/Explosion/Explosions.png');
    
    // Load all animations
    animations = {
      BarrelState.silent: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, 16),
        ),
      ),
      BarrelState.wakingUp: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight+16),
        ),
      ),
      BarrelState.randomLooking: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 2 + 16),
        ),
      ),
      BarrelState.goingBackToSleep: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight * 3 + 16),
        ),
      ),
      BarrelState.awakeWaiting: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 4 + 16),
        ),
      ),
      BarrelState.readyToExplode: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 5 + 16) ,
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
          texturePosition: Vector2(0, 16),
        ),
      ),
      BarrelState.vanishing: SpriteAnimation.fromFrameData(
        deathSheet,
        SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight+16),
        ),
      ),
    };
    
    animation = animations[BarrelState.silent];

  }
  
  KnightRangeResult getKnightRangeStatus() {
  double playerDistanceX = (player.position.x - position.x - 64).abs();
  double playerDistanceY = (player.position.y - position.y - 64).abs();
  double antiPlayerDistanceX = (antiPlayer.position.x - position.x - 64).abs();
  double antiPlayerDistanceY = (antiPlayer.position.y - position.y - 64).abs();

  // Check if either player is within the trigger range
  if ((playerDistanceX <= 10 && playerDistanceY <= 10) || 
      (antiPlayerDistanceX <= 10 && antiPlayerDistanceY <= 10)) {
    String triggeredBy = (playerDistanceX <= 10 && playerDistanceY <= 10) ? "player" : "antiPlayer";
    return KnightRangeResult(KnightRangeStatus.readyToExplode, triggeredBy: triggeredBy);
  }

  // Check if either player is within explode range
  if ((playerDistanceX <= 64 && playerDistanceY <= 64) ||
      (antiPlayerDistanceX <= 64 && antiPlayerDistanceY <= 64)) {
    return KnightRangeResult(KnightRangeStatus.inExplodeRange);
  }

  // Check if either player is within wake range
  if ((playerDistanceX <= 128 && playerDistanceY <= 128) ||
      (antiPlayerDistanceX <= 128 && antiPlayerDistanceY <= 128)) {
    return KnightRangeResult(KnightRangeStatus.inWakeRange);
  }

  return KnightRangeResult(KnightRangeStatus.notInRange);
}

  
  void _updateState() {
    if (currentState == BarrelState.dead) return;

    BarrelState newState = currentState;
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
          case BarrelState.goingBackToSleep:
            currentState = BarrelState.exploding;
            animation = animations[BarrelState.exploding];
            animationTicker?.reset();
            break;

          case BarrelState.exploding:
            currentState = BarrelState.dying;
            animation = animations[BarrelState.dying];
            animationTicker?.reset();
            break;

          case BarrelState.dying:
            currentState = BarrelState.vanishing;
            animation = animations[BarrelState.vanishing];
            animationTicker?.reset();
            break;

          case BarrelState.vanishing:
            currentState = BarrelState.dead;
            removeFromParent();
            break;

          default:
            break;
        }
        return;
      }
    }
    if ((currentState == BarrelState.wakingUp || currentState == BarrelState.goingBackToSleep) 
        && animationTicker?.done() != true) {
      return;
    }
    
    if (knightRangeStatus == KnightRangeStatus.inExplodeRange) {
      newState = BarrelState.readyToExplode;
    }
    else if (knightRangeStatus == KnightRangeStatus.inWakeRange) {
      if (currentState == BarrelState.silent) {
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
        newState = BarrelState.goingBackToSleep;
      }
      else if (currentState == BarrelState.goingBackToSleep && 
               animationTicker?.done() == true) {
        newState = BarrelState.silent;
      }
    }
    if (newState != currentState) {
      currentState = newState;
      animation = animations[currentState];
      if (currentState == BarrelState.wakingUp 
      || currentState == BarrelState.goingBackToSleep
          ) {
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


class KnightRangeResult {
  final KnightRangeStatus status;
  final String? triggeredBy;

  KnightRangeResult(this.status, {this.triggeredBy});
}

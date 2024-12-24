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
  late final Map<BarrelState, SpriteAnimation> animations;
  BarrelState currentState = BarrelState.silent;
  Vector2 currentPosition = Vector2.zero();
  
  final Set<Component> knightsInWakeRange = {};
  final Set<Component> knightsInExplodeRange = {};

  double randomLookTimer = 0;
  static const double randomLookInterval = 3.0;
  
  bool isExploding = false;
  bool isAnyoneInWakeRange = false;
  Barrel({required Vector2 position}) : super(size: Vector2(frameWidth, frameHeight)) {
    // developer.log("Barrel is created");
    this.position = position;
    currentPosition = position.clone();
  }

  @override
  Future<void> onLoad() async {
    player = game.player;
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
      BarrelState.goingBackToSleep: SpriteAnimation.fromFrameData(
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
    
    animation = animations[BarrelState.silent];

  }
  
  KnightRangeStatus getPlayerRangeStatus() {
    // developer.log("player.scale.x is ${player.scale.x}");
    // double playerOffset = (player.scale.x > 0) ? 0 : - 64;
    double distanceX = (player.position.x - position.x - 64).abs();
    double distanceY = (player.position.y - position.y - 64).abs();
    // developer.log("DistanceX is $distanceX and DistanceY is $distanceY");
    if(distanceX <= 10 && distanceY <= 10) {
      // developer.log("player is in exploding range");
      return KnightRangeStatus.readyToExplode;
    }
    if(distanceX <= 64 && distanceY <= 64) {
      // developer.log("player is in exploding range");
      return KnightRangeStatus.inExplodeRange;
    }
    if(distanceX <= 128 && distanceY <= 128) {
      // developer.log("player is in wake range");
      return KnightRangeStatus.inWakeRange;
    }
    return KnightRangeStatus.notInRange;
  }
  
  void _updateState() {
    if (currentState == BarrelState.dead) return;

    BarrelState newState = currentState;
    KnightRangeStatus knightRangeStatus = getPlayerRangeStatus();
    
    if (knightRangeStatus == KnightRangeStatus.readyToExplode) {
      if (player.parent != null) {
         player.parent!.remove(player);
        }
      // developer.log("isExploding is $isExploding with state $currentState");
      // developer.log("animationTicker is ${animationTicker?.isLastFrame}");
      if (animationTicker?.isLastFrame ?? false) {
      // Handle transitions between animation states
        switch (currentState) {
          case BarrelState.goingBackToSleep:
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
    // developer.log("Checking for state change");
    
    // developer.log("Current state is $currentState");
    // if ((currentState == BarrelState.wakingUp || currentState == BarrelState.goingBackToIdle) 
    //     && animationTicker?.done() != true) {
    //   return;
    // }
    
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

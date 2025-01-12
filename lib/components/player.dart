import 'dart:developer';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/collision_block.dart';
import 'package:dual_knights/components/experiments/arrow.dart';
import 'package:dual_knights/components/experiments/dying_knight.dart';
import 'package:dual_knights/components/player_checkpoint.dart';
import 'package:dual_knights/components/player_priority_manager.dart';
import 'package:dual_knights/components/tree.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/routes/gameplay.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationComponent with HasGameRef<DualKnights>, KeyboardHandler, CollisionCallbacks,HasAncestor<Gameplay> {
  static const double frameWidth = 192;
  static const double frameHeight = 192;
  static const double gridSize = 64.0;
  bool isMoving = false;
  Vector2 targetPosition = Vector2.zero();
  final PlayerPriorityManager priorityManager;
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
  late SpriteAnimation fightAnimation;
  late SpriteAnimation glowAnimation;

  // Movement speed
  final double speed = 150.0;
  Vector2 direction = Vector2.zero();
  


  Player() : priorityManager = PlayerPriorityManager(null),super(
      size: Vector2(frameWidth, frameHeight), priority: 5) {
    priorityManager.owner = this;
    targetPosition = position.clone();
  }

  void updateTreeInteraction(Tree tree) {
    priorityManager.updateTreeInteraction(tree);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // priorityManager = PlayerPriorityManager(this);
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
    final downSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Blue/Warrior_Blue_Walk_Down.png');
    final leftSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Blue/Warrior_Blue_Walk_Left.png');
    final upSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Blue/Warrior_Blue_Walk_Up.png');
    final explosionSheet = await gameRef.images.load('Effects/Explosion/Explosions.png');
    final glowSheet =  await gameRef.images.load('Factions/Knights/Troops/Warrior/Blue/Warrior_Blue_Glow.png');

    // Define animations
    idleAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0,16),
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
      ),
    );
    // idleAnimation = SpriteAnimation.fromFrameData(
    //   glowSheet,
    //   SpriteAnimationData.sequenced(
    //     amount: 6,
    //     textureSize: Vector2(192, 192),
    //     stepTime: 0.1,
    //     loop: true,
    //     texturePosition: Vector2(0, 16),
    //   ),
    // );

    moveUpAnimation = SpriteAnimation.fromFrameData(
      upSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, 16),
      ),
    );

    moveDownAnimation = SpriteAnimation.fromFrameData(
      downSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, 16),
      ),
    );

    moveLeftAnimation = SpriteAnimation.fromFrameData(
      leftSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, 16),
      ),
    );

    moveRightAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
        texturePosition: Vector2(0, frameHeight + 16),
      ),
    );
    fightAnimation = SpriteAnimation.fromFrameData(
      explosionSheet,
      SpriteAnimationData.sequenced(
        amount: 9,
        textureSize: Vector2(192, 192),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, 16),
      ),
    );

    glowAnimation = SpriteAnimation.fromFrameData(
      glowSheet,
      SpriteAnimationData.sequenced(
        amount: 9,
        textureSize: Vector2(192, 192),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, 0),
      ),
    );

    // Set initial animation
    animation = idleAnimation;
  }


  void startGridMove(Vector2 dir) {
    if (!isMoving) {
      // if (game.sfxValueNotifier.value) {
      //   FlameAudio.play(DualKnights.move, volume: 0.05);
      // }
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
      else{
        // if (game.sfxValueNotifier.value) {
        //   FlameAudio.play(DualKnights.blocked, volume: 0.02);
        // }
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
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // log("Player detected collsion with $other");
    if (other is AntiPlayer) {
      log("Player collided with AntiPlayer");
      if (game.sfxValueNotifier.value) {
        FlameAudio.play(DualKnights.crashEachother);
      }
      ancestor.input.movementAllowed = false;
      animation = fightAnimation;
      Future.delayed(Duration(milliseconds: 200), () {
        ancestor.onGameOver();
      });
    }
    if(other is Arrow){
      // log("I am dead by arrow");
      removeFromParent();
      DyingKnight dyingKnight = DyingKnight(position: Vector2(position.x-64, position.y-64));
      parent?.add(dyingKnight);
    }


    // else if(other is PlayerCheckpoint ){
    //   log("Player collided with Checkpoint.");
    //   animation = glowAnimation;
    // }
    
  }

  @override
  void update(double dt) {
    super.update(dt);
    // log("Player priority is $priority");
    
    if (isMoving) {
      game.addDialogueRequest('Aqua Knight', 'The enemy is approaching!',0);
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

    if (isMoving) return;

    bool shouldInvert = ancestor.input.isInversed; // Set this flag based on your condition

    Vector2 applyInversion(Vector2 vector) {
      return shouldInvert ? vector * -1 : vector;
    }

    if (ancestor.input.isLeftPressed) {
      startGridMove(applyInversion(Vector2(-1, 0)));
    }
    if (ancestor.input.isRightPressed) {
      startGridMove(applyInversion(Vector2(1, 0)));
    }
    if (ancestor.input.isUpPressed) {
      startGridMove(applyInversion(Vector2(0, -1)));
    }
    if (ancestor.input.isDownPressed) {
      startGridMove(applyInversion(Vector2(0, 1)));
    }
  }
}
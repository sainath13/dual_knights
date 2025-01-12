
import 'package:dual_knights/components/collision_block.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/components/tree.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/routes/gameplay.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

import 'anti_player_priority_manager.dart';
import 'experiments/arrow.dart';
import 'experiments/dying_knight.dart';

class AntiPlayer extends SpriteAnimationComponent with HasGameRef<DualKnights>, KeyboardHandler, CollisionCallbacks,HasAncestor<Gameplay> {
  static const double frameWidth = 192;
  static const double frameHeight = 192;
  final AntiPlayerPriorityManager antiPlayerPriorityManager;
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
  late SpriteAnimation fightAnimation;
  late SpriteAnimation glowAnimation;

  final double speed = 150.0;
  Vector2 direction = Vector2.zero();


  AntiPlayer() :  antiPlayerPriorityManager = AntiPlayerPriorityManager(null),super(size: Vector2(frameWidth, frameHeight), priority: 5) {
    targetPosition = position.clone();
    antiPlayerPriorityManager.owner = this;
  }

  void updateTreeInteraction(Tree tree) {
    antiPlayerPriorityManager.updateTreeInteraction(tree);
  }
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // priorityManager = AntiPlayerPriorityManager(this);

    final hitbox = RectangleHitbox(
      size: Vector2(64-4, 64-4),
      position: Vector2(
        64,
        64
      ),
    );//..debugMode = true;
    add(hitbox);
    final spriteSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red.png');
    final idleSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_Idle.png');
    final downSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_walk_down.png');
    final leftSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_walk_left.png');
    final upSheet = await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_walk_up.png');
    final explosionSheet = await gameRef.images.load('Effects/Explosion/Explosions.png');
    final glowSheet =  await gameRef.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_Glow.png');
  
  
    log("Keeping animations loaded");
    idleAnimation = SpriteAnimation.fromFrameData(
      idleSheet,
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0,16),
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
      ),
    );

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
    // Set initial animation
    
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
        texturePosition: Vector2(0, 16),
      ),
    );

    animation = idleAnimation;
  }
  
 


  void startGridMove(Vector2 dir) {
    if (!isMoving) {
      direction = dir;
      Vector2 potentialTarget = position + (direction * gridSize);
      if (!wouldCollide(potentialTarget)) {
        if (game.sfxValueNotifier.value) {
          FlameAudio.play(DualKnights.move);
        }
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
        if (game.sfxValueNotifier.value) {
          FlameAudio.play(DualKnights.blocked);
        }
      }
    }
  }
  
  bool wouldCollide(Vector2 newPosition) {  
    double futureX = newPosition.x;
    double futureY = newPosition.y;
    for (final block in collisionBlocks) {
      double blockLeft = block.position.x;
      if(futureX < blockLeft) {continue;}
      double blockRight = blockLeft + block.size.x;
      if(futureX > blockRight) {continue;}
      double blockTop = block.position.y;
      if(futureY < blockTop) {continue;}
      double blockBottom = blockTop + block.size.y;
      if(futureY > blockBottom) {continue;}
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
    if (other is Player) {
      log("Player collided with AntiPlayer");
      animation = fightAnimation;  
    }
    if(other is Arrow){
      log("I am dead by arrow");
      removeFromParent();
      DyingKnight dyingKnight = DyingKnight(position: Vector2(position.x-64, position.y-64));
      parent?.add(dyingKnight);
    }
    // else if(other is AntiPlayerCheckpoint ){
    //   log("Player collided with Checkpoint.");
    //   animation = glowAnimation;
    // }
    
  }


  @override
  void update(double dt) {
    super.update(dt);
    // log("AntiPlayer priority is $priority");

    if (isMoving) {
      game.addDialogueRequest('Flame Knight', 'Blue standing still',1);
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

    bool shouldInvert = ancestor.input.isInversed;

    if (ancestor.input.isLeftPressed) {
      startGridMove(Vector2(shouldInvert ? -1 : 1, 0));
    }
    if (ancestor.input.isRightPressed) {
      startGridMove(Vector2(shouldInvert ? 1 : -1, 0));
    }
    if (ancestor.input.isUpPressed) {
      startGridMove(Vector2(0, shouldInvert ? -1 : 1));
    }
    if (ancestor.input.isDownPressed) {
      startGridMove(Vector2(0, shouldInvert ? 1 : -1));
    }
  }
}
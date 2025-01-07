import 'dart:math';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/routes/gameplay.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';

enum TreeState {
  idle,
  shaking,
  cutedDown,
  ahead,
  behind,
}

enum KnightRangeStatus {
  behind,
  ahead,
  notNear,
}

class Tree extends SpriteAnimationComponent with HasGameRef<DualKnights>, CollisionCallbacks, HasAncestor<Gameplay> {
  static const double frameWidth = 192;
  static const double frameHeight = 192;
  static const double gridSize = 64.0;
  final Player player;
  final AntiPlayer antiPlayer;
  late final Map<TreeState, SpriteAnimation> animations;
  TreeState currentState = TreeState.idle;
  Vector2 currentPosition = Vector2.zero();

  // Add new variables for wind animation
  late final Random _random;
  double _windTimer = 0;
  double _nextWindTime = 0;
  double _animationSpeed = 0.1;
  bool _isSwaying = false;
  late final Sprite _spriteSheet;
  // Add variables to track knight interactions
  bool isPlayerBehind = false;
  bool isAntiPlayerBehind = false;
  bool isPlayerAhead = false;
  bool isAntiPlayerAhead = false;

  Tree({required Vector2 position, required this.player, required this.antiPlayer})
      : super(size: Vector2(frameWidth, frameHeight), priority: 10) {
    this.position = position;
    currentPosition = position.clone();
    _random = Random();
    _nextWindTime = _getNextWindTime();
  }

  double _getNextWindTime() {
    // Random time between 1 and 4 seconds for next wind gust
    return _random.nextDouble() * 3 + 1;
  }

  double _getAnimationSpeed() {
    // Random animation speed between 0.08 and 0.15 seconds
    return 0.08 + _random.nextDouble() * 0.07;
  }

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('Resources/Trees/Tree.png');
    _spriteSheet = Sprite(spriteSheet); // Store the sprite sheet

    animations = {
      TreeState.idle: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: _getAnimationSpeed(),
          loop: true,
          texturePosition: Vector2(0, 0),
        ),
      ),
      TreeState.shaking: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 2,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: _getAnimationSpeed(),
          loop: false,
          texturePosition: Vector2(0, frameHeight),
        ),
      ),
      TreeState.cutedDown: SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: true,
          texturePosition: Vector2(0, frameHeight * 2),
        ),
      ),
    };

    animation = animations[TreeState.idle];
  }

  void _updateWindAnimation(double dt) {
    if (currentState == TreeState.cutedDown) return;

    _windTimer += dt;

    // Check if it's time for a new wind gust
    if (_windTimer >= _nextWindTime && !_isSwaying) {
      _isSwaying = true;
      _animationSpeed = _getAnimationSpeed();

      // Create new animation with updated speed
      animation = SpriteAnimation.fromFrameData(
        _spriteSheet.image,  // Use the stored sprite sheet
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: _animationSpeed,
          loop: true,
          texturePosition: Vector2(0, 0),
        ),
      );

      // Reset timer and get next wind time
      _windTimer = 0;
      _nextWindTime = _getNextWindTime();
    } else if (_isSwaying && _windTimer >= 0.5) { // Sway for 0.5 seconds
      _isSwaying = false;
      _windTimer = 0;
    }
  }

  KnightRangeResult getKnightRangeResult(String? knight) {
    // Some logic to determine if the knight is behind the tree
    // developer.log("Player Position: ${player.position}");
    // developer.log("AntiPlayer Position: ${antiPlayer.position} "
    // "Tree Position: ${position + Vector2(0, 48)}");
    Vector2 treePosition = position + Vector2(0, 48);
    KnightRangeStatus status = KnightRangeStatus.notNear;
    if(knight == "player") {
      status = getKnightPositionRelativeToTree(treePosition, player.position);
      // developer.log("Status: ${status.toString()}");
      return KnightRangeResult(status, triggeredBy: "player");
    }
    else if(knight == "antiPlayer") {
      // developer.log("Checking for AntiPlayer");
      status =  getKnightPositionRelativeToTree(treePosition, antiPlayer.position);
      //if Knight is behind
      // developer.log("Status: $status");
      return KnightRangeResult(status, triggeredBy: "antiPlayer");
    }
    //if Knight is behind
    // return KnightRangeResult(playerStatus, triggeredBy: "player");
    return KnightRangeResult(status, triggeredBy: "player");
  }


  void _updateState() {
    if (currentState == TreeState.cutedDown) return;

    // List<KnightRangeResult> knightRangeResults = [
    //   // getKnightRangeResult("player"),
    //   getKnightRangeResult("antiPlayer")];
    // for(KnightRangeResult knightRangeResult in knightRangeResults){
    //   KnightRangeStatus knightRangeStatus = knightRangeResult.status;
    //   if (knightRangeStatus == KnightRangeStatus.behind) {
    //     if(knightRangeResult.triggeredBy == "player") {
          player.priority = 5;
    //     }
    //     else {
    //       antiPlayer.priority = 5;
    //     }
    //   }
    //   else if (knightRangeStatus == KnightRangeStatus.ahead) {
    //     if(knightRangeResult.triggeredBy == "player") {
    //       player.priority = 15;
    //     }
    //     else {
    //       antiPlayer.priority = 15;
    //     }
    //   }
    //   else {
    //     player.priority = 5;
    //     antiPlayer.priority = 5;
    //   }
    // }
    if (animationTicker?.isLastFrame ?? false) {
      switch (currentState) {
        case TreeState.idle:
          break;
        case TreeState.shaking:
          break;
        case TreeState.cutedDown:
          animationTicker?.reset();
          break;
        default:
          break;
      }
      return;
    }
  }
  KnightRangeStatus getKnightPositionRelativeToTree(Vector2 treePos, Vector2 playerPos) {
    const double gridSize = 64.0;
    double distanceX = (playerPos.x - treePos.x).abs();
    double distanceY = (playerPos.y - treePos.y).abs();

    if(playerPos.x == treePos.x && playerPos.y - treePos.y == 64) {
      return KnightRangeStatus.ahead;
    }

    if(playerPos.x == treePos.x && treePos.y - playerPos.y <= 128) {
      return KnightRangeStatus.behind;
    }

    if (distanceX > gridSize || distanceY > gridSize) {
      return KnightRangeStatus.notNear;
    }

    if (playerPos.y == treePos.y) {
      if (playerPos.x == treePos.x - gridSize || playerPos.x == treePos.x + gridSize) {
        return KnightRangeStatus.ahead;
      }
    }

    if (playerPos.y <= treePos.y - gridSize &&
        playerPos.y >= treePos.y - (2 * gridSize) &&
        playerPos.x >= treePos.x - gridSize &&
        playerPos.x <= treePos.x + gridSize) {
      return KnightRangeStatus.behind;
    }

    return KnightRangeStatus.notNear;
  }
  void updateKnightPriorities() {
    Vector2 treePosition = position + Vector2(0, 48);

    // Check player position
    KnightRangeStatus playerStatus = getKnightPositionRelativeToTree(treePosition, player.position);
    // Check antiPlayer position
    KnightRangeStatus antiPlayerStatus = getKnightPositionRelativeToTree(treePosition, antiPlayer.position);

    // Update tracking variables
    isPlayerBehind = playerStatus == KnightRangeStatus.behind;
    isPlayerAhead = playerStatus == KnightRangeStatus.ahead;
    isAntiPlayerBehind = antiPlayerStatus == KnightRangeStatus.behind;
    isAntiPlayerAhead = antiPlayerStatus == KnightRangeStatus.ahead;

    // Send this tree's status to the knights
    player.updateTreeInteraction(this);
    antiPlayer.updateTreeInteraction(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateWindAnimation(dt);
    // _updateState();
    updateKnightPriorities();
  }
}

class KnightRangeResult {
  final KnightRangeStatus status;
  final String? triggeredBy;

  KnightRangeResult(this.status, {this.triggeredBy});
}
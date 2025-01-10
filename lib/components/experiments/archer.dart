import 'dart:developer' as developer;
import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/experiments/arrow.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
class ArcherRangeVisualizer extends PositionComponent {
  final Vector2 sizeXY;
  final Paint _paint;

  ArcherRangeVisualizer({
    required this.sizeXY,
    required Vector2 position,
    Color color = const Color(0x44FF0000),
  }) : _paint = Paint()..color = color {
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, sizeXY.x, sizeXY.y),
      _paint,
    );
  }
}

enum ArcherState {
  idle,
  shootUp,
  shootDiagonalUp,
  shootFront,
  shootDiagonalDown,
  shootDown,
}

class Archer extends SpriteAnimationComponent with HasGameRef<DualKnights>, CollisionCallbacks, TapCallbacks {
  static const double frameWidth = 192;
  static const double frameHeight = 192;
  static const double gridSize = 64.0;

  static const double shootCooldown = 2.0;

  ArcherState state = ArcherState.idle;
  Vector2 currentPosition = Vector2.zero();
  Vector2? targetPosition;
  bool _facingLeft = false;
  double _timeSinceLastShot = 0;
  bool _canShoot = true;

  Archer({required Vector2 position}) : super(position: position,size: Vector2(frameWidth, frameHeight), priority: 5) {
    anchor = Anchor.center;
  }

  late SpriteAnimation idleAnimation;
  late SpriteAnimation shootUpAnimation;
  late SpriteAnimation shootDiagonalUpAnimation;
  late SpriteAnimation shootFrontAnimation;
  late SpriteAnimation shootDiagonalDownAnimation;
  late SpriteAnimation shootDownAnimation;
  ArcherRangeVisualizer? rangeVisualizer;
  bool isRangeVisible = false;


  bool hasCollided = false;

  @override
  bool onTapDown(TapDownEvent event) {
    _toggleRangeVisualizer();
    return true;
  }

  void _toggleRangeVisualizer() {
    if (isRangeVisible) {
      rangeVisualizer?.removeFromParent();
      rangeVisualizer = null;
    } else {
      rangeVisualizer = ArcherRangeVisualizer(
        sizeXY: Vector2(gridSize * 7.5, gridSize * 7),
        position: Vector2(-gridSize * 2, -gridSize * 2),
        color: const Color(0x44FF0000) // Semi-transparent red
      );
      add(rangeVisualizer!);
    }
    isRangeVisible = !isRangeVisible;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final newHitbox = RectangleHitbox(
      size: Vector2(gridSize * 7.25, gridSize * 6.75),
      position: Vector2(-gridSize * 2, -gridSize * 2),
    );//..debugColor = Colors.red
      //..debugMode = true;
    add(newHitbox);

    final spriteSheet = await gameRef.images.load('Factions/Knights/Troops/Archer/Purple/Archer_Purple.png');
    
    idleAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        texturePosition: Vector2.all(0),
        amount: 6,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: true,
      ),
    );

    shootUpAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, frameHeight * 2),
      ),
    );

    shootDiagonalUpAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, frameHeight * 3),
      ),
    );

    shootFrontAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, frameHeight * 4),
      ),
    );

    shootDiagonalDownAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, frameHeight * 5),
      ),
    );

    shootDownAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.1,
        loop: false,
        texturePosition: Vector2(0, frameHeight * 6),
      ),
    );

    animation = idleAnimation;
  }

  Vector2 _calculateArrowSpawnPosition() {
    developer.log("Archer position: $position", name: "Archer");
    final spawnPos = position.clone();
    final offset = Vector2.zero();

    switch (state) {
      case ArcherState.shootUp:
        offset.y = -gridSize;
        break;
      case ArcherState.shootDiagonalUp:
        offset
          ..x = _facingLeft ? -gridSize : gridSize
          ..y = -gridSize;
        break;
      case ArcherState.shootFront:
        offset.x = _facingLeft ? -gridSize : gridSize;
        break;
      case ArcherState.shootDiagonalDown:
        offset
          ..x = _facingLeft ? -gridSize : gridSize
          ..y = gridSize;
        break;
      case ArcherState.shootDown:
        offset.y = gridSize;
        break;
      case ArcherState.idle:
        break;
    }

    return spawnPos + offset;
  }

  void _shoot() {
    if (!_canShoot || targetPosition == null) return;

    final arrowSpawnPos = _calculateArrowSpawnPosition();
    developer.log("Arrow spawn position: $arrowSpawnPos, Target position: $targetPosition", name: "Archer");

    final arrow = Arrow(
      startPosition: arrowSpawnPos,
      targetPosition: targetPosition!,
    );
    arrow.anchor = Anchor.center;
    parent?.add(arrow);
    
    _canShoot = false;
    _timeSinceLastShot = 0;
  }

  void _updateState() {
    if (!hasCollided || targetPosition == null) return;

    final deltaX = targetPosition!.x - position.x;
    final deltaY = targetPosition!.y - position.y;
    double angle = math.atan2(deltaY, deltaX) * (180 / math.pi);

    if (angle < 0) angle += 360;

    _facingLeft = deltaX < 0;
    scale.x = _facingLeft ? -1 : 1;

    ArcherState newState = _getStateFromAngle(angle);
    
    // Only update animation if state changed
    if (state != newState) {
      state = newState;
      animation = _getAnimationForState(state);
      animationTicker?.reset();
    }
  }

  SpriteAnimation _getAnimationForState(ArcherState state) {
    switch (state) {
      case ArcherState.idle:
        return idleAnimation;
      case ArcherState.shootUp:
        return shootUpAnimation;
      case ArcherState.shootDiagonalUp:
        return shootDiagonalUpAnimation;
      case ArcherState.shootFront:
        return shootFrontAnimation;
      case ArcherState.shootDiagonalDown:
        return shootDiagonalDownAnimation;
      case ArcherState.shootDown:
        return shootDownAnimation;
    }
  }

  ArcherState _getStateFromAngle(double angle) {
    if (angle >= 337.5 || angle < 22.5) return ArcherState.shootFront;
    if (angle < 67.5) return ArcherState.shootDiagonalDown;
    if (angle < 112.5) return ArcherState.shootDown;
    if (angle < 157.5) return ArcherState.shootDiagonalDown;
    if (angle < 202.5) return ArcherState.shootFront;
    if (angle < 247.5) return ArcherState.shootDiagonalUp;
    if (angle < 292.5) return ArcherState.shootUp;
    return ArcherState.shootDiagonalUp;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is AntiPlayer || other is Player) {
      hasCollided = true;
      targetPosition = other.position.clone();
      developer.log("Archer targeting ${other.runtimeType} at position $targetPosition");
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateState();

    if (!_canShoot) {
      _timeSinceLastShot += dt;
      if (_timeSinceLastShot >= shootCooldown) {
        _canShoot = false;
      }
    }
    
    if (_canShoot && hasCollided && targetPosition != null) {
      ArcherState newState = state;
      if (animationTicker?.isLastFrame ?? false) {
        switch (newState) {
          default:
            _shoot();
        }
      }
    }
  }
}
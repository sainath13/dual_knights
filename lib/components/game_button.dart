import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class GameButton extends PositionComponent with TapCallbacks, HoverCallbacks, HasGameReference {
  final Sprite? normalSprite;
  final Sprite? onTapSprite;
  final VoidCallback? onClick;
  final String buttonText;
  final Color? buttonTextColor;
  final double? buttonTextSize;
  late TextComponent _textComponent;

  // Corner sprite components
  late SpriteComponent _topLeftCorner;
  late SpriteComponent _topRightCorner;
  late SpriteComponent _bottomLeftCorner;
  late SpriteComponent _bottomRightCorner;

  // Main button sprite component
  late SpriteComponent _mainButton;

  // Animation controls
  double _animationPhase = 0;
  final double _animationSpeed = 2.0;
  final double _maxOffset = 15.0;

  // Corner sprite paths
  final String _topLeftPath = 'UI/Pointers/03.png';
  final String _topRightPath = 'UI/Pointers/04.png';
  final String _bottomLeftPath = 'UI/Pointers/05.png';
  final String _bottomRightPath = 'UI/Pointers/06.png';

  GameButton({
    this.normalSprite,
    this.onTapSprite,
    required this.onClick,
    required Vector2 size,
    required Vector2 position,
    required this.buttonText,
    this.buttonTextColor,
    this.buttonTextSize,
  }) {
    this.size = size;
    this.position = position;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Add main button sprite
    if (normalSprite != null) {
      _mainButton = SpriteComponent(
        sprite: normalSprite,
        size: size,
      );
      add(_mainButton);
    }

    // Load corner sprites
    final topLeftSprite = await game.loadSprite(_topLeftPath);
    final topRightSprite = await game.loadSprite(_topRightPath);
    final bottomLeftSprite = await game.loadSprite(_bottomLeftPath);
    final bottomRightSprite = await game.loadSprite(_bottomRightPath);

    // Initialize corner components with 64x64 size
    final cornerSize = Vector2(64, 64);
    final cornerOffset = 16.0; // Half of the corner size for initial positioning

    _topLeftCorner = SpriteComponent(
      sprite: topLeftSprite,
      size: cornerSize,
      position: Vector2(-cornerOffset, -cornerOffset),
    );

    _topRightCorner = SpriteComponent(
      sprite: topRightSprite,
      size: cornerSize,
      position: Vector2(size.x - cornerSize.x + cornerOffset, -cornerOffset),
    );

    _bottomLeftCorner = SpriteComponent(
      sprite: bottomLeftSprite,
      size: cornerSize,
      position: Vector2(-cornerOffset, size.y - cornerSize.y + cornerOffset),
    );

    _bottomRightCorner = SpriteComponent(
      sprite: bottomRightSprite,
      size: cornerSize,
      position: Vector2(
          size.x - cornerSize.x + cornerOffset,
          size.y - cornerSize.y + cornerOffset
      ),
    );

    // Add corners with initial opacity 0 (invisible)
    for (final corner in [_topLeftCorner, _topRightCorner, _bottomLeftCorner, _bottomRightCorner]) {
      corner.opacity = 0;
      add(corner);
    }

    // Add the text component last
    _textComponent = TextComponent(
      text: buttonText,
      textRenderer: TextPaint(
        style: TextStyle(
          color: buttonTextColor ?? Colors.white,
          fontSize: buttonTextSize ?? 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'DualKnights',
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isHovered) {
      _animationPhase += dt * _animationSpeed;

      // Calculate offset using sine wave for smooth back-and-forth motion
      double offset = (sin(_animationPhase) * _maxOffset).abs();

      final cornerOffset = 32.0; // Match the initial corner offset

      // Update corner positions
      _topLeftCorner.position = Vector2(-cornerOffset - offset, -cornerOffset - offset);
      _topRightCorner.position = Vector2(
          size.x - _topRightCorner.size.x + cornerOffset + offset,
          -cornerOffset - offset
      );
      _bottomLeftCorner.position = Vector2(
          -cornerOffset - offset,
          size.y - _bottomLeftCorner.size.y + cornerOffset + offset
      );
      _bottomRightCorner.position = Vector2(
          size.x - _bottomRightCorner.size.x + cornerOffset + offset,
          size.y - _bottomRightCorner.size.y + cornerOffset + offset
      );
    } else {
      _resetCornerPositions();
    }
  }

  void _resetCornerPositions() {
    final cornerOffset = 32.0;
    _topLeftCorner.position = Vector2(-cornerOffset, -cornerOffset);
    _topRightCorner.position = Vector2(size.x - _topRightCorner.size.x + cornerOffset, -cornerOffset);
    _bottomLeftCorner.position = Vector2(-cornerOffset, size.y - _bottomLeftCorner.size.y + cornerOffset);
    _bottomRightCorner.position = Vector2(
        size.x - _bottomRightCorner.size.x + cornerOffset,
        size.y - _bottomRightCorner.size.y + cornerOffset
    );
  }

  @override
  void onHoverEnter() {
    _animationPhase = 0;
    // Make corners visible
    for (final corner in [_topLeftCorner, _topRightCorner, _bottomLeftCorner, _bottomRightCorner]) {
      corner.opacity = 1;
    }
  }

  @override
  void onHoverExit() {
    _animationPhase = 0;
    _resetCornerPositions();
    // Hide corners
    for (final corner in [_topLeftCorner, _topRightCorner, _bottomLeftCorner, _bottomRightCorner]) {
      corner.opacity = 0;
    }
  }

  @override
  bool onTapDown(TapDownEvent info) {
    if (onTapSprite != null) {
      _mainButton.sprite = onTapSprite;
    }
    return true;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (normalSprite != null) {
      _mainButton.sprite = normalSprite;
    }
    onClick?.call();
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.x >= 0 && point.x <= size.x && point.y >= 0 && point.y <= size.y;
  }
}
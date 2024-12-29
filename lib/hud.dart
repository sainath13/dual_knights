import 'dart:async';
import 'dart:ui';

import 'package:dual_knights/input.dart';
import 'package:dual_knights/routes/gameplay.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Viewport;
import 'package:flutter/services.dart';

class Hud extends PositionComponent with ParentIsA<Viewport>, HasGameReference,HasAncestor<Gameplay> {
  Hud({
    this.input,
    this.onPausePressed,
    required this.onRestartLevel,
  });

  late final JoystickComponent _joystick;
  final Input? input;
  final VoidCallback? onPausePressed;
  final VoidCallback onRestartLevel;
  LogicalKeyboardKey? lastDirection;

  @override
  Future<void> onLoad() async {


      _joystick = JoystickComponent(
        anchor: Anchor.center,
  
        knob: CircleComponent(
          radius: 50,
          paint: Paint()..color = Colors.grey
        ),
        background: CircleComponent(
          radius: 60,
          paint: Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        ),
      );

      _joystick.position.y =
          parent.virtualSize.y - _joystick.knobRadius * 2.5;
      _joystick.position.x =
          _joystick.knobRadius * 2.5;

      await _joystick.addToParent(this);
  

    final pauseButton = HudButtonComponent(
      button: SpriteComponent.fromImage(
        await game.images.load('UI/Icons/pause.png'),
        size: Vector2.all(30),
      ),
      anchor: Anchor.bottomRight,
      position: Vector2(parent.virtualSize.x - 100, 100),
      onPressed: onPausePressed,
    );
    await add(pauseButton);

    // Restart button on the left
    final restartButton = HudButtonComponent(
      button: SpriteComponent.fromImage(
        await game.images.load('UI/Icons/pause.png'),
        size: Vector2.all(30),
      ),
      anchor: Anchor.bottomLeft,
      position: Vector2(100, 100),
      onPressed: onRestartLevel,
    );
    await add(restartButton);
  }


  @override
  void update(double dt) {
    super.update(dt);

    // Detect joystick direction
    if (_joystick.relativeDelta != Vector2.zero()) {
      LogicalKeyboardKey? currentDirection;

      if (_joystick.relativeDelta.x > 0.5) {
        currentDirection = LogicalKeyboardKey.arrowRight;
      } else if (_joystick.relativeDelta.x < -0.5) {
        currentDirection = LogicalKeyboardKey.arrowLeft;
      } else if (_joystick.relativeDelta.y > 0.5) {
        currentDirection = LogicalKeyboardKey.arrowDown;
      } else if (_joystick.relativeDelta.y < -0.5) {
        currentDirection = LogicalKeyboardKey.arrowUp;
      }

      // Log only if the direction has changed
      if (currentDirection != null && currentDirection != lastDirection) {
        _simulateKeyEvent(currentDirection);
        lastDirection = currentDirection; // Update last direction
      }
    } else {
      // Reset last direction when _joystick returns to center
      ancestor.input.pressedKeys.clear();
      lastDirection = null;
    }
  }

  

  void _simulateKeyEvent(LogicalKeyboardKey key) {
      ancestor.input.pressedKeys.add(key);
  }
}

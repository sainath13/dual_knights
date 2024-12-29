import 'dart:async';
import 'dart:ui';

import 'package:dual_knights/input.dart';
import 'package:dual_knights/routes/gameplay.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Viewport;
import 'package:flutter/services.dart';

class Hud extends PositionComponent with ParentIsA<Viewport>, HasGameReference, HasAncestor<Gameplay> {
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

  late HudButtonComponent _knightSelectionButton;
  bool _isBlueSelected = true;

  @override
  Future<void> onLoad() async {
    // Joystick setup
    _joystick = JoystickComponent(
      anchor: Anchor.center,
      knob: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.grey,
      ),
      background: CircleComponent(
        radius: 60,
        paint: Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      ),
    );

    _joystick.position.y = parent.virtualSize.y - _joystick.knobRadius * 2.5;
    _joystick.position.x = _joystick.knobRadius * 2.5;
    await _joystick.addToParent(this);

    // Pause button
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

    // Restart button
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

    // Add blue sprite button
  final blueSprite = await game.images.load('UI/Buttons/Button_Blue_Pressed.png');
  final redSprite = await game.images.load('UI/Buttons/Button_Red_Pressed.png');
  _knightSelectionButton = HudButtonComponent(
    button: SpriteComponent.fromImage(
      _isBlueSelected ? blueSprite : redSprite,
      size: Vector2.all(50),
    ),
    anchor: Anchor.center,
    position: Vector2(_joystick.position.x , _joystick.position.y - 120),
    onPressed: () {
      _toggleSprite(!_isBlueSelected);
      (_knightSelectionButton.button as SpriteComponent?)?.sprite = Sprite(
        _isBlueSelected ? blueSprite : redSprite,
      );
    },
  );
  await add(_knightSelectionButton);
  // Add text above the button
  final textComponent = TextComponent(
    text: 'Primary Knight',
    textRenderer: TextPaint(
    style: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontFamily: "DualKnights"
    ),
    ),
    anchor: Anchor.center,
    position: Vector2(_knightSelectionButton.position.x, _knightSelectionButton.position.y - 40),
  );
  await add(textComponent);


  }

  void _toggleSprite(bool isBlueSelected) { 
    _isBlueSelected = isBlueSelected;
    ancestor.input.setInversed(!isBlueSelected);
  }

    void _simulateKeyEvent(LogicalKeyboardKey key) {
    ancestor.input.pressedKeys.add(key);
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
        lastDirection = currentDirection;
      }
    } else {
      // Reset last direction when joystick returns to center
      ancestor.input.pressedKeys.clear();
      lastDirection = null;
    }
  }


}


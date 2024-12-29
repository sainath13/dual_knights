import 'dart:ui';

import 'package:dual_knights/dual_knights.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';


class Input extends Component with KeyboardHandler, HasGameReference {
  Input({Map<LogicalKeyboardKey, VoidCallback>? keyCallbacks})
      : _keyCallbacks = keyCallbacks ?? <LogicalKeyboardKey, VoidCallback>{};

  bool _leftPressed = false;
  bool _rightPressed = false;

  var _leftInput = 0.0;
  var _rightInput = 0.0;

  final maxHAxis = 1.5;
  final sensitivity = 2.0;

  var hAxis = 0.0;
  bool active = true;

  final Map<LogicalKeyboardKey, VoidCallback> _keyCallbacks;

  final Set<LogicalKeyboardKey> pressedKeys = {};

  @override
  void update(double dt) {
    if (!DualKnights.isMobile) {
      _leftInput = lerpDouble(
        _leftInput,
        (_leftPressed && active) ? maxHAxis : 0,
        sensitivity * dt,
      )!;

      _rightInput = lerpDouble(
        _rightInput,
        (_rightPressed && active) ? maxHAxis : 0,
        sensitivity * dt,
      )!;

      hAxis = _rightInput - _leftInput;
    }
  }


@override
bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  
  if (game.paused == false) {
    if (event is KeyDownEvent) {
      if(keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) {
        pressedKeys.add(event.logicalKey);
      }
      if(keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) {
        pressedKeys.add(event.logicalKey);
      } 
      if(keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW)) {
        pressedKeys.add(event.logicalKey);
      }
      if(keysPressed.contains(LogicalKeyboardKey.arrowDown) || keysPressed.contains(LogicalKeyboardKey.keyS)) {
        pressedKeys.add(event.logicalKey);
      }    
    } else if (event is KeyUpEvent) {
         pressedKeys.remove(event.logicalKey);
    }

    if (active && event is KeyDownEvent) {
      for (final entry in _keyCallbacks.entries) {
        if (entry.key == event.logicalKey) {
          entry.value.call();
        }
      }
    }

  }
  return super.onKeyEvent(event, keysPressed);
}

bool get isUpPressed => pressedKeys.contains(LogicalKeyboardKey.arrowUp) || pressedKeys.contains(LogicalKeyboardKey.keyW);
bool get isDownPressed => pressedKeys.contains(LogicalKeyboardKey.arrowDown) || pressedKeys.contains(LogicalKeyboardKey.keyS);
bool get isLeftPressed => pressedKeys.contains(LogicalKeyboardKey.arrowLeft) || pressedKeys.contains(LogicalKeyboardKey.keyA);
bool get isRightPressed => pressedKeys.contains(LogicalKeyboardKey.arrowRight) ||  pressedKeys.contains(LogicalKeyboardKey.keyD);

}
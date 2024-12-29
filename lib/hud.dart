import 'dart:async';
import 'dart:ui';

import 'package:dual_knights/input.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Viewport;

class Hud extends PositionComponent with ParentIsA<Viewport>, HasGameReference {
  Hud({
    this.input,
    this.onPausePressed,
    required this.onRestartLevel,
  });

  late final JoystickComponent? _joystick;
  final Input? input;
  final VoidCallback? onPausePressed;
  final VoidCallback onRestartLevel;

  @override
  Future<void> onLoad() async {

    // if (DualKnights.isMobile) {
    //   _joystick = JoystickComponent(
    //     anchor: Anchor.center,
    //     position: parent.virtualSize * 0.5,
    //     knob: CircleComponent(
    //       radius: 10,
    //       paint: Paint()..color = Colors.green.withOpacity(0.08),
    //     ),
    //     background: CircleComponent(
    //       radius: 20,
    //       paint: Paint()
    //         ..color = Colors.black.withOpacity(0.05)
    //         ..style = PaintingStyle.stroke
    //         ..strokeWidth = 4,
    //     ),
    //   );

    //   _joystick?.position.y =
    //       parent.virtualSize.y - _joystick!.knobRadius * 1.5;
    //   await _joystick?.addToParent(this);
    // }

    final pauseButton = HudButtonComponent(
      button: SpriteComponent.fromImage(
        await game.images.load('UI/Icons/pause.png'),
        size: Vector2.all(30),
      ),
      anchor: Anchor.bottomRight,
      position: Vector2(parent.virtualSize.x - 100, 50),
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
      position: Vector2(100, 50),
      onPressed: _confirmRestart,
    );
    await add(restartButton);
  }

  void _confirmRestart() {
    // Show a confirmation dialog before restarting
    showDialog(
      context: game.buildContext!,
      builder: (context) {
        return AlertDialog(
          title: const Text("Restart Level"),
          content: const Text("Are you sure you want to restart the level?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                onRestartLevel(); // Call restart level method
              },
              child: const Text("Restart"),
            ),
          ],
        );
      },
    );
  }

  @override
  void update(double dt) {
    if (input?.active ?? false) {
      input?.hAxis = lerpDouble(
        input!.hAxis,
        _joystick!.isDragged ? _joystick!.relativeDelta.x * input!.maxHAxis : 0,
        input!.sensitivity * dt,
      )!;
    }
  }
}

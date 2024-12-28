import 'dart:async';
import 'dart:ui';

import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/input.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Viewport;


class Hud extends PositionComponent with ParentIsA<Viewport>, HasGameReference {
  Hud({
    this.input,
    this.onPausePressed,
  });



  late final JoystickComponent? _joystick;
  final Input? input;
  final VoidCallback? onPausePressed;

  @override
  Future<void> onLoad() async {

    if (DualKnights.isMobile) {
      _joystick = JoystickComponent(
        anchor: Anchor.center,
        position: parent.virtualSize * 0.5,
        knob: CircleComponent(
          radius: 10,
          paint: Paint()..color = Colors.green.withOpacity(0.08),
        ),
        background: CircleComponent(
          radius: 20,
          paint: Paint()
            ..color = Colors.black.withOpacity(0.05)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        ),
      );

      _joystick?.position.y =
          parent.virtualSize.y - _joystick!.knobRadius * 1.5;
      await _joystick?.addToParent(this);
    }

     final pauseButton = HudButtonComponent(
        button: SpriteComponent.fromImage(
          await game.images.load('UI/Icons/pause.png'),
          size: Vector2.all(30),
        ),
        anchor: Anchor.bottomRight,
        position: Vector2(parent.virtualSize.x / 2, 50),
        onPressed: onPausePressed,
      );
      await add(pauseButton);
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

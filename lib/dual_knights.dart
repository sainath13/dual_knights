// ignore_for_file: implementation_imports, unnecessary_import

import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:dual_knights/components/level.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/widgets/focus_manager.dart';

class DualKnights extends FlameGame with KeyboardEvents{
  late final CameraComponent cam;
  final world = Level();

  @override
  Color backgroundColor()  => const Color(0xFF211F30);
  @override
  FutureOr<void> onLoad() async{
    await images.loadAllImages();
    cam = CameraComponent.withFixedResolution(world: world, width: 1280, height: 960);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam,world]);
    return super.onLoad();
  }
  

  // @override
  // KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  //   {
  //   final isKeyDown = event is KeyDownEvent;
  //   log("Dual Knights : some key is pressed");
  //   final isSpace = keysPressed.contains(LogicalKeyboardKey.space);

  //   if (isSpace && isKeyDown) {
  //     if (keysPressed.contains(LogicalKeyboardKey.altLeft) ||
  //         keysPressed.contains(LogicalKeyboardKey.altRight)) {
  //       log("Dual Knights : some key is pressed");
  //     } else {
  //       log("Dual Knights : some key is pressed");
  //     }
  //     return KeyEventResult.handled;
  //   }
  //   return KeyEventResult.ignored;
  //   }
  // }

@override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // log("Dual Knights: key event received");
    
    world.children.forEach((component) {
      // log("Found component: ${component.runtimeType}");
      if (component is KeyboardHandler) {
        // log("Component is KeyboardHandler");
        // ignore: unnecessary_cast
        (component as KeyboardHandler).onKeyEvent(event, keysPressed);
      }
    });
    
    return KeyEventResult.handled;
  }

}
// ignore_for_file: implementation_imports, unnecessary_import

import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/level.dart';
import 'package:dual_knights/components/player.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/widgets/focus_manager.dart';

class DualKnights extends FlameGame with KeyboardEvents{
  late final CameraComponent cam;
  // final world = Level();

  @override
  Color backgroundColor()  => const Color(0xFF211F30);
  final player = Player()..debugMode = true;
  final antiPlayer = AntiPlayer()..debugMode = true;
  List<String> levelNames = ['Level-01', 'Level-01'];

  @override
  FutureOr<void> onLoad() async{
    await images.loadAllImages();
    _loadLevel();
    return super.onLoad();
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level world = Level(
        player: player,
        antiPlayer : antiPlayer,
        levelName: levelNames[0],
      );

      cam = CameraComponent.withFixedResolution(world: world, width: 1280, height: 960);
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll([cam, world]);
    });
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
    player.onKeyEvent(event, keysPressed);
    // antiPlayer.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

}
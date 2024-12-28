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
  
  @override
  Color backgroundColor()  => const Color(0xFF47ABA9);
  final player = Player();//..debugMode = true;
  final antiPlayer = AntiPlayer();//..debugMode = true;
  List<String> levelNames = ['Level-02', 'Level-02'];

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

      cam = CameraComponent.withFixedResolution(world: world, width: 16*64, height: 12*64);
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll([cam, world]);
    });
  }

@override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    player.onKeyEvent(event, keysPressed);
    antiPlayer.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

}
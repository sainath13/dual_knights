// lib/game/dual_knights_game.dart

import 'dart:async';
import 'dart:ui';
import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/screens/level_selection.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:dual_knights/routes/routes.dart';
import 'package:dual_knights/screens/login_screen.dart';
import 'package:flutter/material.dart' hide Route;

import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:dual_knights/state/game_state.dart';

class DualKnights extends FlameGame with KeyboardEvents {
  late final RouterComponent router;
  final gameState = GameState();
  List<String> levelNames = List.generate(100, (index) => 'Level-${(index + 1).toString().padLeft(2, '0')}');

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    
    // Initialize game state
    gameState.initializePlayers();

    router = RouterComponent(
      initialRoute: Routes.levelSelection,
      routes: {
        Routes.login: Route(() => LoginScreen()),
        Routes.levelSelection: Route(
          () => LevelSelectionScreen(levelNames: levelNames),
        ),
     
      },
    );

    add(router);
    return super.onLoad();
  }

  Player get player => gameState.player!;
  AntiPlayer get antiPlayer => gameState.antiPlayer!;

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


import 'package:dual_knights/dual_knights.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/pause_game_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  DualKnights game = DualKnights(); // Main game instance
  runApp(
    GameWidget<DualKnights>(
      game: game,
      overlayBuilderMap: {
        'pause_menu2': (BuildContext context, DualKnights game) {
          return GameWidget<PauseMenuGame>(
            game: PauseMenuGame(), // Use PauseMenuGame wrapper
          );
        },
      },
    ),
  );
}

class PauseMenuGame extends FlameGame {
  @override
  Future<void> onLoad() async {

    add(PauseMenu2()); // Add PauseMenu2 to the game
  }
}
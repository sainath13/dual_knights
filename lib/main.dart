import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/widgets/overlays/pause_button.dart';
import 'package:dual_knights/widgets/overlays/pause_menu.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  DualKnights game = DualKnights()..debugMode = true;
  runApp(
    GameWidget(
      game: true ? DualKnights() : game,
      initialActiveOverlays: const [PauseButton.id],
      overlayBuilderMap: {
        PauseButton.id: (BuildContext context, DualKnights game) =>
            PauseButton(
              game: game,
            ),
        PauseMenu.id: (BuildContext context, DualKnights game) =>
            PauseMenu(
              game: game,
            ),
        // GameOverMenu.id: (BuildContext context, DualKnights game) =>
        //     GameOverMenu(
        //       game: game,
        //     ),
      },
    ),
  );
}
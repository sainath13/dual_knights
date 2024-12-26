import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/widgets/overlays/pause_menu.dart';
import 'package:flutter/material.dart';


// This class represents the pause button overlay.
class PauseButton extends StatelessWidget {
  static const String id = 'PauseButton';
  final DualKnights game;

  const PauseButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
        child: const Icon(
          Icons.pause_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          game.pauseEngine();
          game.overlays.add(PauseMenu.id);
          game.overlays.remove(PauseButton.id);
        },
      ),
    );
  }
}
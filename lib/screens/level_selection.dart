// lib/screens/level_selection_screen.dart

import 'dart:async';
import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/level.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/widgets/level_button.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';


class LevelSelectionScreen extends Component {
  final List<String> levelNames;
  late final CameraComponent cam;
  final player = Player();
  final antiPlayer = AntiPlayer();
  late final SpriteComponent ribbonHeader;
  late final TextComponent headerText;

  LevelSelectionScreen({required this.levelNames});

 

  @override
  FutureOr<void> onLoad() async {
    const double buttonWidth = 100;
    const double buttonHeight = 100;
    const double spacing = 20;
    const double startX = 100;
    const double startY = 200;
    const double screenWidth = 1280;

    double x = startX;
    double y = startY;

    final ribbonSprite = await Sprite.load('UI/Ribbons/Ribbon_Red_3Slides.png');
    ribbonHeader = SpriteComponent(
      sprite: ribbonSprite,
      size: Vector2(400, 100), // Adjust size as needed
      position: Vector2(
        (screenWidth - 400) / 2, // Center horizontally
        20, // Top padding
      ),
    );
    add(ribbonHeader);

    // Add "Levels" text
    headerText = TextComponent(
      text: 'Levels',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(
        screenWidth / 2,
        60, // Vertically center in ribbon
      ),
    );
    add(headerText);

    for (var i = 0; i < levelNames.length; i++) {
      if (x + buttonWidth > screenWidth) {
        x = startX;
        y += buttonHeight + spacing;
      }

      final button = LevelButtonComponent(
        levelName: levelNames[i],
        onPressed: _loadLevel,
        position: Vector2(x, y),
        size: Vector2(buttonWidth, buttonHeight),
        starsEarned: 1,
      );
      add(button);

      x += buttonWidth + spacing;
    }
  }

  void _loadLevel(String levelName) {
    // Remove existing level if any
    parent?.findGame()?.children.whereType<CameraComponent>().forEach((camera) {
      camera.removeFromParent();
    });
    parent?.findGame()?.children.whereType<Level>().forEach((level) {
      level.removeFromParent();
    });

    // Create and add new level
    Future.delayed(const Duration(milliseconds: 100), () {
      final world = Level(
        player: player,
        antiPlayer: antiPlayer,
        levelName: levelName,
      );

      cam = CameraComponent.withFixedResolution(
        world: world,
        width: 1280,
        height: 960,
      );
      cam.viewfinder.anchor = Anchor.topLeft;

      // Add level components to the game
      parent?.findGame()?.addAll([cam, world]);
      // Add UI buttons



      // Remove level selection screen
      removeFromParent();
    });

    
  }
}
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../dual_knights.dart';
import '../main.dart';

class PauseMenu2 extends Component with HasGameRef<PauseMenuGame> {
  // Size for the pause menu
  final Vector2 menuSize = Vector2(6 * 64, 6 * 64);

  bool isMusicOn = true;
  bool isSfxOn = true;

  late SpriteComponent background;
  late SpriteComponent resumeButton;
  late SpriteComponent restartButton;
  late SpriteComponent exitButton;
  late SpriteComponent musicButton;
  late SpriteComponent sfxButton;

  @override
  Future<void> onLoad() async {
    // Load sprites
    final backgroundSprite = await Sprite.load('Factions/Knights/Troops/Warrior/Blue/Warrior_Blue.png');
    final buttonSprite = await Sprite.load('UI/Buttons/Button_Blue.png');
    final toggleOnSprite = await Sprite.load('UI/Buttons/Button_Blue.png');
    final toggleOffSprite = await Sprite.load('UI/Buttons/Button_Blue.png');

    // Add semi-transparent background
    background = SpriteComponent(
      sprite: backgroundSprite,
      size: menuSize,
      position: (gameRef.size - menuSize) / 2, // Center in the game view
    );
    add(background);

    // Button sizes
    final buttonWidth = menuSize.x * 0.8;
    final buttonHeight = menuSize.y * 0.15;
    final toggleSize = Vector2(buttonHeight, buttonHeight);

    // Resume Button
    resumeButton = SpriteComponent(
      sprite: buttonSprite,
      size: Vector2(buttonWidth, buttonHeight),
      position: background.position + Vector2(menuSize.x * 0.1, menuSize.y * 0.2),
    )..add(ButtonBehavior(
      onTap: () {
        gameRef.overlays.remove('pause_menu2'); // Close menu
        gameRef.resumeEngine(); // Resume game
      },
    ));
    add(resumeButton);

    // Restart Button
    restartButton = SpriteComponent(
      sprite: buttonSprite,
      size: Vector2(buttonWidth, buttonHeight),
      position: background.position + Vector2(menuSize.x * 0.1, menuSize.y * 0.4),
    )..add(ButtonBehavior(
      onTap: () {
        developer.log("Restarting game");
        gameRef.overlays.remove('pause_menu2'); // Close menu
        // gameRef.restart(); // Assuming a restart method exists
      },
    ));
    add(restartButton);

    // Exit Button
    exitButton = SpriteComponent(
      sprite: buttonSprite,
      size: Vector2(buttonWidth, buttonHeight),
      position: background.position + Vector2(menuSize.x * 0.1, menuSize.y * 0.6),
    )..add(ButtonBehavior(
      onTap: () {
        developer.log("Exiting to level selection");
        gameRef.overlays.remove('pause_menu2'); // Close menu
        // gameRef.exitToLevelSelection(); // Add your exit logic here
      },
    ));
    add(exitButton);

    // Music Toggle
    musicButton = SpriteComponent(
      sprite: toggleOnSprite,
      size: toggleSize,
      position: background.position + Vector2(menuSize.x * 0.3, menuSize.y * 0.8),
    )..add(ButtonBehavior(
      onTap: () {
        isMusicOn = !isMusicOn;
        musicButton.sprite = isMusicOn ? toggleOnSprite : toggleOffSprite;
      },
    ));
    add(musicButton);

    // SFX Toggle
    sfxButton = SpriteComponent(
      sprite: toggleOnSprite,
      size: toggleSize,
      position: background.position + Vector2(menuSize.x * 0.6, menuSize.y * 0.8),
    )..add(ButtonBehavior(
      onTap: () {
        isSfxOn = !isSfxOn;
        sfxButton.sprite = isSfxOn ? toggleOnSprite : toggleOffSprite;
      },
    ));
    add(sfxButton);
  }
}


// Helper class to handle button behavior
class ButtonBehavior extends Component with TapCallbacks {
  final Function onTap;
  bool isPressed = false;

  ButtonBehavior({required this.onTap});

  @override
  bool onTapDown(TapDownEvent event) {
    developer.log("Tap detected");
    isPressed = true;
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    developer.log("Tap detected");
    if (isPressed) {
      isPressed = false;
      onTap();
    }
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    developer.log("Tap detected");
    isPressed = false;
    return true;
  }
}
import 'dart:ui';


import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class PauseDialog extends PositionComponent{
  final VoidCallback onResume;
  final VoidCallback onExit;
  late final NineTileBoxComponent background;
  bool isMusicOn = true;
  bool isSFXOn = true;
  
  
  PauseDialog({
    required this.onResume,
    required this.onExit
  }) : super(
    position: Vector2(
      1280/2 - 400/2,  // screenWidth/2 - dialogWidth/2
      960/2 - 300,   // screenHeight/2 - dialogHeight/2
    ),
    size: Vector2(400, 80 + (100 * 4) + 100), // width, (startY + (spacing * (numButtons-1)) + extra padding)
  );

  @override
  Future<void> onLoad() async {
    // Dialog background
    final buttonSize = Vector2(64, 64);
    const double startY = 80;
    const double spacing = 100;
    
    final sprite = await Sprite.load('UI/Banners/Carved_9Slides.png');
    background = NineTileBoxComponent(
      nineTileBox: NineTileBox(sprite),
      size: size,
    );
    add(background);


  final closeButton = SpriteButtonComponent(
    button: await Sprite.load('UI/Ribbons/Ribbon_Yellow_Connection_Right.png'),
    buttonDown: await Sprite.load('UI/Ribbons/Ribbon_Yellow_Connection_Right_Pressed.png'),
    position: Vector2(size.x - 32, -32), // Positioned outside dialog top-right
    size: Vector2(32, 32), // Smaller size for close button
    onPressed: () {
      // onResume(); // Resume game
      removeFromParent(); // Remove dialog
    },
  );
  add(closeButton);

  final closeText = TextComponent(
      text: 'X',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: closeButton.position + (closeButton.size / 2),
    );
    add(closeText);


    // Resume button
    await _addButton(
      'Resume',
      Vector2(size.x/2 - buttonSize.x/2, startY),
      onResume,
    );

    // Level Selection Button
    await _addButton(
      'Level Selection',
      Vector2(size.x/2 - buttonSize.x/2, startY + spacing),
      onExit,
    );

    // Music Toggle Button
    await _addToggleButton(
      'Music',
      'UI/Buttons/Button_Blue_3Slides.png',
      'UI/Buttons/Button_Blue_3Slides_Pressed.png',
      Vector2(size.x/2 - buttonSize.x/2, startY + spacing * 2),
      () => isMusicOn = !isMusicOn,
      isMusicOn,
    );

    // SFX Toggle Button
    await _addToggleButton(
      'SFX',
      'UI/Buttons/Button_Blue_3Slides.png',
      'UI/Buttons/Button_Blue_3Slides_Pressed.png',
      Vector2(size.x/2 - buttonSize.x/2, startY + spacing * 3),
      () => isSFXOn = !isSFXOn,
      isSFXOn,
    );

    // Hints Button
    await _addButton(
      'Hints',
      Vector2(size.x/2 - buttonSize.x/2, startY + spacing * 4),
      () => _showHints(),
    );
  }



  Future<void> _addButton(
    String text,
    Vector2 position,
    VoidCallback onPressed,
  ) async {
    String normalSprite = 'UI/Buttons/Button_Blue_9Slides.png';
    String pressedSprite = 'UI/Buttons/Button_Blue_9Slides_Pressed.png';
    final button = SpriteButtonComponent(
      button: await Sprite.load(normalSprite),
      buttonDown: await Sprite.load(pressedSprite),
      position: position,
      size: Vector2(64, 64),
      onPressed: onPressed,
    );
    add(button);

    final label = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      anchor: Anchor.center,
      position: position + Vector2(32, 70),
    );
    add(label);
  }

  Future<void> _addToggleButton(
    String text,
    String normalSprite,
    String pressedSprite,
    Vector2 position,
    VoidCallback onPressed,
    bool isOn,
  ) async {
    await _addButton(
      '$text: ${isOn ? 'ON' : 'OFF'}',
      position,
      onPressed,
    );
  }


  void _showHints() {
    // Implement hints functionality
  }
}
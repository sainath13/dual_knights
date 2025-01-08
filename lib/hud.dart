import 'dart:async';
import 'dart:ui';

import 'package:dual_knights/components/arrow_keys.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/input.dart';
import 'package:dual_knights/rounded_background.dart';
import 'package:dual_knights/routes/gameplay.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Viewport;
import 'package:flutter/services.dart';

class Hud extends PositionComponent with ParentIsA<Viewport>, HasGameReference<DualKnights>,HasAncestor<Gameplay> {
  Hud({
    this.input,
    this.onPausePressed,
    required this.onRestartLevel,
  });

  late  JoystickComponent _joystick;
  final Input? input;
  final VoidCallback? onPausePressed;
  final VoidCallback onRestartLevel;
  LogicalKeyboardKey? lastDirection;
  var _joystickSettingListener;

  late HudButtonComponent _knightSelectionButton;
  bool _isBlueSelected = true;

  @override
  Future<void> onLoad() async {
    setupJoyStick();
    await addPauseButton();
    await addRestartButton();
    await addPlayAsOption();
  }

  Future<void> addPlayAsOption() async {
    final blueSprite = await game.images.load('Factions/Knights/Troops/Warrior/Blue/Warrior_Blue_Small.png');
    final redSprite = await game.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_Small.png');

    final background = RoundedBackgroundComponent(
    size: Vector2(100, 140), // Adjust to fit the button and text
    position: Vector2(parent.virtualSize.x - 80, parent.virtualSize.y - 100),
    backgroundPaint: Paint()
      ..color = const Color.fromARGB(255, 215, 215, 215).withOpacity(0.75)
      ..style = PaintingStyle.fill,
    borderRadius: 16.0, 
    anchor: Anchor.center,
  );

  await add(background);

    _knightSelectionButton = HudButtonComponent(
      button: SpriteComponent.fromImage(
        _isBlueSelected ? blueSprite : redSprite,
        size: Vector2.all(192),
      ),
      anchor: Anchor.center,
      position: Vector2(background.position.x, background.position.y + 20),
      onPressed: () {
        _toggleSprite(!_isBlueSelected);
        (_knightSelectionButton.button as SpriteComponent?)?.sprite = Sprite(
          _isBlueSelected ? blueSprite : redSprite,
        );
      },
    );
    await add(_knightSelectionButton);
    // Add text above the button
    final textComponent = TextComponent(
      text: 'Play As',
      textRenderer: TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontFamily: "DualKnights"
      ),
      ),
      anchor: Anchor.center,
      position: Vector2(background.position.x, background.position.y - 50),
    );
    await add(textComponent);
  }

  Future<void> addRestartButton() async {

    final background = RoundedBackgroundComponent(
    size: Vector2.all(50),
    position: Vector2(50,50),
    backgroundPaint: Paint()
      ..color = const Color.fromARGB(255, 215, 215, 215).withOpacity(0.75)
      ..style = PaintingStyle.fill,
    borderRadius: 16.0, 
    anchor: Anchor.center,
  );

  await add(background);

    final restartButton = HudButtonComponent(
      button: SpriteComponent.fromImage(
        await game.images.load('UI/Icons/pause.png'),
        size: Vector2.all(30),
      ),
      anchor: Anchor.center,
      position: background.position,
      onPressed: onRestartLevel,
    );
    await add(restartButton);
  }

  Future<void> addPauseButton() async {

    final background = RoundedBackgroundComponent(
    size: Vector2.all(50),
    position: Vector2(parent.virtualSize.x - 50, 50),
    backgroundPaint: Paint()
      ..color = const Color.fromARGB(255, 215, 215, 215).withOpacity(0.75)
      ..style = PaintingStyle.fill,
    borderRadius: 16.0, 
    anchor: Anchor.center,
  );

  await add(background);

    final pauseButton = HudButtonComponent(
      button: SpriteComponent.fromImage(
        await game.images.load('UI/Icons/pause.png'),
        size: Vector2.all(30),
      ),
      anchor: Anchor.center,
      position: background.position,
      onPressed: onPausePressed,
    );
    await add(pauseButton);
  }

  void _toggleSprite(bool isBlueSelected) { 
    _isBlueSelected = isBlueSelected;
    ancestor.input.setInversed(!isBlueSelected);
  }

    void _simulateKeyEvent(LogicalKeyboardKey key) {
    ancestor.input.pressedKeys.add(key);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Detect joystick direction
    if (_joystick.relativeDelta != Vector2.zero()) {
      LogicalKeyboardKey? currentDirection;

      if (_joystick.relativeDelta.x > 0.5) {
        currentDirection = LogicalKeyboardKey.arrowRight;
      } else if (_joystick.relativeDelta.x < -0.5) {
        currentDirection = LogicalKeyboardKey.arrowLeft;
      } else if (_joystick.relativeDelta.y > 0.5) {
        currentDirection = LogicalKeyboardKey.arrowDown;
      } else if (_joystick.relativeDelta.y < -0.5) {
        currentDirection = LogicalKeyboardKey.arrowUp;
      }

      // Log only if the direction has changed
      if (currentDirection != null && currentDirection != lastDirection) {
        _simulateKeyEvent(currentDirection);
        lastDirection = currentDirection;
      }
    } else {
      // Reset last direction when joystick returns to center
      ancestor.input.pressedKeys.clear();
      lastDirection = null;
    }
  }
  
  void setupJoyStick() async{

  final background = RoundedBackgroundComponent(
    size: Vector2.all(160),
    position: Vector2( 110, parent.virtualSize.y - 110),
    backgroundPaint: Paint()
      ..color = const Color.fromARGB(255, 215, 215, 215).withOpacity(0.75)
      ..style = PaintingStyle.fill,
    borderRadius: 16.0, 
    anchor: Anchor.center,
  );

  await add(background);

  _joystick = JoystickComponent(
  anchor: Anchor.center,
  position: background.position,
  knob: CircleComponent(
    radius: 50,
    paint: Paint()..color = Colors.grey,
  ),
  background: CircleComponent(
    radius: 60,
    paint: Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4,
  ),
);



      var arrowKeysComponent = ArrowKeysComponent(
            onDirectionPressed: (direction) {
              switch (direction) {
                case 'up':
                  _simulateKeyEvent(LogicalKeyboardKey.arrowUp);
                  break;
                case 'down':
                  _simulateKeyEvent(LogicalKeyboardKey.arrowDown);
                  break;
                case 'left':
                  _simulateKeyEvent(LogicalKeyboardKey.arrowLeft);
                  break;
                case 'right':
                  _simulateKeyEvent(LogicalKeyboardKey.arrowRight);
                  break;
              }
            },
          );
      arrowKeysComponent.position = background.position;
      

       _joystickSettingListener = () {
      if (game.analogueJoystick.value) {
        remove(arrowKeysComponent);
        add(_joystick);
      } else {
        add(arrowKeysComponent);
        remove(_joystick);
      }
    };

    game.analogueJoystick.addListener(_joystickSettingListener);
      
    if(game.analogueJoystick.value==true){
        add(_joystick);
    }else{
      add(arrowKeysComponent);
    }
      
    
      
    }
    

  @override
  void onRemove() {
    
    game.analogueJoystick.removeListener(_joystickSettingListener);
    super.onRemove();
  }
    

  }





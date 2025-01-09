import 'dart:async';

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
  final Map<String, SpriteAnimation> characterAnimations = {}; // Map of available character animations
  int currentPriority = 0; // Tracks the priority of the currently displayed dialogue
  bool _isDialogueActive = false; // Tracks if a dialogue is currently active
  PositionComponent? _activeDialogueBox; 
  var _dialogueListener;

  @override
  Future<void> onLoad() async {
    setupJoyStick();
    await addPauseButton();
    await addRestartButton();
    await addPlayAsOption();

    await loadDialogueCharacterSprites();
    _dialogueListener = () {
        _updateDialogue(game.dialogueNotifier.value);
    };
    game.dialogueNotifier.addListener(_dialogueListener);
  }

  Future<void> loadDialogueCharacterSprites() async {
    characterAnimations['Blue Knight'] = await game.loadSpriteAnimation(
      'Factions/Knights/Troops/Warrior/Blue/Warrior_Blue.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0,16),
        amount: 6,
        textureSize: Vector2(192, 192),
        stepTime: 0.1,
        loop: true,
      ),
    );

    characterAnimations['Red Knight'] = await game.loadSpriteAnimation(
      'Factions/Knights/Troops/Warrior/Red/Warrior_Red.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0,16),
        amount: 6,
        textureSize: Vector2(192, 192),
        stepTime: 0.1,
        loop: true,
      ),
    );

    characterAnimations['Barell'] = await game.loadSpriteAnimation(
      'Factions/Goblins/Troops/Barrel/Red/Barrel_Red.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0,16),
        amount: 1,
        textureSize: Vector2(128, 128),
        stepTime: 0.1,
        loop: true,
      ),
    );
  }

  Future<void> addPlayAsOption() async {
    final blueSprite = await game.images.load('Factions/Knights/Troops/Warrior/Blue/Warrior_Blue_Small.png');
    final redSprite = await game.images.load('Factions/Knights/Troops/Warrior/Red/Warrior_Red_Small.png');

    final background = RoundedBackgroundComponent(
    size: Vector2(140, 140), // Adjust to fit the button and text
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
    


Future<void> _updateDialogue(Map<String, String> dialogue) async {
  // Extract dialogue details
  final characterName = dialogue['characterName'] ?? '';
  final characterDialogue = dialogue['dialogue'] ?? '';
  final priority = int.tryParse(dialogue['priority'] ?? '0') ?? 0;

  // Skip if a lower priority dialogue tries to override
  if (_isDialogueActive && priority <= currentPriority) return;

  // Cancel any ongoing dialogue
  _isDialogueActive = false; // Reset the active flag
  if (_activeDialogueBox != null && _activeDialogueBox!.isMounted) {
    remove(_activeDialogueBox!);
    _activeDialogueBox = null;
  }

  // If there's no dialogue, return early
  if (characterName.isEmpty && characterDialogue.isEmpty) {
    currentPriority = 0; // Reset priority
    return;
  }

  // Mark the dialogue as active
  _isDialogueActive = true;
  currentPriority = priority;

  // Create dialogue background
  final dialogueBackground = RoundedBackgroundComponent(
    size: Vector2(parent.virtualSize.x / 2 + 100, 120),
    position: Vector2(parent.virtualSize.x / 2, parent.virtualSize.y - 120),
    backgroundPaint: Paint()
      ..color = const Color.fromARGB(255, 215, 215, 215).withOpacity(0.75)
      ..style = PaintingStyle.fill,
    borderRadius: 16.0,
    anchor: Anchor.center,
  );
  _activeDialogueBox = dialogueBackground;
  await add(dialogueBackground);

  // Add character name
  final nameComponent = TextComponent(
    text: characterName,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    anchor: Anchor.topLeft,
    position: Vector2(20, 10),
    priority: 101,
  );
  await dialogueBackground.add(nameComponent);

  // Add character sprite if available
  SpriteAnimationComponent? spriteComponent;
  if (characterAnimations.containsKey(characterName)) {
    spriteComponent = SpriteAnimationComponent(
      animation: characterAnimations[characterName]!,
      size: Vector2(150, 150), // Size of the character sprite
      position: Vector2(-20, 20),
      anchor: Anchor.topLeft,
      priority: 101,
    );
    await dialogueBackground.add(spriteComponent);
  }

  // Add dialogue text
  final dialoguePosition = spriteComponent != null
      ? Vector2(90, 40) // Dialogue position when sprite is present
      : Vector2(20, 40); // Dialogue position when no sprite is present
  final dialogueComponent = TextComponent(
    text: '', // Initially empty for word-by-word animation
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    ),
    anchor: Anchor.topLeft,
    position: dialoguePosition,
    priority: 101,
  );
  await dialogueBackground.add(dialogueComponent);

  // Load text word by word
  final words = characterDialogue.split(' ');
  String currentText = '';
  for (final word in words) {
    if (!_isDialogueActive) return; // Stop if dialogue has been canceled
    currentText += '$word ';
    dialogueComponent.text = currentText;
    await Future.delayed(const Duration(milliseconds: 300)); // Adjust word speed
  }

  // Wait for 5 seconds before allowing the next update
  //TODO SARVESH Does the thread gets stuck here? If it gets stuck its not a good idea.
  await Future.delayed(const Duration(seconds: 5));
  if (!_isDialogueActive) return; // Stop if dialogue has been canceled

  // Remove the dialogue after the duration, but ensure it's still attached
  if (_activeDialogueBox != null && _activeDialogueBox!.isMounted) {
    remove(dialogueBackground);
    _activeDialogueBox = null;
  }

  _isDialogueActive = false;
  currentPriority = 0; // Reset priority
}

  @override
  void onRemove() {
    
    game.analogueJoystick.removeListener(_joystickSettingListener);
    game.dialogueNotifier.removeListener(_dialogueListener);
    super.onRemove();
  }
    

  }





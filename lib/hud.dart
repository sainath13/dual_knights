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
    
    this.onPausePressed,
    required this.onRestartLevel,
  });

  late  JoystickComponent _joystick;
  
  final VoidCallback? onPausePressed;
  final VoidCallback onRestartLevel;
  LogicalKeyboardKey? lastDirection;
  var _joystickSettingListener;
  
  late HudButtonComponent _knightSelectionButton;
  bool _isBlueSelected = true;
  final Map<String, SpriteAnimation> characterAnimations = {}; // Map of available character animations
  int currentPriority = 0; // Tracks the priority of the currently displayed dialogue
   // Tracks if a dialogue is currently active
  PositionComponent? _activeDialogueBox; 
  bool _isUpdatingDialogue = false;
  var _dialogueListener;
  var _stepCountListener = null;

  @override
  Future<void> onLoad() async {
    setupJoyStick();
    await addPauseButton();
    await addRestartButton();
    await addPlayAsOption();
    await addStepCount();

    await loadDialogueCharacterSprites();
    _dialogueListener = () {
        _updateDialogue(game.dialogueNotifier.value);
    };
    game.dialogueNotifier.addListener(_dialogueListener);
    
  }

  Future<void> loadDialogueCharacterSprites() async {
    characterAnimations['Aqua Knight'] = await game.loadSpriteAnimation(
      'Factions/Knights/Troops/Warrior/Blue/Warrior_Blue.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0,16),
        amount: 6,
        textureSize: Vector2(192, 192),
        stepTime: 0.1,
        loop: true,
      ),
    );

    characterAnimations['Flame Knight'] = await game.loadSpriteAnimation(
      'Factions/Knights/Troops/Warrior/Red/Warrior_Red.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0,16),
        amount: 6,
        textureSize: Vector2(192, 192),
        stepTime: 0.1,
        loop: true,
      ),
    );

    characterAnimations['Barrel'] = await game.loadSpriteAnimation(
      'Factions/Goblins/Troops/Barrel/Red/Barrel_Red.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0,128+16),
        amount: 6,
        textureSize: Vector2(128, 128),
        stepTime: 0.1,
        loop: true,
      ),
    );

    characterAnimations['Archer'] = await game.loadSpriteAnimation(
      'Factions/Knights/Troops/Archer/Purple/Archer_Purple.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2.all(0),
        amount: 6,
        textureSize: Vector2(128, 128),
        stepTime: 0.1,
        loop: true,
      ),
    );

    characterAnimations['Moving Barrel'] = await game.loadSpriteAnimation(
      'Factions/Goblins/Troops/Barrel/Blue/Barrel_Blue.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0, 128*4+16),
        amount: 3,
        textureSize: Vector2(128,128),
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
        await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Icon/Replay@2x-1.png'),
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
    if(!ancestor.input.pressedKeys.isEmpty){
      ancestor.input.pressedKeys.clear();
      ancestor.addStepCount();
    }
    

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
  // print("Updating dialogue: $dialogue");
  final characterName = dialogue['characterName'] ?? '';
  final characterDialogue = dialogue['dialogue'] ?? '';
  final priority = int.tryParse(dialogue['priority'] ?? '0') ?? 0;

  // Ignore empty dialogues
  if (characterName.isEmpty && characterDialogue.isEmpty) {
    return;
  }

  // Ensure synchronized access to dialogue updates
  if (_isUpdatingDialogue) return;
  _isUpdatingDialogue = true;

  try {
    // Handle priority: Remove current dialogue if the new one is higher priority
    if (_activeDialogueBox != null && priority > currentPriority) {
      if (_activeDialogueBox!.isMounted) {
        remove(_activeDialogueBox!);
      }
      _activeDialogueBox = null;
      game.isDialogueActive = false;
    }

    // Skip lower-priority dialogues if a dialogue is already active
    if (game.isDialogueActive && priority <= currentPriority) {
      _isUpdatingDialogue = false; // Allow other dialogues to proceed
      return;
    }

    // Update state for the new dialogue
    game.isDialogueActive = true;
    currentPriority = priority;

    // Create and display dialogue box
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
    size: Vector2(150, 150),
    position: Vector2(-20, 20),
    anchor: Anchor.topLeft,
    priority: 101,
  );
  await dialogueBackground.add(spriteComponent);
}

// Calculate dialogue position and width
final dialoguePosition = spriteComponent != null
    ? Vector2(90, 40)
    : Vector2(20, 40);
final dialogueWidth = dialogueBackground.size.x - dialoguePosition.x - 20;

// Add dialogue text using TextBoxComponent
final dialogueComponent = TextBoxComponent(
  text: '',
  textRenderer: TextPaint(
    style: const TextStyle(
      color: Colors.black,
      fontSize: 16,
    ),
  ),
  boxConfig: TextBoxConfig(
    maxWidth: dialogueWidth, // Set max width for wrapping text
    timePerChar: 0.03,      // Adjust the speed of appearing text
  ),
  anchor: Anchor.topLeft,
  position: dialoguePosition,
  priority: 101,
);
await dialogueBackground.add(dialogueComponent);

// Display dialogue text word by word
for (final word in characterDialogue.split(' ')) {
  if (!game.isDialogueActive || currentPriority != priority) return;
  dialogueComponent.text += '$word ';
  await Future.delayed(const Duration(milliseconds: 300));
}


    // Keep the dialogue visible for 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    if (!game.isDialogueActive || currentPriority != priority) return;

    // Remove the dialogue if still active
    if (_activeDialogueBox != null && _activeDialogueBox!.isMounted) {
      remove(_activeDialogueBox!);
      _activeDialogueBox = null;
    }

    // Reset state after removal
    game.isDialogueActive = false;
    currentPriority = 0;
  } finally {
    _isUpdatingDialogue = false; // Unlock updates
  }
}





  @override
  void onRemove() {
    
    game.analogueJoystick.removeListener(_joystickSettingListener);
    game.dialogueNotifier.removeListener(_dialogueListener);
    game.stepCountNotifier.removeListener(_stepCountListener);
    super.onRemove();
  }
  

    Future<void> addStepCount() async {
      final stepCountBackground = RoundedBackgroundComponent(
        size: Vector2(100, 50),
        position: Vector2(parent.virtualSize.x / 2, 30),
        backgroundPaint: Paint()
          ..color = const Color.fromARGB(255, 215, 215, 215).withOpacity(0.75)
          ..style = PaintingStyle.fill,
        borderRadius: 16.0,
        anchor: Anchor.center,
      );

      await add(stepCountBackground);

      final stepCountText = TextComponent(
        text: 'Steps: 0',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: "DualKnights",
          ),
        ),
        anchor: Anchor.center,
        position: stepCountBackground.size / 2,
      );

      await stepCountBackground.add(stepCountText);

      _stepCountListener = () {
        stepCountText.text = 'Steps: ${game.stepCountNotifier.value}';
      };
      
      game.stepCountNotifier.addListener(_stepCountListener);
    }
  }





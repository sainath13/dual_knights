import 'dart:math';

import 'package:dual_knights/components/camera_movement.dart';
import 'package:dual_knights/components/game_button.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/model/user_progress_model.dart';
import 'package:dual_knights/repository/game_repository.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';

class GameLevelSelection extends PositionComponent
    with HasGameRef<DualKnights>, TapCallbacks {
  static const id = 'GameLevelSelection';

  late TiledComponent gameLevelSelection;
  late final World _world;
  late final CameraComponent _camera;
  final ValueChanged<int>? onLevelSelected;
  final VoidCallback? onBackPressed;
  Vector2 dragStart = Vector2.zero();

  double cameraViewportWidth = 24 * 64; // 832
  double cameraViewportHeight = 12 * 64;
  final GameRepository gameRepository;

  GameLevelSelection({
    super.key,
    required this.onLevelSelected,
    required this.onBackPressed,
    required this.gameRepository,
  });

  @override
  Future<void> onLoad() async {
    game.updateBackgroundColor(Color(0xFFC9AA8D));
    await loadGameLevelSelection();
    GameButton backButton = GameButton(
      onClick: () => onBackPressed?.call(),
      size: Vector2(40, 40),
      position: Vector2(30, 15),
      normalSprite: Sprite(await game.images.load(
          'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowLeft-Thin/Default@2x-1.png')),
      onTapSprite: Sprite(await game.images.load(
          'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowLeft-Thin/Hover@2x-1.png')),
      buttonText: '',
    );
    _camera.viewport.add(backButton);
    super.onLoad();
    // Load your assets and initialize your component here
  }

  @override
  void onRemove() {
    game.updateDefaultBackgroundColor();
    _world.removeFromParent();
    _camera.removeFromParent();
    super.onRemove();
  }

  void moveCamera(int direction, double viewportWidth, double tmxWidth) {
    double duration = 0.5;
    final currentPosition = _camera.viewfinder.position;
    final offset = direction * 64 * 14;
    final targetX = (currentPosition.x + offset)
        .clamp(viewportWidth / 2, tmxWidth - viewportWidth / 2);

    final startPosition = currentPosition.clone();
    final targetPosition = Vector2(targetX, currentPosition.y);

    // Add a custom component to handle smooth movement
    game.add(
      CameraMovementComponent(
        camera: _camera,
        startPosition: startPosition,
        targetPosition: targetPosition,
        duration: duration,
      ),
    );
  }

  Future<void> loadGameLevelSelection() async {
    Map<int, LevelProgress> levelData = {};

    levelData = await loadUserProgress(levelData);

    var lastLevelUnlocked = 25;
    gameLevelSelection = await TiledComponent.load(
        'tutorial.tmx', Vector2(64, 64),
        atlasMaxX: 5000, atlasMaxY: 5000);

    // 1408
    _world = World(children: [gameLevelSelection]);
    await add(_world);
    _camera = CameraComponent.withFixedResolution(
      width: cameraViewportWidth,
      height: cameraViewportHeight,
      world: _world,
    );

    final initialCameraX = cameraViewportWidth / 2; // Center horizontally
    final initialCameraY = cameraViewportHeight / 2; // Center vertically
    _camera.moveTo(Vector2(initialCameraX, initialCameraY));
    await add(_camera);

    final navigationButtons =
        gameLevelSelection.tileMap.getLayer<ObjectGroup>('NavigationButtons');
    if (navigationButtons != null) {
      for (final button in navigationButtons.objects) {
        switch (button.class_) {
          case 'LeftNavigation':
            final leftButton = GameButton(
              onClick: () => moveCamera(
                  -1, cameraViewportWidth, gameLevelSelection.size.x),
              size: Vector2(button.width / 1.1, button.height / 1.1),
              position: Vector2(button.x, button.y),
              normalSprite: Sprite(await game.images.load(
                  'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowLeft-Bold/Default@2x-1.png')),
              onTapSprite: Sprite(await game.images.load(
                  'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowLeft-Bold/Hover@2x-1.png')),
              buttonText: '',
            );
            _world.add(leftButton);
            break;
          case 'RightNavigation':
            final rightButton = GameButton(
              onClick: () =>
                  moveCamera(1, cameraViewportWidth, gameLevelSelection.size.x),
              size: Vector2(button.width / 1.1, button.height / 1.1),
              position: Vector2(button.x, button.y),
              normalSprite: Sprite(await game.images.load(
                  'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowRight-Bold/Default@2x-1.png')),
              onTapSprite: Sprite(await game.images.load(
                  'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowRight-Bold/Hover@2x-1.png')),
              buttonText: '',
            );
            _world.add(rightButton);
            break;
          case 'StageOne':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 48.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'STAGE ONE',
              textRenderer: textPaint,
              position: Vector2(button.x + 64 + 64 + 16, button.y + 24),
              // Position from the Tiled object
              anchor: Anchor.center, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'StageTwo':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 48.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'STAGE TWO',
              textRenderer: textPaint,
              position: Vector2(button.x + 64 + 64 + 16, button.y + 24),
              // Position from the Tiled object
              anchor: Anchor.center, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'StageThree':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 48.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'STAGE THREE',
              textRenderer: textPaint,
              position: Vector2(button.x + 64 + 64 + 16, button.y + 24),
              // Position from the Tiled object
              anchor: Anchor.center, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'DevelopedFor':
            final document = DocumentRoot([
              ParagraphNode.simple(
                'This game is developed for AWS Game Builder Challenge hosted on Devpost.',
              ),
            ]);
            // Define the document style with the custom font
            final style = DocumentStyle(
              text: InlineTextStyle(
                fontSize: 32.0, // Adjust font size
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Use your custom font family
              ),
              paragraph:
                  BlockStyle(margin: EdgeInsets.all(10)), // Optional spacing
            );
            final textElement = TextElementComponent.fromDocument(
              document: document,
              position: Vector2(button.x, button.y + 24),
              // Position from the Tiled object
              size: Vector2(button.width, button.height),
              // Area size for the text
              style: style, // Apply the custom styl
            );

            _world.add(textElement);
            break;
        }
      }
    }

    final textAreaLayer =
        gameLevelSelection.tileMap.getLayer<ObjectGroup>('TextArea');
    if (textAreaLayer != null) {
      for (final area in textAreaLayer.objects) {
        switch (area.class_) {
          //TODO could have been down with properites in tmx
          case 'GameStory':
            final document = DocumentRoot([
              ParagraphNode.simple(
                "In a kingdom gripped by a powerful curse, the Dual Knights—the Blue Knight and the Red Knight—are bound by a mystical spell that forces them to move in perfect opposition. Together, they must journey through perilous landscapes filled with deadly traps, treacherous barriers, and explosive dangers to restore balance to the realm.Their goal is to reach the sacred Blue Sigil and Red Sigil—ancient symbols of power that hold the key to breaking the curse. But there's a catch: both knights must stand on their respective sigils at the exact same moment to unlock the path forward. Any misstep could spell doom for their mission, and a clash between them would end their journey in a tragic battle.\n\n",
              ),
            ]);
            // Define the document style with the custom font
            final style = DocumentStyle(
              text: InlineTextStyle(
                fontSize: 30.0, // Adjust font size
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Use your custom font family
              ),
              paragraph:
                  BlockStyle(margin: EdgeInsets.all(10)), // Optional spacing
            );
            final textElement = TextElementComponent.fromDocument(
              document: document,
              position: Vector2(area.x, area.y),
              // Position from the Tiled object
              size: Vector2(area.width, area.height),
              // Area size for the text
              style: style, // Apply the custom style
            );
            _world.add(textElement);
            break;
          case "GameRules":
            final document = DocumentRoot([
              ParagraphNode.simple(
                "In this ultimate test of harmony and precision,\n the Dual Knights must rely on their unwavering bond as warriors to succeed. Only by mastering their opposing movements can they uncover the truth behind the sigils and bring salvation to their world.",
              ),
            ]);
            // Define the document style with the custom font
            final style = DocumentStyle(
              text: InlineTextStyle(
                fontSize: 30.0, // Adjust font size
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Use your custom font family
              ),
              paragraph:
                  BlockStyle(margin: EdgeInsets.all(10)), // Optional spacing
            );
            final textElement = TextElementComponent.fromDocument(
              document: document,
              position: Vector2(area.x, area.y),
              // Position from the Tiled object
              size: Vector2(area.width, area.height),
              // Area size for the text
              style: style, // Apply the custom style
            );
            _world.add(textElement);
            break;

          case 'MoveUp':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 30.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Moves Up',
              textRenderer: textPaint,
              position: Vector2(area.x + 32, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'MoveDown':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 32.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Moves Down',
              textRenderer: textPaint,
              position: Vector2(area.x + 32, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;

          case 'MoveLeft':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 30.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Moves Left',
              textRenderer: textPaint,
              position: Vector2(area.x + 32, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'MoveRight':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 32.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Moves Right',
              textRenderer: textPaint,
              position: Vector2(area.x + 32, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;

          case 'AntiMovesUp':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 30.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Moves Up',
              textRenderer: textPaint,
              position: Vector2(area.x + 32, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'AntiMovesDown':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 32.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Moves Down',
              textRenderer: textPaint,
              position: Vector2(area.x + 32, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;

          case 'AntiMovesLeft':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 30.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Moves Left',
              textRenderer: textPaint,
              position: Vector2(area.x + 32, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'AntiMovesRight':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 32.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Moves Right',
              textRenderer: textPaint,
              position: Vector2(area.x + 32, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'W':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 32.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'W',
              textRenderer: textPaint,
              position: Vector2(area.x + 22, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'A':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 32.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'A',
              textRenderer: textPaint,
              position: Vector2(area.x + 22 , area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'S':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 32.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'S',
              textRenderer: textPaint,
              position: Vector2(area.x + 22, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'D':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 32.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'D',
              textRenderer: textPaint,
              position: Vector2(area.x + 24, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'StationaryBarrel':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 30.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Stationary Barrel',
              textRenderer: textPaint,
              position: Vector2(area.x + 32, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;

          case 'ExplodesOnCollision':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 28.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Explodes On Collision',
              textRenderer: textPaint,
              position: Vector2(area.x + 16, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'MovingBarrel':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 30.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Moving Barrel',
              textRenderer: textPaint,
              position: Vector2(area.x + 16+4, area.y + 16+8),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          case 'MovingExplodesOnCollision':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 28.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Explodes On Collision',
              textRenderer: textPaint,
              position: Vector2(area.x+16, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);
            break;
          //JoiningFightSoon
          case 'JoiningFightSoon':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 30.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Coming Soon',
              textRenderer: textPaint,
              position: Vector2(area.x+32, area.y + 32),
              // Position from the Tiled object
              anchor: Anchor.centerLeft, // Align the text to the center
            );
            _world.add(textComponent);

          default:
            break;
        }
      }
    }
  }

  Future<Map<int, LevelProgress>> loadUserProgress(
      Map<int, LevelProgress> levelData) async {
    final jwtToken = await game.getJwtToken();
    final userProgress = await gameRepository.getUserProgress(jwtToken);
    print('User progress: ${userProgress.levelProgress}');
    levelData = userProgress.levelProgress;
    return levelData;
  }
}

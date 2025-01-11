import 'dart:ui';

import 'package:dual_knights/components/game_button.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/text.dart';

class GameLevelComplete extends PositionComponent with HasGameRef<DualKnights>{
  

  static const id = 'GameLevelComplete';
  late TiledComponent gameLevelComplete;
  late final World _world;
  late final CameraComponent _camera;

  final int nStars;
  final VoidCallback? onNextPressed;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onExitPressed;


   GameLevelComplete({
    required this.nStars,
    super.key,
    this.onNextPressed,
    this.onRetryPressed,
    this.onExitPressed,
  });


  @override
  Future<void> onLoad() async {
    await loadGameCompletionScreen();
    super.onLoad();
    // Initialize your component here
  }
  @override
  void onRemove() {
    _world.removeFromParent();
    _camera.removeFromParent();
    super.onRemove();
  }
 

  Future<void> loadGameCompletionScreen() async {
    gameLevelComplete = await TiledComponent.load('Level-Completed-Menu.tmx', Vector2(64, 64));
    // gameLevelComplete = await TiledComponent.load('Level-for-Sarvesh.tmx', Vector2(64, 64));
    // add(gameLevelComplete);
    _world = World(children: [gameLevelComplete]);
    await add(_world);
    _camera = CameraComponent.withFixedResolution(
      width: 16*64, height: 12*64,
      world: _world,
    );
    _camera.moveTo(Vector2(gameLevelComplete.size.x * 0.5, _camera.viewport.virtualSize.y*0.5));
    await add(_camera);


    final buttonsLayer = gameLevelComplete.tileMap.getLayer<ObjectGroup>('ButtonsSpawnLayer');
    if (buttonsLayer != null) {
      for (final button in buttonsLayer.objects) {
        switch (button.class_) {
          case 'Restart':
            final restartButton = GameButton(
              onClick: onRetryPressed,
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              normalSprite : Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Button/Square/Fill/Default.png')),
              onTapSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Button/Square/Fill/Hover.png')),
              buttonText: 'Restart',
            );
            _world.add(restartButton);
            break;
          case 'Exit':
            final exitButton = GameButton(
              onClick:onExitPressed,
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              normalSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Button/Square/Fill/Default.png')),
              onTapSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Button/Square/Fill/Hover.png')),
              buttonText: 'Exit',
            );
            _world.add(exitButton);
            break;
          case 'Next':  
            final nextButton = GameButton(
              onClick: onNextPressed,
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              normalSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Button/Square/Fill/Default.png')),
              onTapSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Button/Square/Fill/Hover.png')),
              buttonText: 'Next',
            );
            _world.add(nextButton);
            break;
          }


    }
  }

  final starSpawnLayer = gameLevelComplete.tileMap.getLayer<ObjectGroup>('StarSpawnLayer');
    if (starSpawnLayer != null) {
      for (final button in starSpawnLayer.objects) {
        switch (button.class_) {
          case 'StarPositionOne':
            final star = SpriteComponent(
              sprite: Sprite(await game.images.load(
                nStars >= 1 ? 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Active.png' 
                : 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Unactive.png'
              )),
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
            );
            _world.add(star);
            break;
          case 'StarPositionTwo':
            final star = SpriteComponent(
              sprite: Sprite(await game.images.load(
                nStars >= 2 ? 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Active.png' 
                : 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Unactive.png'
              )),
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
            );
            _world.add(star);
            break;
          case 'StarPositionThree':
            final star = SpriteComponent(
              sprite: Sprite(await game.images.load(
                nStars >= 3 ? 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Active.png' 
                : 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Unactive.png'
              )),
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
            );
            _world.add(star);
            break;
          case 'Completion':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 48.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Level Completed',
              textRenderer: textPaint,
              position: Vector2(button.x+64+32+16+8, button.y+20), // Position from the Tiled object
              anchor: Anchor.center, // Align the text to the center
            );
            _world.add(textComponent);
            break;

        }
      }
    }
}}
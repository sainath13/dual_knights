
import 'dart:math';

import 'package:dual_knights/components/camera_movement.dart';
import 'package:dual_knights/components/game_button.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';

class GameLevelSelection extends PositionComponent with HasGameRef<DualKnights>, TapCallbacks  {

  static const id = 'GameLevelSelection';
  
  late TiledComponent gameLevelSelection;
  late final World _world;
  late final CameraComponent _camera;
  final ValueChanged<int>? onLevelSelected;
  final VoidCallback? onBackPressed;
  Vector2 dragStart = Vector2.zero();

  double cameraViewportWidth = 24 * 64; // 832
  double cameraViewportHeight = 12 * 64; 


 GameLevelSelection({
    super.key,
    required this.onLevelSelected,
    required this.onBackPressed,
  });

  @override
  Future<void> onLoad() async {
    await loadGameLevelSelection();
    GameButton backButton = GameButton(
        onClick: () => onBackPressed?.call(),
        size: Vector2(40, 40),
        position: Vector2(30, 15),
        normalSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowLeft-Thin/Default@2x-1.png')),
        onTapSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowLeft-Thin/Hover@2x-1.png')),
        buttonText: '',
    );
    _camera.viewport.add(backButton);
    super.onLoad();
    // Load your assets and initialize your component here
  }

   @override
  void onRemove() {
    _world.removeFromParent();
    _camera.removeFromParent();
    super.onRemove();
  }

  void moveCamera(int direction, double viewportWidth, double tmxWidth) {
  double duration = 0.5;
  final currentPosition = _camera.viewfinder.position;
  final offset = direction * 64 * 14;
  final targetX = (currentPosition.x + offset).clamp(viewportWidth / 2, tmxWidth - viewportWidth / 2);

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



    var levelData = {1: {"locked": false, "stars": 3}, 2: {"locked": false, "stars": 1},3: {"locked": false, "stars": 3},4: {"locked": false, "stars": 1},5: {"locked": false, "stars": 1},6: {"locked": false, "stars": 1},7: {"locked": false, "stars": 1},8: {"locked": false, "stars": 1},9: {"locked": false, "stars": 1},10: {"locked": false, "stars": 1},};
    var lastLevelUnlocked  = 25;
    gameLevelSelection = await TiledComponent.load('level-selection-final.tmx', Vector2(64, 64),atlasMaxX: 5000,atlasMaxY: 5000);

    // 1408
    _world = World(children: [gameLevelSelection]);
    await add(_world);
    _camera = CameraComponent.withFixedResolution(
      width: cameraViewportWidth, height: cameraViewportHeight,
      world: _world,
    );

  final initialCameraX = cameraViewportWidth / 2; // Center horizontally
  final initialCameraY = cameraViewportHeight / 2; // Center vertically
  _camera.moveTo(Vector2(initialCameraX, initialCameraY));
  await add(_camera);


final buttonsLayer = gameLevelSelection.tileMap.getLayer<ObjectGroup>('Level');
if (buttonsLayer != null) {
  for (final button in buttonsLayer.objects) {
    final levelName = button.name; // E.g., 'Level-01', 'Level-02', etc.
    if (levelName != null && levelName.startsWith('Level-')) {
      final levelIndex = int.parse(levelName.split('-')[1]); // Extract level index (e.g., 1, 2, etc.)
      
      // Assuming you have some level data like this:
      
      final levelInfo = levelData[levelIndex]; 
      final isLocked = levelInfo?['locked'] ?? true;
      final stars = levelInfo?['stars'] ?? 0;

      // Common button size and position
      final buttonSize = Vector2(button.width, button.height);
      final buttonPosition = Vector2(button.x, button.y+6);

      

      if (isLocked==true) {
        // Locked level: Display a lock icon
        final lockSprite = Sprite(await game.images.load('UI/Icons/Regular_10.png'));
        final lockButton = SpriteComponent(
          sprite: lockSprite,
          size: buttonSize,
          position: buttonPosition,
        );
        _world.add(lockButton);
      } else {


        GameButton gameButton = GameButton(
          onClick: () => onLevelSelected?.call(levelIndex),
          size: Vector2(button.width, button.height),
          position: Vector2(button.x, button.y),
          buttonText: '$levelIndex',
        );
        _world.add(gameButton);

        // Add stars at the bottom of the button if stars > 0
        for (int i = 0; i < 3; i++) {
          final starSprite = Sprite(await game.images.load(
            i < (stars as int)
              ? 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png@2x/Level/Star/Active@2x.png'
              : 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png@2x/Level/Star/Unactive@2x.png'
          ));
          // final starSprite = Sprite(await game.images.load(
          //     i < (stars as int)
          //         ? 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Active.png'
          //         : 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Unactive.png'
          // ));
          final starSize = Vector2(16+5, 16+4);
          final starPosition = buttonPosition +
              Vector2(
                (buttonSize.x - (3 * starSize.x + (3 - 1) * 4)) / 2 + i * (starSize.x + 4),
                buttonSize.y -20,
              );

          final starComponent = SpriteComponent(
            sprite: starSprite,
            size: starSize,
            position: starPosition,
          );

          _world.add(starComponent);
        }
      }
    }
  }
} 


final navigationButtons = gameLevelSelection.tileMap.getLayer<ObjectGroup>('NavigationButtons');
if (navigationButtons != null) {
  for (final button in navigationButtons.objects) {
    switch (button.class_) {
      case 'LeftNavigation':
       final leftButton = GameButton(
        onClick: () => moveCamera(-1,  cameraViewportWidth,gameLevelSelection.size.x),
        size: Vector2(button.width/1.1, button.height/1.1),
        position: Vector2(button.x, button.y),
        normalSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowLeft-Bold/Default@2x-1.png')),
        onTapSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowLeft-Bold/Hover@2x-1.png')),
        buttonText: '',
      );
      _world.add(leftButton);
        break;
      case 'RightNavigation':
       final rightButton = GameButton(
        onClick: () => moveCamera(1, cameraViewportWidth,gameLevelSelection.size.x),
        size: Vector2(button.width/1.1, button.height/1.1),
        position: Vector2(button.x, button.y),
        normalSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowRight-Bold/Default@2x-1.png')),
        onTapSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/ArrowRight-Bold/Hover@2x-1.png')),
        buttonText: '',
      );
      _world.add(rightButton);
        break;
    }
  }

}




}



  
}
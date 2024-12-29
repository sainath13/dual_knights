import 'package:dual_knights/dual_knights.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'dart:developer' as developer;

import '../components/game_button.dart';

class GameMainMenu extends PositionComponent with HasGameRef<DualKnights>,TapCallbacks {
  static const id = 'GameMainMenu';
  late TiledComponent gameMainMenu;
  late final World _world;
  late final CameraComponent _camera;

  @override
  Future<void> onLoad() async {
    await loadGameMainMenu();
    super.onLoad();
  }

  @override
  void onRemove() {
    _world.removeFromParent();
    _camera.removeFromParent();
    super.onRemove();
  }

  Future<void> loadGameMainMenu() async {
    gameMainMenu = await TiledComponent.load('Game-Welcome-Page.tmx', Vector2(64, 64));
    add(gameMainMenu);
    _world = World(children: [gameMainMenu]);
    await add(_world);
    _camera = CameraComponent.withFixedResolution(
      width: 16 * 64,
      height: 12 * 64,
      world: _world,
    );
    _camera.viewfinder.anchor = Anchor.topLeft;
    await add(_camera);

    final buttonsLayer = gameMainMenu.tileMap.getLayer<ObjectGroup>('Buttons');
    if (buttonsLayer != null) {
      for (final button in buttonsLayer.objects) {
        GameButton gameButton;

        switch (button.class_) {
          case 'PlayButton':
            gameButton = GameButton(
              baseImagePath: 'UI/Buttons/Button_Blue_3Slides.png',
              tapImagePath: 'UI/Buttons/Button_Blue_3Slides_Pressed.png',
              buttonText: 'Play',
              buttonSize: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              onTap: () {
                developer.log('Play button pressed!');
                // Add your play button logic here
              },
            );
            break;

          case 'SettingsButton':
            gameButton = GameButton(
              baseImagePath: 'buttons/settings_button.png',
              tapImagePath: 'buttons/settings_button_pressed.png',
              buttonText: 'Settings',
              buttonSize: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              onTap: () {
                developer.log('Settings button pressed!');
                // Add your settings button logic here
              },
            );
            break;

          case 'MuteButton':
            gameButton = GameButton(
              baseImagePath: 'buttons/mute_button.png',
              tapImagePath: 'buttons/mute_button_pressed.png',
              buttonText: 'Mute',
              buttonSize: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              onTap: () {
                developer.log('Mute button pressed!');
                // Add your mute button logic here
              },
            );
            break;

          default:
            continue;
        }

        _world.add(gameButton);
        developer.log('Added ${button.class_} at position: ${button.x}, ${button.y}');
      }
    } else {
      developer.log('Level: Sadly buttonsLayer is null');
    }
  }
}
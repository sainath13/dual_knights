import 'dart:ui';

import 'package:dual_knights/components/game_sound_button.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import '../components/game_button.dart';

class GameMainMenu extends PositionComponent with HasGameRef<DualKnights> {
  static const id = 'GameMainMenu';
  late TiledComponent gameMainMenu;
  late final World _world;
  late final CameraComponent _camera;

  final VoidCallback? onPlayPressed;

 final ValueListenable<bool> musicValueListenable;
  final ValueListenable<bool> sfxValueListenable;

  final ValueChanged<bool>? onMusicValueChanged;
  final ValueChanged<bool>? onSfxValueChanged;

  GameMainMenu({
    this.onPlayPressed,
    required this.musicValueListenable,
    required this.sfxValueListenable,
    this.onMusicValueChanged,
    this.onSfxValueChanged,});

  @override
  Future<void> onLoad() async {
    await loadGameMainMenu();
    super.onLoad();
  }

  @override
  void onRemove() {
    super.onRemove();
    _world.removeFromParent();
    _camera.removeFromParent();
    for (final child in _world.children) {
      child.removeFromParent();
    }
  }

  Future<void> loadGameMainMenu() async {
    gameMainMenu = await TiledComponent.load('Game-UI-With-Settings.tmx', Vector2(64, 64));
    // add(gameMainMenu);
    _world = World(children: [gameMainMenu]);
    await add(_world);
    _camera = CameraComponent.withFixedResolution(
      width: 31*2 * 64,
      height: 22 * 64,
      world: _world,
    );
    // _camera.viewfinder.anchor = Anchor.topLeft;
    _camera.moveTo(Vector2(gameMainMenu.size.x * 0.5, _camera.viewport.virtualSize.y*0.5));
    await add(_camera);


    final buttonsLayer = gameMainMenu.tileMap.getLayer<ObjectGroup>('ButtonsForSpawn');
    if (buttonsLayer != null) {
      for (final button in buttonsLayer.objects) {



        switch (button.class_) {
          case 'PlayButton':
          Sprite normalSprite = Sprite(await game.images.load('UI/Buttons/Button_Blue_9Slides.png'));
            Sprite onTapSprite = Sprite(await game.images.load('UI/Buttons/Button_Blue_9Slides_Pressed.png'));
            GameButton gameButton = GameButton(
              normalSprite: normalSprite,
              onTapSprite: onTapSprite,
              onClick: onPlayPressed!,
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              buttonText: 'Play',
            );
            _world.add(gameButton);
            break;

          case 'SoundButton':
            Sprite spriteOn = Sprite(await game.images.load('UI/Icons/Regular_03.png'));
            Sprite spriteOff = Sprite(await game.images.load('UI/Icons/Pressed_03.png'));
            GameSoundButton musicSoundButton = GameSoundButton(spriteOn: spriteOn, spriteOff: spriteOff, onToggle: onMusicValueChanged, isSoundOn: musicValueListenable.value, size: Vector2(button.width, button.height), position: Vector2(button.x, button.y),buttonText: "Music");
            _world.add(musicSoundButton);
            break;

          case 'SFXButton':
            Sprite spriteOn = Sprite(await game.images.load('UI/Icons/Regular_03.png'));
            Sprite spriteOff = Sprite(await game.images.load('UI/Icons/Pressed_03.png'));
            GameSoundButton sfxSoundButton = GameSoundButton(spriteOn: spriteOn, spriteOff: spriteOff, onToggle: onSfxValueChanged, isSoundOn: sfxValueListenable.value, size: Vector2(button.width, button.height), position: Vector2(button.x, button.y),buttonText: "SFX");
            _world.add(sfxSoundButton);
            break;

          // case 'AboutUsButton':
          //   gameButton = GameButton(
          //     baseImagePath: 'buttons/mute_button.png',
          //     tapImagePath: 'buttons/mute_button_pressed.png',
          //     buttonText: 'Mute',
          //     buttonSize: Vector2(button.width, button.height),
          //     position: Vector2(button.x, button.y),
          //     onTap: () {
          //       developer.log('Mute button pressed!');
          //       // Add your mute button logic here
          //     },
          //   );
          //   break;

          default:
            continue;
        }

        
        developer.log('Added ${button.class_} at position: ${button.x}, ${button.y}');
      }
    } else {
      developer.log('Level: Sadly buttonsLayer is null');
    }
  }
}
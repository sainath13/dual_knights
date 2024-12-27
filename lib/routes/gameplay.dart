import 'dart:async';
import 'dart:ui';



import 'package:dual_knights/components/anti_player.dart';

import 'package:dual_knights/components/level.dart';

import 'package:dual_knights/components/player.dart';

import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/hud.dart';

import 'package:dual_knights/input.dart';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';

// import 'package:flame_audio/flame_audio.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';


class Gameplay extends Component with HasGameReference<DualKnights> {
  final Player player;
  final AntiPlayer antiPlayer;

  Gameplay(
    this.currentLevel, {
    super.key,
    required this.onPausePressed,
    required this.onLevelCompleted,
    required this.onGameOver,
    required this.player,
    required this.antiPlayer
  });

  static const id = 'Gameplay';
  
  static const _bgmFadeRate = 1;
  static const _bgmMinVol = 0;
  static const _bgmMaxVol = 0.6;
  

  final int currentLevel;
  final VoidCallback onPausePressed;
  final ValueChanged<int> onLevelCompleted;
  final VoidCallback onGameOver;

  late final input = Input(
    keyCallbacks: {
      LogicalKeyboardKey.keyP: onPausePressed,
      LogicalKeyboardKey.keyC: () => onLevelCompleted.call(3),
      LogicalKeyboardKey.keyO: onGameOver,
    },
  );

  late final _cameraShake = MoveEffect.by(
    Vector2(0, 3),
    InfiniteEffectController(ZigzagEffectController(period: 0.2)),
  );

  late final World _world;
  late final CameraComponent _camera;
  late final RectangleComponent _fader;
  late final Hud _hud;



  bool _levelCompleted = false;
  bool _gameOver = false;

  AudioPlayer? _bgmPlayer;

  @override
  Future<void> onLoad() async {
    if (game.musicValueNotifier.value) {
      _bgmPlayer = await FlameAudio.loopLongAudio(DualKnights.bgm, volume: 0);
    }

    Level level = Level(currentLevelIndex: currentLevel.toString().padLeft(2, '0'), player: player, antiPlayer: antiPlayer);
    

    await _setupWorldAndCamera(level);
    

    _fader = RectangleComponent(
      size: _camera.viewport.virtualSize,
      paint: Paint()..color = game.backgroundColor(),
      children: [OpacityEffect.fadeOut(LinearEffectController(1.5))],
      priority: 1,
    );

    _hud = Hud(
      playerSprite: Sprite(game.images.fromCache('UI/Buttons/Button_Blue.png')),
      snowmanSprite: Sprite(game.images.fromCache('UI/Buttons/Button_Blue.png')),
      input: DualKnights.isMobile ? input : null,
      onPausePressed:onPausePressed,
    );

    await _camera.viewport.addAll([_fader,_hud]);
    // await _camera.viewfinder.add(_cameraShake);
    // _cameraShake.pause();
  }

  @override
  void update(double dt) {
    if (_bgmPlayer != null) {
      if (_levelCompleted) {
        if (_bgmPlayer!.volume > _bgmMinVol) {
          _bgmPlayer!.setVolume(
            lerpDouble(_bgmPlayer!.volume, _bgmMinVol, _bgmFadeRate * dt)!,
          );
        }
      } else {
        if (_bgmPlayer!.volume < _bgmMaxVol) {
          _bgmPlayer!.setVolume(
            lerpDouble(_bgmPlayer!.volume, _bgmMaxVol, _bgmFadeRate * dt)!,
          );
        }
      }
    }
  }

  @override
  void onRemove() {
    _bgmPlayer?.dispose();
    super.onRemove();
  }

  Future<void> _setupWorldAndCamera(Level level) async {
    _world = World(children: [level,input]);
    await add(_world);

    _camera = CameraComponent.withFixedResolution(
      width: 15*64, height: 15*64,
      world: _world,
    );
    _camera.viewfinder.anchor = Anchor.topLeft;
    await add(_camera);
    
  }

  
}

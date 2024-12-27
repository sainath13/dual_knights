import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/anti_player_checkpoint.dart';
import 'package:dual_knights/components/barrel.dart';
import 'package:dual_knights/components/collision_block.dart';
import 'package:dual_knights/components/moving_barrel.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/components/player_checkpoint.dart';
import 'package:dual_knights/components/tree.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/hud.dart';
import 'package:dual_knights/input.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
// import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
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
  static const _timeScaleRate = 1;
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
  // late final Hud _hud;
  // late final SpriteSheet _spriteSheet;



  bool _levelCompleted = false;
  bool _gameOver = false;

  // AudioPlayer? _bgmPlayer;

  @override
  Future<void> onLoad() async {
    if (game.musicValueNotifier.value) {
      // _bgmPlayer = await FlameAudio.loopLongAudio(DualKnights.bgm, volume: 0);
    }

    final level = await TiledComponent.load(
      'Level-0$currentLevel.tmx',
      Vector2.all(64),
    );

    List<CollisionBlock> collisionBlocks = [];
    final checkpointLayer = level.tileMap.getLayer<ObjectGroup>('Checkpoints');
    if(checkpointLayer != null){
      for(final checkpoint in checkpointLayer.objects){
        switch (checkpoint.class_) {
          case 'PlayerCheckpoint' :
            final playerCheckpoint = PlayerCheckpoint();//..debugMode = true;
            playerCheckpoint.position = Vector2(checkpoint.x, checkpoint.y);
            add(playerCheckpoint);
          case 'AntiPlayerCheckpoint' :
            final antiPlayerCheckpoint = AntiPlayerCheckpoint();//..debugMode = true;
            antiPlayerCheckpoint.position = Vector2(checkpoint.x, checkpoint.y);
            add(antiPlayerCheckpoint);
          default:  
        }
      }
    }
    else{
      log('Level : Sadly spawnPointslayer is null');
    }
    
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if(spawnPointsLayer != null){
      for(final spawnPoint in spawnPointsLayer.objects){
        switch (spawnPoint.class_) {
          
          case 'AntiPlayer' :
            antiPlayer.position = Vector2(spawnPoint.x + 32, spawnPoint.y + 32);
            antiPlayer.anchor = Anchor.center;
            add(antiPlayer);
            break;
          case 'Player' :
            player.position = Vector2(spawnPoint.x + 32, spawnPoint.y + 32);
            player.anchor = Anchor.center;
            add(player);
            break;  
          case 'Barrel' :
            final barrel = Barrel(position: Vector2(spawnPoint.x-32, spawnPoint.y-32));//..debugMode = true;
            add(barrel);
            break; 
          case 'MovingBarrel' :
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final leftOffset = spawnPoint.properties.getValue('leftOffset');
            final rightOffset = spawnPoint.properties.getValue('rightOffset');
            final upOffset = spawnPoint.properties.getValue('upOffset');
            final downOffset = spawnPoint.properties.getValue('downOffset');
            final movingBarrel = MovingBarrel(
              isVertical: isVertical, 
              leftOffset: leftOffset, 
              rightOffset: rightOffset, 
              upOffset: upOffset, 
              downOffset: downOffset ,
              position: Vector2(spawnPoint.x-32, spawnPoint.y-32));//..debugMode = true;
            add(movingBarrel);
            break;   
          case 'Tree' :
            final tree = Tree(position: Vector2(spawnPoint.x + 32, spawnPoint.y-16));//..debugMode = true;
            tree.anchor = Anchor.center;
            add(tree);     
            final block = CollisionBlock(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );//..debugMode = true;
            add(block);
            collisionBlocks.add(block);
            break;
          default:  
        }
      }
    }
    else{
      log('Level : Sadly spawnPointslayer is null');
    }

    
    final collisionBlocksLayer = level.tileMap.getLayer<ObjectGroup>('Collisionblocks');
    if(collisionBlocksLayer != null){
      // log("Collision blocks layer is not null");
      for(final collisionBlock in collisionBlocksLayer.objects){
        switch(collisionBlock.class_){
          case 'Block' :
            final block = CollisionBlock(
              position: Vector2(collisionBlock.x, collisionBlock.y),
              size: Vector2(collisionBlock.width, collisionBlock.height),
            );//..debugMode = true;
            add(block);
            collisionBlocks.add(block);
            //create a new block.
            break;
          default:   
        }
      }
    }
    else {
      log("Collision blocks layer is sadly null");
    }

    player.setCollisionBlocks(collisionBlocks);
    antiPlayer.setCollisionBlocks(collisionBlocks);
    
    

    await _setupWorldAndCamera(level);
    

    _fader = RectangleComponent(
      size: _camera.viewport.virtualSize,
      paint: Paint()..color = game.backgroundColor(),
      children: [OpacityEffect.fadeOut(LinearEffectController(1.5))],
      priority: 1,
    );

    // _hud = Hud(
    //   playerSprite: _spriteSheet.getSprite(5, 10),
    //   snowmanSprite: _spriteSheet.getSprite(5, 9),
    //   input: DualKnights.isMobile ? input : null,
    //   onPausePressed: DualKnights.isMobile ? onPausePressed : null,
    // );

    await _camera.viewport.addAll([_fader]);
    // await _camera.viewfinder.add(_cameraShake);
    // _cameraShake.pause();
  }

  // @override
  // void update(double dt) {
  //   if (_bgmPlayer != null) {
  //     if (_levelCompleted) {
  //       if (_bgmPlayer!.volume > _bgmMinVol) {
  //         _bgmPlayer!.setVolume(
  //           lerpDouble(_bgmPlayer!.volume, _bgmMinVol, _bgmFadeRate * dt)!,
  //         );
  //       }
  //     } else {
  //       if (_bgmPlayer!.volume < _bgmMaxVol) {
  //         _bgmPlayer!.setVolume(
  //           lerpDouble(_bgmPlayer!.volume, _bgmMaxVol, _bgmFadeRate * dt)!,
  //         );
  //       }
  //     }
  //   }
  // }

  @override
  void onRemove() {
    // _bgmPlayer?.dispose();
    super.onRemove();
  }

  Future<void> _setupWorldAndCamera(TiledComponent map) async {
    _world = World(children: [map]);
    

    _camera = CameraComponent.withFixedResolution(
      width: 15*64, height: 15*64,
      world: _world,
    );
    _camera.viewfinder.anchor = Anchor.topLeft;
    await add(_camera);
    await add(_world);
  }

  
}

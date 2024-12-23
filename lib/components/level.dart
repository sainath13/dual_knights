import 'dart:async';
import 'dart:developer';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/barrel.dart';
import 'package:dual_knights/components/collision_block.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/components/player_checkpoint.dart';
import 'package:dual_knights/components/anti_player_checkpoint.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasCollisionDetection{
  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async{
    level = await TiledComponent.load('Level-01.tmx', Vector2(64, 64));
    level.debugMode = true;
    add(level);

    final checkpointLayer = level.tileMap.getLayer<ObjectGroup>('Checkpoints');
    if(checkpointLayer != null){
      // log('Level : spawnPointslayer is not null');
      for(final checkpoint in checkpointLayer.objects){
        switch (checkpoint.class_) {
          case 'PlayerCheckpoint' :
            final playerCheckpoint = PlayerCheckpoint()..debugMode = true;
            playerCheckpoint.position = Vector2(checkpoint.x, checkpoint.y);
            add(playerCheckpoint);
          case 'AntiPlayerCheckpoint' :
            final antiPlayerCheckpoint = AntiPlayerCheckpoint()..debugMode = true;
            antiPlayerCheckpoint.position = Vector2(checkpoint.x, checkpoint.y);
            add(antiPlayerCheckpoint);
          default:  
        }
      }
    }
    else{
      log('Level : Sadly spawnPointslayer is null');
    }

    final player = Player()..debugMode = true;
    final antiPlayer = AntiPlayer()..debugMode = true;
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if(spawnPointsLayer != null){
      // log('Level : spawnPointslayer is not null');
      for(final spawnPoint in spawnPointsLayer.objects){
        switch (spawnPoint.class_) {
          case 'Player' :
            // final player = Player();
            player.position = Vector2(spawnPoint.x + 32, spawnPoint.y + 32);
            player.anchor = Anchor.center;
            // player.scale.x = 2/3;
            // player.scale.y = 2/3;
            add(player);
            break;
          case 'AntiPlayer' :
            antiPlayer.position = Vector2(spawnPoint.x+32, spawnPoint.y+32);
            antiPlayer.anchor = Anchor.center;
            // antiPlayer.scale.x = 0.666667;
            // antiPlayer.scale.y = 0.666667;
            add(antiPlayer);
            break;
          case 'Barrel' :
            final barrel = Barrel(position: Vector2(spawnPoint.x+32, spawnPoint.y+32))..debugMode = true;
            antiPlayer.anchor = Anchor.center;
            // final barrel = Barrel(position: Vector2(spawnPoint.x - 10, spawnPoint.y-10));
            // barrel.scale.x = 0.666667;
            // barrel.scale.y = 0.666667;
            add(barrel);
            break;    
          default:  
        }
      }
    }
    else{
      log('Level : Sadly spawnPointslayer is null');
    }

    List<CollisionBlock> collisionBlocks = [];
    final collisionBlocksLayer = level.tileMap.getLayer<ObjectGroup>('Collisionblocks');
    if(collisionBlocksLayer != null){
      // log("Collision blocks layer is not null");
      for(final collisionBlock in collisionBlocksLayer.objects){
        switch(collisionBlock.class_){
          case 'Block' :
            final block = CollisionBlock(
              position: Vector2(collisionBlock.x, collisionBlock.y),
              size: Vector2(collisionBlock.width, collisionBlock.height),
            )..debugMode = true;
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
    
    return super.onLoad();
  }

}
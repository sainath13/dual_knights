import 'dart:async';
import 'dart:developer';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/barrel.dart';
import 'package:dual_knights/components/collision_block.dart';
import 'package:dual_knights/components/experiments/archer.dart';
import 'package:dual_knights/components/moving_barrel.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/components/player_checkpoint.dart';
import 'package:dual_knights/components/anti_player_checkpoint.dart';
import 'package:dual_knights/components/tree.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';


class Level extends PositionComponent with HasGameRef<DualKnights>, HasCollisionDetection{
  final String currentLevelIndex;
  final Player player;
  final AntiPlayer antiPlayer;
  Level({required this.currentLevelIndex, required this.player, required this.antiPlayer});
  late TiledComponent level;
  
  @override
  FutureOr<void> onLoad() async{
    level = await TiledComponent.load('Level-$currentLevelIndex.tmx', Vector2(64, 64));
    // level.debugMode = true;
    add(level);
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
    
    return super.onLoad();
  }

}
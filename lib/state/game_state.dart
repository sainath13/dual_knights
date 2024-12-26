// lib/state/game_state.dart



import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';

class GameState {
  static final GameState _instance = GameState._internal();
  
  factory GameState() {
    return _instance;
  }
  
  GameState._internal();
  
  Player? player;
  AntiPlayer? antiPlayer;
  
  void initializePlayers() {
    player = Player();
    antiPlayer = AntiPlayer();
  }
  
  void resetPlayers() {
    player = null;
    antiPlayer = null;
  }
}
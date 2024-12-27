// ignore_for_file: implementation_imports, unnecessary_import

import 'dart:async';
import 'dart:ui';

import 'package:dual_knights/components/anti_player.dart';
import 'package:dual_knights/components/player.dart';
import 'package:dual_knights/routes/gameplay.dart';
import 'package:dual_knights/routes/level_complete.dart';
import 'package:dual_knights/routes/level_selection.dart';
import 'package:dual_knights/routes/main_menu.dart';
import 'package:dual_knights/routes/pause_menu.dart';
import 'package:dual_knights/routes/retry_menu.dart';
import 'package:dual_knights/routes/settings.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

import 'package:flutter/widgets.dart' hide Route,OverlayRoute;

class DualKnights extends FlameGame with HasKeyboardHandlerComponents{

  static const isMobile = bool.fromEnvironment('MOBILE_BUILD');
  final musicValueNotifier = ValueNotifier(true);
  final sfxValueNotifier = ValueNotifier(true);

  static const bgm = '8BitDNALoop.wav';


  late final _routes = <String, Route>{
    MainMenu.id: OverlayRoute(
      (context, game) =>  MainMenu(
        onPlayPressed: () => _routeById(LevelSelection.id),
        onSettingsPressed: () => _routeById(Settings.id),
      ),
    ),
    LevelSelection.id: OverlayRoute(
      (context, game) => LevelSelection(
        onLevelSelected: _startLevel,
        onBackPressed: _popRoute,
      ),
    ),
     Settings.id: OverlayRoute(
      (context, game) => Settings(
        musicValueListenable: musicValueNotifier,
        sfxValueListenable: sfxValueNotifier,
        onMusicValueChanged: (value) => musicValueNotifier.value = value,
        onSfxValueChanged: (value) => sfxValueNotifier.value = value,
        onBackPressed: _popRoute,
      ),
    ),
    PauseMenu.id: OverlayRoute(
      (context, game) => PauseMenu(
        onResumePressed: _resumeGame,
        onRestartPressed: _restartLevel,
        onExitPressed: _exitToMainMenu,
        
      ),
    ),
    RetryMenu.id: OverlayRoute(
      (context, game) => RetryMenu(
        onRetryPressed: _restartLevel,
        onExitPressed: _exitToMainMenu,
      ),
    )
    
  };


  late final _routeFactories = <String, Route Function(String)>{
    LevelComplete.id: (argument) => OverlayRoute(
          (context, game) => LevelComplete(
            nStars: int.parse(argument),
            onNextPressed: _startNextLevel,
            onRetryPressed: _restartLevel,
            onExitPressed: _exitToMainMenu,
          ),
        ),
  };

  late final _router = RouterComponent(
    initialRoute: MainMenu.id,
    routes: _routes,
    routeFactories: _routeFactories,
  );


  late final CameraComponent cam;
  
  @override
  Color backgroundColor()  => const Color(0xFF47ABA9);
  final player = Player();//..debugMode = true;
  final antiPlayer = AntiPlayer();
    

  @override
  FutureOr<void> onLoad() async{
    await FlameAudio.audioCache.loadAll([bgm]);
    await images.loadAllImages();
    await add(_router);
    
    
    return super.onLoad();
  }


  void _routeById(String id) {
    _router.pushNamed(id);
  }

  void _popRoute() {
    _router.pop();
  }

  void _startLevel(int levelIndex) {
    _router.pop();
    _router.pushReplacement(
      Route(
        () => Gameplay(
          levelIndex,
          onPausePressed: _pauseGame,
          onLevelCompleted: _showLevelCompleteMenu,
          onGameOver: _showRetryMenu,
          key: ComponentKey.named(Gameplay.id),
          player:player,
          antiPlayer: antiPlayer
        ),
      ),
      name: Gameplay.id,
    );
  }

  void _startNextLevel() {
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);

    if (gameplay != null) {
      _startLevel(gameplay.currentLevel + 1);
    }
  }

  void _restartLevel() {
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);

    if (gameplay != null) {
      _startLevel(gameplay.currentLevel);
      resumeEngine();
    }
  }
  void _pauseGame() {
    _router.pushNamed(PauseMenu.id);
    pauseEngine();
  }
  void _resumeGame() {
    _router.pop();
    resumeEngine();
  }

  void _exitToMainMenu() {
    _resumeGame();
    _router.pushReplacementNamed(MainMenu.id);
  }

   void _showLevelCompleteMenu(int nStars) {
    _router.pushNamed('${LevelComplete.id}/$nStars');
  }

   void _showRetryMenu() {
    _router.pushNamed(RetryMenu.id);
  }


}
// ignore_for_file: implementation_imports, unnecessary_import

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dual_knights/components/cloud_loading.dart';
import 'package:dual_knights/components/cloud_loading_inverse.dart';
import 'package:dual_knights/model/character_dialogue_model.dart';
import 'package:dual_knights/model/user_model.dart';
import 'package:dual_knights/model/user_settings_model.dart';
import 'package:dual_knights/repository/game_repository.dart';
import 'package:dual_knights/routes/game_level_selection.dart';
import 'package:dual_knights/routes/game_main_menu.dart';
import 'package:dual_knights/routes/game_level_complete.dart';
import 'package:dual_knights/routes/game_tutorial.dart';
import 'package:dual_knights/routes/gameplay.dart';
import 'package:dual_knights/routes/level_complete.dart';
import 'package:dual_knights/routes/level_selection.dart';
import 'package:dual_knights/routes/main_menu.dart';
import 'package:dual_knights/routes/pause_menu.dart';
import 'package:dual_knights/routes/retry_menu.dart';
import 'package:dual_knights/routes/settings.dart';
import 'package:dual_knights/widgets/authentication/login_page.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/widgets.dart' hide Route,OverlayRoute;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DualKnights extends FlameGame with HasKeyboardHandlerComponents, TapDetector{

  final GameRepository gameRepository;

  DualKnights({required this.gameRepository});

  static const isMobile = bool.fromEnvironment('MOBILE_BUILD');
  final musicValueNotifier = ValueNotifier(true);
  final sfxValueNotifier = ValueNotifier(true);
  final analogueJoystick = ValueNotifier(false); //If true hud will have analogue joystick else arrow keys
  ValueNotifier<int> stepCountNotifier = ValueNotifier(0);
  Map<int, int> stepCountForStars = {};
  bool isDialogueActive = false;
  bool dialogueApiCallActive = false;
  final int lastLevel = 45;
  final List<Map<String, dynamic>> dialogueQueue = [];

  var lastGamePlayState = null;

  late RectangleComponent background;


  bool _levelCompleteMenuShown = false; // Add a flag

  static const bgm = 'bf_music_for_dual_knights.wav';
  static const explosion = 'explosion.wav';
  static const blocked = 'impactWood_medium_000.wav';
  static const move = 'footstep_concrete_003.wav';
  static const crashEachother = 'crash.wav';
  static const completeLevel = 'level-complete.wav';
  static const beep = 'beep.ogg';
  var _settingsListener;
  final storage = FlutterSecureStorage();

  final ValueNotifier<Map<String, String>> dialogueNotifier = ValueNotifier({
    'characterName': '',
    'dialogue': '',
    'priority': '0'
  });


  late final _routes = <String, Route>{
    LoginPage.id: OverlayRoute(
      (context, game) =>  LoginPage(
        onLoginSuccess:  _onLoginSuccess,
      )
      ),
    MainMenu.id: OverlayRoute(
      (context, game) =>  MainMenu(
        onPlayPressed: () => _routeById(LevelSelection.id),
        onSettingsPressed: () => _routeById(Settings.id),
      ),
    ),
    LevelSelection.id: OverlayRoute(
      (context, game) => LevelSelection(
        onLevelSelected: _startLevel,
        onBackPressed:  _popRoute,
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
        musicValueListenable: musicValueNotifier,
        sfxValueListenable: sfxValueNotifier,
        onMusicValueChanged: (value) => musicValueNotifier.value = value,
        onSfxValueChanged: (value) => sfxValueNotifier.value = value,
        controlTypeListenable: analogueJoystick,
        onControlTypeChanged: (value) => analogueJoystick.value = value,
        onLevelSelection: _navigateToGameLevelSelectionFromPause

      ),
    ),
    RetryMenu.id: OverlayRoute(
      (context, game) => RetryMenu(
        onRetryPressed: _restartLevel,
        onExitPressed: _exitToMainMenu,
      ),
    ),
    GameMainMenu.id: Route(
      () => GameMainMenu(
        onPlayPressed: () => _navigateToGameLevelSelection(),
        musicValueListenable: musicValueNotifier,
        sfxValueListenable: sfxValueNotifier,
        onMusicValueChanged: (value) => musicValueNotifier.value = value,
        onSfxValueChanged: (value) => sfxValueNotifier.value = value,
        onLoginClicked: () => _routeById(LoginPage.id),
        isUserLoggedIn: isUserLoggedIn(),
        onLogoutClicked: logout,
        loadUserSettings: loadUserSettings(),
        onTutorialPressed: _navigateToTutorialScreen,
      ),
    ),
    GameLevelSelection.id: Route(
      () => GameLevelSelection(
        onLevelSelected: _startLevel,
        onBackPressed:  _popRoute,
        gameRepository: gameRepository,
      ),
    ),
  };


  late final _routeFactories = <String, Route Function(String)>{
    LevelComplete.id: (argument) => OverlayRoute(
          (context, game) => LevelComplete(
            nStars: int.parse(argument),
            onNextPressed: _startNextLevel,
            onRetryPressed: _restartLevel,
            onExitPressed: _exitToMainMenu,
          ),
        )
  };

  late final _router = RouterComponent(
    initialRoute: GameMainMenu.id,
    routes: _routes,
    routeFactories: _routeFactories,
  );



  
  @override
  Color backgroundColor()  => const Color.fromRGBO(71, 171, 169, 1);

  @override
  FutureOr<void> onLoad() async{
    await loadUserSettings();
    syncUserSettings();
    await FlameAudio.audioCache.loadAll([bgm,explosion,blocked,move,beep,crashEachother,completeLevel]);
    await images.loadAllImages();
    await add(_router);

    background = RectangleComponent(
      size: canvasSize, // Full-screen background
      paint: Paint()..color = Color(0xFF47ABA9), // Initial color
      priority: -1, // Render it behind everything
    );

    add(background);


  return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    processDialogueQueue(); // Process the queue on each frame
  }

   @override
  void onRemove() {
    musicValueNotifier.removeListener(_settingsListener);
    sfxValueNotifier.removeListener(_settingsListener);
    analogueJoystick.removeListener(_settingsListener);
    dialogueNotifier.dispose();
    super.onRemove();
  }

  void syncUserSettings() {
    _settingsListener = () async {
        await updateUserSettings(musicValueNotifier.value, sfxValueNotifier.value, analogueJoystick.value);
    };
        musicValueNotifier.addListener(_settingsListener);
        sfxValueNotifier.addListener(_settingsListener);
        analogueJoystick.addListener(_settingsListener);
  }

  Future<void> loadUserSettings() async {
    final jwtToken = await getJwtToken();
    UserSettings userSettings = await gameRepository.getUserSettings(jwtToken);
    print('User settings: ${userSettings}');
    musicValueNotifier.value = userSettings.music;
    sfxValueNotifier.value = userSettings.sfx;
    analogueJoystick.value = userSettings.joystick;
  }
  

  void updateBackgroundColor(Color color) {
    background.paint.color = color;
  }

  void updateDefaultBackgroundColor(){
    background.paint.color = Color(0xFF47ABA9);
  }

   void _routeReplaceById(String id) {
    _router.pushReplacementNamed(id);
  }


  void _routeById(String id) {
    _router.pushNamed(id);
}

  void _popRoute() {
    _router.pop();
  }

  void _navigateToGameLevelSelectionFromLevelComplete() {
     
     
     _routeToGameMainMenu();
     _navigateToGameLevelSelection();
  }

   void _navigateToGameLevelSelectionFromPause() {
     resumeEngine();
     _router.pop();
     _routeToGameMainMenu();
     _navigateToGameLevelSelection();
  }

  void _navigateToGameLevelSelection() {
     _router.pushRoute(
      Route(
      () => GameLevelSelection(
        onLevelSelected: _startLevel,
        onBackPressed:  _popRoute,
        gameRepository: gameRepository,
      ),
    )
    );
  }

  void _navigateToTutorialScreen() {
     _router.pushRoute(
      Route(
      () => GameTutorial(
        onBackPressed:  _popRoute,
      ),
    )
    );
  }

  void _startLevel(int levelIndex) {
    _router.pop();    
    _router.pushReplacement(
      Route(
        () => Gameplay(
          levelIndex,
          onPausePressed: _pauseGame,
          onLevelCompleted: _showLevelCompleteMenu,
          onGameOver: _restartWithoutPopup,
          onRestartLevel:  _restartWithoutPopup,
          key: ComponentKey.named(Gameplay.id),
          gameRepository: gameRepository
        ),
      ),
      name: Gameplay.id,
    );
  }

  void _startNextLevel() {
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);

    if(gameplay != null && gameplay.currentLevel == lastLevel){
      openLink('https://luxuriant-title-564.notion.site/A-Message-from-the-Realm-of-Dualaria-17a8a752df9380cfa001f4a20e441886');
      return;
    }
    if (gameplay != null) {
      _startLevel(gameplay.currentLevel + 1);
    }else if(lastGamePlayState!=null){
       if(lastGamePlayState != null && lastGamePlayState.currentLevel == lastLevel){
        openLink('https://luxuriant-title-564.notion.site/A-Message-from-the-Realm-of-Dualaria-17a8a752df9380cfa001f4a20e441886');
        return;
      }
      _router.pushOverlay(MainMenu.id);
      _startLevel(lastGamePlayState.currentLevel + 1);
    }
  }

  void _restartLevel() {
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);

    if (gameplay != null) {
      _startLevel(gameplay.currentLevel);
      resumeEngine();
    }
    else if(lastGamePlayState!=null){
      _router.pushOverlay(MainMenu.id);
      _startLevel(lastGamePlayState.currentLevel);
      resumeEngine();
    }
  }

  void _restartWithoutPopup(){
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);

    if (gameplay != null) {
      _router.pushOverlay(MainMenu.id);
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
    _routeToGameMainMenu();
  }

  void _routeToGameMainMenu(){
     _router.pushReplacement(Route(
      () => GameMainMenu(
        onPlayPressed: () => _navigateToGameLevelSelection(),
        musicValueListenable: musicValueNotifier,
        sfxValueListenable: sfxValueNotifier,
        onMusicValueChanged: (value) => musicValueNotifier.value = value,
        onSfxValueChanged: (value) => sfxValueNotifier.value = value,
        onLoginClicked: () => _routeById(LoginPage.id),
        isUserLoggedIn: isUserLoggedIn(),
        onLogoutClicked: logout,
        loadUserSettings: loadUserSettings(),
        onTutorialPressed: _navigateToTutorialScreen
      ),
    ));
  }

 void _showLevelCompleteMenu(int nSteps) {
  // Prevent multiple executions
  if (_levelCompleteMenuShown) return;

  _levelCompleteMenuShown = true; // Set the flag to true

  nSteps = stepCountNotifier.value;
  int nStars = 0;
  if (nSteps <= stepCountForStars[3]!) {
    nStars = 3;
  } else if (nSteps <= stepCountForStars[2]!) {
    nStars = 2;
  } else if (nSteps <= stepCountForStars[1]!) {
    nStars = 1;
  }

  final gameplay = findByKeyName<Gameplay>(Gameplay.id);

  final cloudLoading = CloudLoadingInverse(
    onRemoveCallback: () {
      // Logic to execute after cloud animation is removed
      int completedLevel = gameplay?.currentLevel ?? lastGamePlayState?.currentLevel ?? 0;
      saveLevelCompletion(completedLevel, nStars);

      gameplay?.levelCompleted = true;
      gameplay?.input.movementAllowed = false;

      lastGamePlayState = gameplay;
      _router.pushReplacement(Route(
        () => GameLevelComplete(
              nStars: nStars,
              onNextPressed: _startNextLevel,
              onRetryPressed: _restartLevel,
              onExitPressed: _routeToGameMainMenu,
              onLevelSelectionPressed: _navigateToGameLevelSelectionFromLevelComplete,
        ),
      ));
      _levelCompleteMenuShown = false; 
    },
  );

  camera.viewport.add(cloudLoading);
}



  Future<void> logout() async {
    await storage.delete(key: 'authToken');
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
    _routeToGameMainMenu();
  }

  Future<void> saveLevelCompletion(int completedLevel, int nStars) async {
    final jwtToken = await getJwtToken();
    
    bool status = await gameRepository.markLevelComplete(completedLevel,nStars,jwtToken);
    print('User progress saved: ${status}');
    
  }

   void _showRetryMenu() {
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);
    gameplay?.input.movementAllowed = false;
    _router.pushNamed(RetryMenu.id);

  }

  Future<bool> isUserLoggedIn() async {
  try {
    String? token = await storage.read(key: 'authToken');
    return token != null;
  } catch (e) {
    return false;
  }
}

Future<String?> getJwtToken() async {
  try {

    return await storage.read(key: 'authToken');

  } catch (e) {
      print('Error fetching JWT token: $e');
    return null;
  }
}



  void _onLoginSuccess(GameUser gameUser) async{
    
    var token = await gameRepository.generateJwtToken(gameUser);
    await storage.write(key: 'authToken', value: token);

    _popRoute();
    _routeToGameMainMenu();
  }
  
  Future<void> updateUserSettings(bool musicValue, bool sfxValue, bool joyStickValue) async {
    final jwtToken = await getJwtToken();
    final userSettings = UserSettings(music: musicValue, sfx: sfxValue, joystick: joyStickValue);
    gameRepository.saveUserSettings(userSettings, jwtToken); 
  }


  Future<void> processDialogueQueue() async {
    if (dialogueApiCallActive || dialogueQueue.isEmpty || isDialogueActive) return;

    dialogueApiCallActive = true;

    try {
      // print('Dialogue queue length: ${dialogueQueue.length}');
      // Randomly select a dialogue request from the queue
      final randomIndex = Random().nextInt(dialogueQueue.length);
      final selectedRequest = dialogueQueue.removeAt(randomIndex);
      dialogueQueue.clear();
      // print('Dialogue queue length: ${dialogueQueue.length}');

      final jwtToken = await getJwtToken();
      final characterDialogue = await gameRepository.getCharacterDialogues(
        jwtToken,
        selectedRequest['event'],
        selectedRequest['characterName'],
      );


      // Notify dialogue system with the result
      dialogueNotifier.value = {
        'characterName': characterDialogue.character,
        'dialogue': characterDialogue.taunt,
        'priority': selectedRequest['priority'].toString(),
      };
    } catch (e) {
      print('Error fetching character dialogues: $e');
    } finally {
      dialogueApiCallActive = false;
    }
  }

  void addDialogueRequest(String characterName, String event, int priority) {
    // Add the dialogue request to the queue

    if (!dialogueApiCallActive && !isDialogueActive){
      dialogueQueue.add({
      'characterName': characterName,
      'event': event,
      'priority': priority,
    });
    }
   
  }

  void openLink(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch $url';
  }
}

}
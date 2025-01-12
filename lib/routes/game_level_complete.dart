import 'dart:math';
import 'dart:ui';

import 'package:dual_knights/components/cloud_loading.dart';
import 'package:dual_knights/components/game_button.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/text.dart';

class GameLevelComplete extends PositionComponent with HasGameRef<DualKnights>{
  

  static const id = 'GameLevelComplete';
  late TiledComponent gameLevelComplete;
  late final World _world;
  late final CameraComponent _camera;

  final int nStars;
  final VoidCallback? onNextPressed;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onExitPressed;
  final VoidCallback? onLevelSelectionPressed;


   GameLevelComplete({
    required this.nStars,
    super.key,
    this.onNextPressed,
    this.onRetryPressed,
    this.onExitPressed,
    this.onLevelSelectionPressed
  });


  @override
  Future<void> onLoad() async {
    await loadGameCompletionScreen();
    super.onLoad();
    // Initialize your component here
  }
  @override
  void onRemove() {
    _world.removeFromParent();
    _camera.removeFromParent();
    super.onRemove();
  }


  void addConfettiEffect() {
  final rng = Random();

  final confetti = ParticleSystemComponent(
    position: Vector2(gameLevelComplete.size.x * 0.5, gameLevelComplete.size.y * 0.5),
    particle: Particle.generate(
      count: 70*nStars,
      lifespan: 5,
      generator: (i) {
        final randomColor = Color.fromARGB(
          255,
          rng.nextInt(256),
          rng.nextInt(256),
          rng.nextInt(256),
        );
        
        return AcceleratedParticle(
          position: Vector2(rng.nextDouble() * 300 - 150, rng.nextDouble() * 200 - 100),
          acceleration: Vector2(0, 100), // Gravity effect
          speed: Vector2(rng.nextDouble() * 200 - 100, rng.nextDouble() * -200),
          child: ComposedParticle(
            children: [
              CircleParticle(
                radius: 4,
                paint: Paint()
                  ..color = randomColor.withOpacity(0.8)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5),
              ),
              // Add a fading overlay particle
              CircleParticle(
                radius: 4,
                paint: Paint()
                  ..color = randomColor.withOpacity(0.2)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
              ),
            ],
          ),
        );
      },
    ),
  );

  _world.add(confetti);
}
 

  Future<void> loadGameCompletionScreen() async {
    gameLevelComplete = await TiledComponent.load('Level-Completed-Menu.tmx', Vector2(64, 64));
    // gameLevelComplete = await TiledComponent.load('Level-for-Sarvesh.tmx', Vector2(64, 64));
    // add(gameLevelComplete);
    _world = World(children: [gameLevelComplete]);
    await add(_world);
    _camera = CameraComponent.withFixedResolution(
      width: 16*64, height: 12*64,
      world: _world,
    );

    late final RectangleComponent fader = RectangleComponent(
      size: _camera.viewport.virtualSize,
      paint: Paint()..color = game.backgroundColor(),
      children: [OpacityEffect.fadeOut(LinearEffectController(1.5))],
      priority: 1,
    );

    _camera.viewport.addAll([fader]);

    _camera.moveTo(Vector2(gameLevelComplete.size.x * 0.5, _camera.viewport.virtualSize.y*0.5));
    await add(_camera);
    addConfettiEffect();
    if (game.sfxValueNotifier.value) {
      FlameAudio.play(DualKnights.completeLevel);
    }

    final buttonsLayer = gameLevelComplete.tileMap.getLayer<ObjectGroup>('ButtonsSpawnLayer');
    if (buttonsLayer != null) {
      for (final button in buttonsLayer.objects) {
        switch (button.class_) {
          case 'Restart':
            final restartButton = GameButton(
              onClick: onRetryPressed,
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              normalSprite : Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/Repeat/Default@2x-1.png')),
              onTapSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/Repeat/Hover@2x-1.png')),
              buttonText: '',
            );
            _world.add(restartButton);
            break;
          case 'LevelSelect':
            final levelSelectButton = GameButton(
              onClick:onLevelSelectionPressed,
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              normalSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/Levels/Default@2x-1.png')),
              onTapSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/Levels/Hover@2x-1.png')),
              buttonText: '',
            );
            _world.add(levelSelectButton);
            break;
          case 'Next':  
            final nextButton = GameButton(
              onClick: onNextPressed,
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              normalSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/Play/Default@2x-1.png')),
              onTapSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Buttons/Square/Play/Hover@2x-1.png')),
              buttonText: '',
            );
            _world.add(nextButton);
            break;
          case 'Exit':
            final exitButton = GameButton(
              onClick:onExitPressed,
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
              // normalSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Button/Square/Fill/Default.png')),
              // onTapSprite: Sprite(await game.images.load('Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Button/Square/Fill/Hover.png')),
              buttonText: '',
            );
            _world.add(exitButton);
            break;
          }


    }
  }

  final starSpawnLayer = gameLevelComplete.tileMap.getLayer<ObjectGroup>('StarSpawnLayer');
    if (starSpawnLayer != null) {
      for (final button in starSpawnLayer.objects) {
        switch (button.class_) {
          case 'StarPositionOne':
            final star = SpriteComponent(
              sprite: Sprite(await game.images.load(
                nStars >= 1 ? 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Active.png' 
                : 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Unactive.png'
              )),
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
            );
            _world.add(star);
            break;
          case 'StarPositionTwo':
            final star = SpriteComponent(
              sprite: Sprite(await game.images.load(
                nStars >= 2 ? 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Active.png' 
                : 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Unactive.png'
              )),
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
            );
            _world.add(star);
            break;
          case 'StarPositionThree':
            final star = SpriteComponent(
              sprite: Sprite(await game.images.load(
                nStars >= 3 ? 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Active.png' 
                : 'Prinbles_Asset_Robin (v 1.1) (9_5_2023)/png/Star/Unactive.png'
              )),
              size: Vector2(button.width, button.height),
              position: Vector2(button.x, button.y),
            );
            _world.add(star);
            break;
          case 'Completion':
            final textPaint = TextPaint(
              style: TextStyle(
                fontSize: 48.0,
                color: Color(0xFFFFFFFF), // White color
                fontFamily: 'DualKnights', // Customize the font family
              ),
            );

            final textComponent = TextComponent(
              text: 'Sigils Claimed!',
              textRenderer: textPaint,
              position: Vector2(button.x+64+32+16+8, button.y+20), // Position from the Tiled object
              anchor: Anchor.center, // Align the text to the center
            );
            _world.add(textComponent);
            break;

        }
      }
    }
}}
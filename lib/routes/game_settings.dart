import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class GameSettings extends PositionComponent {

  static const id = 'GameSettings';
  late TiledComponent gameSettings;
  late final World _world;
  late final CameraComponent _camera;


  @override
  Future<void> onLoad() async {
    await loadGameSettings();
    super.onLoad();
    // Initialize your component here
  }
  @override
  void onRemove() {
    _world.removeFromParent();
    _camera.removeFromParent();
    super.onRemove();
  }
 

  Future<void> loadGameSettings() async {
    gameSettings = await TiledComponent.load('Background-test-23.tmx', Vector2(64, 64));

    add(gameSettings);
    _world = World(children: [gameSettings]);
    await add(_world);
    _camera = CameraComponent.withFixedResolution(
      width: 16*64, height: 12*64,
      world: _world,
    );
    _camera.viewfinder.anchor = Anchor.topLeft;
    await add(_camera);
  }
}
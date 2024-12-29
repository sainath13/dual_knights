import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'dart:developer' as developer;

class GameLevelSelection extends Component {

  static const id = 'GameLevelSelection';
  late TiledComponent gameLevelSelection;
  late final World _world;
  late final CameraComponent _camera;

  @override
  Future<void> onLoad() async {
    await loadGameLevelSelection();
    super.onLoad();
    // Load your assets and initialize your component here
  }

   @override
  void onRemove() {
    _world.removeFromParent();
    _camera.removeFromParent();
    super.onRemove();
  }

Future<void> loadGameLevelSelection() async {
    // developer.log("Loading a level");
    gameLevelSelection = await TiledComponent.load('Background-test-23.tmx', Vector2(64, 64));

    add(gameLevelSelection);
    _world = World(children: [gameLevelSelection]);
    await add(_world);
    _camera = CameraComponent.withFixedResolution(
      width: 16*64, height: 12*64,
      world: _world,
    );
    _camera.viewfinder.anchor = Anchor.topLeft;
    await add(_camera);
  }
}
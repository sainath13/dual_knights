import 'package:dual_knights/dual_knights.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class GameMainMenu extends Component with HasGameRef<DualKnights>{

  static const id = 'GameMainMenu';
  late TiledComponent gameMainMenu;
  late final World _world;
  late final CameraComponent _camera;

  @override
  Future<void> onLoad() async {
    await loadGameMainMenu();
    super.onLoad();
    // Load your assets and initialize your menu here
  }

  @override
  void onRemove() {
    _world.removeFromParent();
    _camera.removeFromParent();
    super.onRemove();

  }

  
  Future<void> loadGameMainMenu() async {
    gameMainMenu = await TiledComponent.load('Background-test-23.tmx', Vector2(64, 64));

    add(gameMainMenu);
    _world = World(children: [gameMainMenu]);
    await add(_world);
    _camera = CameraComponent.withFixedResolution(
      width: 16*64, height: 12*64,
      world: _world,
    );
    _camera.viewfinder.anchor = Anchor.topLeft;
    await add(_camera);
  }



}
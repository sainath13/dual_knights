import 'dart:async';
import 'dart:ui';

import 'package:dual_knights/components/level.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class DualKnights extends FlameGame{
  late final CameraComponent cam;
  final world = Level();

  @override
  Color backgroundColor()  => const Color(0xFF211F30);
  @override
  FutureOr<void> onLoad() async{
    await images.loadAllImages();
    cam = CameraComponent.withFixedResolution(world: world, width: 1280, height: 960);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam,world]);
    return super.onLoad();
  }
  
}
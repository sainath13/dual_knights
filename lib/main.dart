import 'package:dual_knights/dual_knights.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  DualKnights game = DualKnights();//..debugMode = true;
  runApp(
    GameWidget(game: true ? DualKnights() : game),
  );
}


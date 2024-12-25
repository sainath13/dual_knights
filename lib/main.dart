import 'package:dual_knights/dual_knights.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AmplifyAuthCognito auth = AmplifyAuthCognito();
  final AmplifyStorageS3 storage = AmplifyStorageS3();

  await Amplify.addPlugins([auth, storage]);
    try {
  await Amplify.configure('your amplifyconfiguration.json');
  } catch (e) {
    print('Error configuring Amplify: $e');
  }
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  DualKnights game = DualKnights();//..debugMode = true;
  runApp(
    GameWidget(game: true ? DualKnights() : game),
  );
}
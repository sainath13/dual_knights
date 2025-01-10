import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dio/dio.dart';
import 'package:dual_knights/amplifyconfiguration.dart';
import 'package:dual_knights/dual_knights.dart';
import 'package:dual_knights/repository/game_repository.dart';
import 'package:dual_knights/repository/local_storage.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  await _configureAmplify();
  final dio = Dio();
  const baseUrl = 'https://your-api-url.com'; // Replace with your actual API URL
  LocalStorageService localStorageService = LocalStorageService();
  final gameRepository = GameRepository(dio: dio, baseUrl: baseUrl,localStorageService: localStorageService);
  DualKnights game = DualKnights(gameRepository: gameRepository);//..debugMode = true;
  runApp(
      MouseRegion(
        onHover: (event) {
          html.document.body?.style.cursor = 'url(assets/images/UI/Pointers/01.png), auto';
        },
        onExit: (event) {
          html.document.body?.style.cursor = 'auto';
        },
        child:
    GameWidget(
        mouseCursor :  SystemMouseCursors.move,
        game: true ? DualKnights(gameRepository: gameRepository) : game),
  ));
}

 Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}


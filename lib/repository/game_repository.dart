import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dual_knights/model/character_dialogue_model.dart';
import 'package:dual_knights/model/level_details.dart';
import 'package:dual_knights/model/user_model.dart';
import 'package:dual_knights/model/user_progress_model.dart';
import 'package:dual_knights/model/user_settings_model.dart';
import 'package:dual_knights/repository/local_storage.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';


class GameRepository {
  final Dio dio;
  final String baseUrl;
  final LocalStorageService localStorageService;

  GameRepository({
    required this.dio,
    required this.baseUrl,
    required this.localStorageService,
  });



  Future<String> generateJwtToken(GameUser user) async {
      
      final response = await dio.post(
        '$baseUrl/api/v1/user-info',
        data: user.toJson(),
      );

      return response.data['data']['token'] as String;
    }

  /// Get user progress (API or local storage)
  Future<UserProgress> getUserProgress(String? jwtToken) async {
    if (jwtToken != null) {
      // Fetch from API
      final response = await dio.get(
        '$baseUrl/api/v1/game-levels/user/user/levels',
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );
      final userProgress = UserProgress.fromJson(response.data['data']);

      // Save locally for offline use
      await localStorageService.saveUserProgress(userProgress.toJson());
      return userProgress;
    } else {
      // Fetch from local storage
      final localProgress = await localStorageService.getUserProgress();
      return UserProgress.fromJson(localProgress);
    }
  }

  /// Get user settings (API or local storage)
  Future<UserSettings> getUserSettings(String? jwtToken) async {
    if (jwtToken != null) {
      // Fetch from API
      final response = await dio.get(
        '$baseUrl/api/v1/user-setting/settings',
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );
      final userSettings = UserSettings.fromJson(response.data);

      // Save locally for offline use
      await localStorageService.saveUserSettings(userSettings.toJson());
      return userSettings;
    } else {
      // Fetch from local storage
      final localSettings = await localStorageService.getUserSettings();
      return UserSettings.fromJson(localSettings);
    }
  }

   Future<void> saveUserSettings(UserSettings settings, String? jwtToken) async {
    if (jwtToken != null) {
      // Save to API
      await dio.post(
        '$baseUrl/api/v1/user-setting/settings',
        data: settings.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );
    }

    // Save locally (always save for offline support)
    await localStorageService.saveUserSettings(settings.toJson());
  }


  /// Mark level complete (API or save locally for guest users)
  Future<bool> markLevelComplete(
    int completedLevel, int stars, String? jwtToken) async {
      print('markLevelComplete called');
  if (jwtToken != null) {
    // Send to API
    final response = await dio.post(
      '$baseUrl/api/v1/game-levels/user/level/$completedLevel',
      data: {'completedLevel': completedLevel, 'stars': stars},
      options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
    );

    return true;
  } else {
    // Update progress locally
    final localProgress = await localStorageService.getUserProgress();

    // Ensure levelProgress exists in local storage
    if (!localProgress.containsKey('levelProgress')) {
      localProgress['levelProgress'] = {};
    }

    // Update the current level as completed
    localProgress['levelProgress'][completedLevel.toString()] = {
      'locked': false,
      'stars': stars,
    };

    // Increment the unlocked level
    final lastLevelUnlocked = localProgress['lastLevelUnlocked'] ?? 1;
    if (completedLevel == lastLevelUnlocked) {
      final nextLevel = completedLevel + 1;

      localProgress['levelProgress'][nextLevel.toString()] = {
        'locked': false,
        'stars': 0, // New level starts with 0 stars
      };
      localProgress['lastLevelUnlocked'] = nextLevel;
    }

    // Save updated progress locally
    await localStorageService.saveUserProgress(localProgress);
    return true;
  }
}

Future<TiledComponent> loadTmxFromS3(String bucketUrl,String tmxFileName) async {
    try {
      final String fullUrl = '$bucketUrl/$tmxFileName';
      
      // Download TMX file as string
      final response = await dio.get(
        fullUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      
      final tmxString = utf8.decode(response.data);
      final images = Images();
      // Create TiledMap from string
      final tiledMap = await RenderableTiledMap.fromString(
          tmxString,Vector2(64, 64),
        
      );


      return TiledComponent(
        tiledMap,
        priority: 1,
      );
      
    } catch (e) {
      throw Exception('Error loading TMX from S3: $e');
    }
  }

  Future<CharacterDialogue> getCharacterDialogues(String? jwtToken,String event,String character) async {
    if (jwtToken != null) {
      
      final response = await dio.post(
        '$baseUrl/api/v1/bedrock/ask',
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
        data: {
          'event': event,
          'character': character,
        },
      );
      final characterDialogue = CharacterDialogue.fromJson(response.data['data']);

      
      return characterDialogue;
    } else {
      // Fetch from local storage
      
      return CharacterDialogue.fromJson({});
    }
  }

}

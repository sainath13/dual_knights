// lib/services/game_api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/game_level.dart';
import '../models/game_map.dart';

class GameApiService {
  final String baseUrl;
  final Map<String, String> headers;

  GameApiService.defaultConfig()
      : baseUrl = ApiConfig.baseUrl,
        headers = ApiConfig.headers;
  // Game Levels API
  Future<GameLevel> createGameLevel({
    required String gameId,
    required int index,
    required String status,
    required String name,
    required String difficulty,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.gameLevels}'),
        headers: headers,
        body: jsonEncode({
          'id': gameId,
          'index': index,
          'status': status,
          'name': name,
          'difficulty': difficulty,
          'description': description,
        }),
      ).timeout(Duration(milliseconds: ApiConfig.connectionTimeout));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GameLevel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create game level: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create game level: $e');
    }
  }

  Future<GameLevel> getGameLevel(String gameId, int index) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.gameLevels}/$gameId/$index'),
        headers: headers,
      ).timeout(Duration(milliseconds: ApiConfig.connectionTimeout));
      
      if (response.statusCode == 200) {
        return GameLevel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch game level: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch game level: $e');
    }
  }

  Future<GameMap> createGameMap({
    required String levelId,
    required String mapId,
    required String status,
    required String version,
    required Map<String, dynamic> mapData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.maps}'),
        headers: headers,
        body: jsonEncode({
          'levelId': levelId,
          'mapId': mapId,
          'status': status,
          'version': version,
          'mapData': mapData,
        }),
      ).timeout(Duration(milliseconds: ApiConfig.connectionTimeout));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GameMap.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create game map: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create game map: $e');
    }
  }

  // ... other methods
}

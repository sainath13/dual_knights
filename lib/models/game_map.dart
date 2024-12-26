// lib/models/game_map.dart

import 'dart:convert';

class GameMap {
  final String levelId;
  final String mapId;
  final String status;
  final String version;
  final Map<String, dynamic> mapData;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GameMap({
    required this.levelId,
    required this.mapId,
    required this.status,
    required this.version,
    required this.mapData,
    this.createdAt,
    this.updatedAt,
  });

  // Create a copy with some fields updated
  GameMap copyWith({
    String? levelId,
    String? mapId,
    String? status,
    String? version,
    Map<String, dynamic>? mapData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GameMap(
      levelId: levelId ?? this.levelId,
      mapId: mapId ?? this.mapId,
      status: status ?? this.status,
      version: version ?? this.version,
      mapData: mapData ?? Map<String, dynamic>.from(this.mapData),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Factory constructor to create GameMap from JSON
  factory GameMap.fromJson(Map<String, dynamic> json) {
    return GameMap(
      levelId: json['levelId'] as String,
      mapId: json['mapId'] as String,
      status: json['status'] as String,
      version: json['version'] as String,
      mapData: Map<String, dynamic>.from(json['mapData'] as Map),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  // Convert GameMap to JSON
  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'mapId': mapId,
      'status': status,
      'version': version,
      'mapData': mapData,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert to String
  @override
  String toString() {
    return 'GameMap(levelId: $levelId, mapId: $mapId, status: $status, '
           'version: $version, mapData: $mapData, '
           'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  // Implement equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is GameMap &&
      other.levelId == levelId &&
      other.mapId == mapId &&
      other.status == status &&
      other.version == version &&
      _mapEquals(other.mapData, mapData) &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  // Helper method to compare maps
  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    return map1.entries.every((e) => 
      map2.containsKey(e.key) && map2[e.key] == e.value);
  }

  @override
  int get hashCode {
    return levelId.hashCode ^
      mapId.hashCode ^
      status.hashCode ^
      version.hashCode ^
      mapData.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }

  // Static methods for validation
  static const List<String> validStatuses = ['active', 'inactive', 'draft'];
  
  static bool isValidStatus(String status) {
    return validStatuses.contains(status.toLowerCase());
  }

  static bool isValidVersion(String version) {
    try {
      final parts = version.split('.');
      return parts.every((part) => int.tryParse(part) != null);
    } catch (_) {
      return false;
    }
  }

  // Factory constructor for creating a new GameMap with default values
  factory GameMap.create({
    required String levelId,
    required String mapId,
    String status = 'draft',
    String version = '1.0',
    required Map<String, dynamic> mapData,
  }) {
    final now = DateTime.now();
    return GameMap(
      levelId: levelId,
      mapId: mapId,
      status: status,
      version: version,
      mapData: mapData,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Encode to JSON string
  String toJsonString() => json.encode(toJson());

  // Create from JSON string
  static GameMap fromJsonString(String jsonString) {
    return GameMap.fromJson(json.decode(jsonString));
  }

  // Required map data fields
  static const requiredMapDataFields = ['terrain', 'difficulty'];

  // Validation method
  String? validate() {
    if (levelId.isEmpty) {
      return 'LevelId cannot be empty';
    }
    if (mapId.isEmpty) {
      return 'MapId cannot be empty';
    }
    if (!isValidStatus(status)) {
      return 'Invalid status: $status. Must be one of ${validStatuses.join(", ")}';
    }
    if (!isValidVersion(version)) {
      return 'Invalid version format: $version. Must be in format x.y';
    }
    if (mapData.isEmpty) {
      return 'MapData cannot be empty';
    }
    
    // Check required map data fields
    for (final field in requiredMapDataFields) {
      if (!mapData.containsKey(field)) {
        return 'Missing required map data field: $field';
      }
    }
    
    return null;
  }

  // Utility getters
  bool get isActive => status == 'active';
  bool get isDraft => status == 'draft';
  bool get isInactive => status == 'inactive';

  // Map data getters
  String? get terrain => mapData['terrain'] as String?;
  String? get difficulty => mapData['difficulty'] as String?;
  
  // Version comparison
  bool isNewerThan(String otherVersion) {
    final thisVer = version.split('.').map(int.parse).toList();
    final otherVer = otherVersion.split('.').map(int.parse).toList();
    
    for (var i = 0; i < thisVer.length; i++) {
      if (thisVer[i] > otherVer[i]) return true;
      if (thisVer[i] < otherVer[i]) return false;
    }
    return false;
  }
}

// Extension methods for List<GameMap>
extension GameMapListExtension on List<GameMap> {
  // Filter active maps
  List<GameMap> get activeMaps => 
      where((map) => map.status == 'active').toList();

  // Filter by level
  List<GameMap> byLevel(String levelId) => 
      where((map) => map.levelId == levelId).toList();

  // Get latest version of each map
  List<GameMap> getLatestVersions() {
    final mapGroups = groupBy(this, (GameMap m) => m.mapId);
    return mapGroups.values.map((maps) => 
      maps.reduce((a, b) => 
        a.isNewerThan(b.version) ? a : b
      )).toList();
  }

  // Find map by id and version
  GameMap? findByIdAndVersion(String mapId, String version) => 
      cast<GameMap?>().firstWhere(
        (map) => map?.mapId == mapId && map?.version == version,
        orElse: () => null
      );
}

// Helper function for groupBy
Map<T, List<S>> groupBy<S, T>(Iterable<S> values, T Function(S) key) {
  var map = <T, List<S>>{};
  for (var element in values) {
    (map[key(element)] ??= []).add(element);
  }
  return map;
}


/*
void main() {
  // Create a new game map
  final gameMap = GameMap.create(
    levelId: 'level1',
    mapId: 'map1',
    mapData: {
      'terrain': 'forest',
      'difficulty': 'medium',
      'obstacles': [
        {'type': 'tree', 'position': {'x': 10, 'y': 20}},
        {'type': 'rock', 'position': {'x': 30, 'y': 40}},
      ],
    },
  );

  // Validate the map
  final validationError = gameMap.validate();
  if (validationError != null) {
    print('Validation error: $validationError');
    return;
  }

  // Convert to JSON
  final json = gameMap.toJson();
  print('Map as JSON: $json');

  // Create from JSON
  final decodedMap = GameMap.fromJson(json);
  print('Decoded map: $decodedMap');

  // Create a list of maps
  final maps = [
    gameMap,
    GameMap.create(
      levelId: 'level1',
      mapId: 'map1',
      version: '1.1',
      status: 'active',
      mapData: {
        'terrain': 'desert',
        'difficulty': 'hard',
      },
    ),
  ];

  // Use extension methods
  final activeMaps = maps.activeMaps;
  final levelMaps = maps.byLevel('level1');
  final latestMaps = maps.getLatestVersions();
  final foundMap = maps.findByIdAndVersion('map1', '1.0');
}

*/

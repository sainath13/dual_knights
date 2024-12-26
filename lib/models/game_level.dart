// lib/models/game_level.dart

import 'dart:convert';

class GameLevel {
  final String id;
  final int index;
  final String status;
  final String name;
  final String difficulty;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GameLevel({
    required this.id,
    required this.index,
    required this.status,
    required this.name,
    required this.difficulty,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Create a copy of GameLevel with some fields updated
  GameLevel copyWith({
    String? id,
    int? index,
    String? status,
    String? name,
    String? difficulty,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GameLevel(
      id: id ?? this.id,
      index: index ?? this.index,
      status: status ?? this.status,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Factory constructor to create GameLevel from JSON
  factory GameLevel.fromJson(Map<String, dynamic> json) {
    return GameLevel(
      id: json['id'] as String,
      index: json['index'] as int,
      status: json['status'] as String,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  // Convert GameLevel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
      'status': status,
      'name': name,
      'difficulty': difficulty,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert GameLevel to String
  @override
  String toString() {
    return 'GameLevel(id: $id, index: $index, status: $status, name: $name, '
           'difficulty: $difficulty, description: $description, '
           'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  // Implement equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is GameLevel &&
      other.id == id &&
      other.index == index &&
      other.status == status &&
      other.name == name &&
      other.difficulty == difficulty &&
      other.description == description &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      index.hashCode ^
      status.hashCode ^
      name.hashCode ^
      difficulty.hashCode ^
      description.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }

  // Static methods for status and difficulty validation
  static const List<String> validStatuses = ['active', 'inactive', 'draft'];
  static const List<String> validDifficulties = ['easy', 'medium', 'hard'];

  static bool isValidStatus(String status) {
    return validStatuses.contains(status.toLowerCase());
  }

  static bool isValidDifficulty(String difficulty) {
    return validDifficulties.contains(difficulty.toLowerCase());
  }

  // Factory constructor for creating a new GameLevel with default values
  factory GameLevel.create({
    required String id,
    required int index,
    String status = 'draft',
    required String name,
    String difficulty = 'easy',
    required String description,
  }) {
    final now = DateTime.now();
    return GameLevel(
      id: id,
      index: index,
      status: status,
      name: name,
      difficulty: difficulty,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Encode to JSON string
  String toJsonString() => json.encode(toJson());

  // Create from JSON string
  static GameLevel fromJsonString(String jsonString) {
    return GameLevel.fromJson(json.decode(jsonString));
  }

  // Validation method
  String? validate() {
    if (id.isEmpty) {
      return 'ID cannot be empty';
    }
    if (index < 0) {
      return 'Index must be non-negative';
    }
    if (!isValidStatus(status)) {
      return 'Invalid status: $status. Must be one of ${validStatuses.join(", ")}';
    }
    if (!isValidDifficulty(difficulty)) {
      return 'Invalid difficulty: $difficulty. Must be one of ${validDifficulties.join(", ")}';
    }
    if (name.isEmpty) {
      return 'Name cannot be empty';
    }
    if (description.isEmpty) {
      return 'Description cannot be empty';
    }
    return null;
  }

  // Check if level is playable
  bool get isPlayable => status == 'active';

  // Check if level is draft
  bool get isDraft => status == 'draft';

  // Check if level is inactive
  bool get isInactive => status == 'inactive';
}

// Extension methods for List<GameLevel>
extension GameLevelListExtension on List<GameLevel> {
  // Filter active levels
  List<GameLevel> get activeLevels => 
      where((level) => level.status == 'active').toList();

  // Filter by difficulty
  List<GameLevel> byDifficulty(String difficulty) => 
      where((level) => level.difficulty == difficulty).toList();

  // Sort by index
  List<GameLevel> sortedByIndex() => 
      [...this]..sort((a, b) => a.index.compareTo(b.index));

  // Get level by id
  GameLevel? findById(String id) => 
      cast<GameLevel?>().firstWhere(
        (level) => level?.id == id, 
        orElse: () => null
      );
}

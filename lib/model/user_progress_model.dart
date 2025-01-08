class UserProgress {
  final Map<int, LevelProgress> levelProgress;
  final int lastLevelUnlocked;

  UserProgress({
    required this.levelProgress,
    required this.lastLevelUnlocked,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final levelProgressJson = json['levelProgress'] as Map<String, dynamic>?;
    final progress = levelProgressJson?.map(
      (key, value) => MapEntry(
        int.tryParse(key) ?? 1,
        value is Map<String, dynamic>
            ? LevelProgress.fromJson(value)
            : LevelProgress(locked: false, stars: 0),
      ),
    ) ?? {1: LevelProgress(locked: false, stars: 0)};
    

    return UserProgress(
      levelProgress: progress,
      lastLevelUnlocked: json['lastLevelUnlocked'] as int? ?? 0,
    );
  }

  

  Map<String, dynamic> toJson() {
    return {
      'levelProgress': levelProgress.map(
        (key, value) => MapEntry(key.toString(), value.toJson()),
      ),
      'lastLevelUnlocked': lastLevelUnlocked,
    }..removeWhere((key, value) => value == null); // Remove null values
  }
}

class LevelProgress {
  final bool locked;
  final int stars;

  LevelProgress({
    required this.locked,
    required this.stars,
  });

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      locked: json['locked'] as bool? ?? true, // Default to true if null
      stars: json['stars'] as int? ?? 0,      // Default to 0 if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locked': locked,
      'stars': stars,
    }..removeWhere((key, value) => value == null); // Remove null values
  }
}

class UserSettings {
  final bool sfx;
  final bool music;
  final bool joystick;

  UserSettings({
    required this.sfx,
    required this.music,
    required this.joystick,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      sfx: json['SFX'] as bool? ?? true, // Default to true if null
      music: json['Music'] as bool? ?? true,
      joystick: json['joystick'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SFX': sfx,
      'Music': music,
      'joystick': joystick,
    }..removeWhere((key, value) => value == null); // Remove null values
  }
}

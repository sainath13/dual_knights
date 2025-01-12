
class CharacterDialogue {
  final String event;
  final String character;
  final String taunt;


  CharacterDialogue({
    required this.event,
    required this.character,
    required this.taunt,
  });

  factory CharacterDialogue.fromJson(Map<String, dynamic> json) {
    return CharacterDialogue(
      event: json['event'] as String? ?? '',
      character: json['character'] as String? ?? '',
      taunt: json['taunt'] as String? ?? '',
    );
    }

    Map<String, dynamic> toJson() {
    return {
      'event': event,
      'character': character,
      'taunt': taunt,
    };
    }
}
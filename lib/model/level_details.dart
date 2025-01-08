class LevelDetail {
  final String tmxFile;

  LevelDetail({required this.tmxFile});

  factory LevelDetail.fromJson(Map<String, dynamic> json) {
    return LevelDetail(tmxFile: json['tmxFile'] as String);
  }
}

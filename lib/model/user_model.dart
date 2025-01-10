
class GameUser {
  final String userId;
  final String email;

  GameUser({
    required this.userId,
    required this.email,
  });

  factory GameUser.fromJson(Map<String, dynamic> json) {
    return GameUser(
      userId: json['userId'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
    };
  }
}
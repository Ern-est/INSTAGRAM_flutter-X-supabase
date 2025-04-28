class Comment {
  final String id;
  final String text;
  final String userId;
  final String username;
  final String profileUrl; // Correct field name from users table

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    required this.username,
    required this.profileUrl,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['users'] ?? {}; // Relation is with users table
    return Comment(
      id: json['id'] as String,
      text: json['text'] ?? '',
      userId: json['user_id'] ?? '',
      username: user['username'] ?? 'Unknown',
      profileUrl: user['profile_url'] ?? '', // Correct field used here
    );
  }
}

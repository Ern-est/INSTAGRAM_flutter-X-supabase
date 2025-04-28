class Like {
  final String id;
  final String postId;
  final String userId;

  Like({required this.id, required this.postId, required this.userId});

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
    );
  }
}

class Post {
  final String id;
  final String userId; // Added userId field
  final String imageUrl;
  final String caption;
  final DateTime createdAt;

  // Added username and profileImageUrl as nullable fields
  String? username;
  String? profileImageUrl;

  Post({
    required this.id,
    required this.userId, // Updated constructor to include userId
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    this.username, // Optional fields for username and profileImageUrl
    this.profileImageUrl,
  });

  // fromJson method to create a Post object from a map
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '', // Ensure user_id is fetched
      imageUrl: json['image_url'] ?? '',
      caption: json['caption'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      username: json['username'], // Make sure username is optional
      profileImageUrl:
          json['profile_image_url'], // Make sure profileImageUrl is optional
    );
  }

  // Optionally, you can define a toJson method if you need to send the Post object to the database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId, // Sending userId instead of username
      'image_url': imageUrl,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper method to update the username and profileImageUrl after the post is created
  void updateUserDetails(String username, String profileImageUrl) {
    this.username = username;
    this.profileImageUrl = profileImageUrl;
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:insta_clone/models/comment.dart';

class CommentService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Fetch comments for a specific post
  Stream<List<Comment>> getComments(String postId) {
    return supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: true)
        .map((data) => data.map((e) => Comment.fromJson(e)).toList());
  }

  // Add a new comment to a post
  Future<void> addComment(
    String postId,
    String userId,
    String text, {
    required String username, // Named parameter
  }) async {
    // Fetch profile_url from the 'users' table
    final Map<String, dynamic> response =
        await supabase
            .from('users')
            .select('profile_url')
            .eq('id', userId)
            .single();

    String? profileUrl = response['profile_url'];

    // Add the comment with the correct profile URL and fixed created_at
    await supabase.from('comments').insert({
      'post_id': postId,
      'user_id': userId,
      'text': text,
      'username': username,
      'profile_url': profileUrl,
      'created_at': DateTime.now().toUtc().toIso8601String(), // <-- IMPORTANT
    });
  }
}

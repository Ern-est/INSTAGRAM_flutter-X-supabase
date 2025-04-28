import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  final supabase = Supabase.instance.client;

  Future<void> likePost(String postId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await supabase.from('likes').insert({
      'post_id': postId,
      'user_id': user.id,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> unlikePost(String postId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await supabase
        .from('likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', user.id);
  }

  Future<bool> hasLikedPost(String postId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    final response =
        await supabase
            .from('likes')
            .select()
            .eq('post_id', postId)
            .eq('user_id', user.id)
            .maybeSingle();

    return response != null;
  }

  Future<int> getLikeCount(String postId) async {
    final response = await supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId);

    return response.length; // just return the length!
  }
}

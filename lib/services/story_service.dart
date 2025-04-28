// lib/services/story_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:insta_clone/models/story.dart';
import 'package:uuid/uuid.dart';

class StoryService {
  final SupabaseClient supabase = Supabase.instance.client;
  final Uuid _uuid = Uuid();

  /// Pick image and upload to storage
  Future<String?> pickAndUploadStoryImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      final fileExt = pickedFile.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExt';

      // Upload to 'post-images' bucket under 'stories/' folder
      await supabase.storage
          .from('post-images')
          .upload('stories/$fileName', file);

      final imageUrl = supabase.storage
          .from('post-images')
          .getPublicUrl('stories/$fileName');

      return imageUrl;
    } catch (e) {
      print('Error picking/uploading story image: $e');
      return null;
    }
  }

  /// Insert new story to the database
  Future<void> uploadStory(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No logged-in user');

      final currentTime = DateTime.now();
      final expirationTime = currentTime.add(const Duration(hours: 24));

      await supabase.from('stories').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'created_at': currentTime.toUtc(),
        'expires_at': expirationTime.toUtc(),
      });
    } catch (e) {
      print('Error uploading story: $e');
      rethrow;
    }
  }

  /// Fetch active (non-expired) stories
  Future<List<Story>> fetchActiveStories() async {
    try {
      final currentTime = DateTime.now().toUtc();

      final List<dynamic> data = await supabase
          .from('stories')
          .select()
          .gt('expires_at', currentTime); // Only fetch active stories

      return data.map((e) => Story.fromJson(e)).toList();
    } catch (e) {
      print('Failed to load stories: $e');
      rethrow;
    }
  }

  /// Realtime stream of active stories
  Stream<List<Story>> getStories() {
    final currentTime = DateTime.now().toUtc();

    return supabase
        .from('stories')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (maps) =>
              maps
                  .where(
                    (story) => DateTime.parse(
                      story['expires_at'],
                    ).isAfter(currentTime),
                  )
                  .map((e) => Story.fromJson(e))
                  .toList(),
        );
  }
}

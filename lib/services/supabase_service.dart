import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadPostImage(File file) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final fileExt = path.extension(file.path);
      final fileName = const Uuid().v4() + fileExt;
      final filePath = '${user.id}/$fileName';

      final fileBytes = await file.readAsBytes();

      // Upload image to Supabase Storage
      await supabase.storage
          .from('post-images')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // If upload fails, it will throw an error and go to catch block

      final publicUrl = supabase.storage
          .from('post-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  Future<void> createPost(String imageUrl, String caption) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not authenticated';

      await supabase.from('posts').insert({
        'user_id': user.id,
        'image_url': imageUrl,
        'caption': caption,
      });

      // If insert fails, it will throw and go to catch block
    } catch (e) {
      print('Post creation error: $e');
      rethrow; // or return an error if you want
    }
  }
}

// lib/core/services/storage_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> uploadProfileImage(File imageFile, String uid) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName = const Uuid().v4();
    final filePath = '$uid/$fileName.$fileExt';

    try {
      await _client.storage
          .from('post-images')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // Return the public URL to the uploaded image
      return _client.storage.from('post-images').getPublicUrl(filePath);
    } catch (e) {
      // Log and throw a more helpful error
      throw Exception('Failed to upload image: $e');
    }
  }
}

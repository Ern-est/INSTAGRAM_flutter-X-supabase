import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_clone/services/supabase_service.dart';

class PostUploaderScreen extends StatefulWidget {
  const PostUploaderScreen({super.key});

  @override
  State<PostUploaderScreen> createState() => _PostUploaderScreenState();
}

class _PostUploaderScreenState extends State<PostUploaderScreen> {
  File? _image;
  final _captionController = TextEditingController();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_image == null || _captionController.text.isEmpty) return;

    setState(() => _isUploading = true);

    final service = SupabaseService();
    final imageUrl = await service.uploadPostImage(_image!);

    if (imageUrl != null) {
      // Upload image was successful, now create post
      try {
        await service.createPost(imageUrl, _captionController.text);
        if (mounted) {
          // Post created successfully
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Post uploaded!')));
          setState(() {
            _image = null;
            _captionController.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          // Handle post creation failure
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to create post: $e')));
        }
      }
    } else {
      // Image upload failed
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image upload failed.')));
      }
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child:
                  _image == null
                      ? Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(child: Text('Tap to select image')),
                      )
                      : Image.file(_image!, height: 200),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: _uploadPost,
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Post'),
                ),
          ],
        ),
      ),
    );
  }
}

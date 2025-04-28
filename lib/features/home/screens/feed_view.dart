import 'package:flutter/material.dart';
import 'package:insta_clone/features/home/screens/story_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:insta_clone/services/comment_service.dart';
import 'package:insta_clone/services/like_service.dart';
import 'package:insta_clone/services/story_service.dart';
import 'package:insta_clone/models/post.dart';
import 'package:insta_clone/models/comment.dart';
import 'package:insta_clone/models/story.dart';

class FeedView extends StatefulWidget {
  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final CommentService _commentService = CommentService();
  final supabase = Supabase.instance.client;
  final StoryService _storyService = StoryService();

  Future<Map<String, String>> _getUserProfile(String userId) async {
    try {
      final response =
          await supabase
              .from('users')
              .select('username, profile_url')
              .eq('id', userId)
              .single();

      return {
        'username': response['username'] ?? 'Unknown',
        'profile_image_url': response['profile_url'] ?? '',
      };
    } catch (e) {
      print('Error fetching user profile: $e');
      return {'username': 'Unknown', 'profile_image_url': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontSize: 24,
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // === STORIES SECTION ===
          SizedBox(
            height: 100,
            child: StreamBuilder<List<Story>>(
              stream: _storyService.getStories(),
              builder: (context, storySnapshot) {
                if (storySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (storySnapshot.hasError) {
                  return const Center(child: Text('Error loading stories'));
                }

                final stories = storySnapshot.data ?? [];

                if (stories.isEmpty) {
                  return const Center(child: Text('No stories yet.'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoryWidget(story: story),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StoryWidget(story: story),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Add story button
          AddStoryButton(),
          // === FEED POSTS SECTION ===
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: supabase
                  .from('posts')
                  .stream(primaryKey: ['id'])
                  .order('created_at', ascending: false)
                  .execute()
                  .map((maps) => maps.map((e) => Post.fromJson(e)).toList()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const Center(child: Text('No posts yet.'));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return FutureBuilder<Map<String, String>>(
                      future: _getUserProfile(post.userId),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (userSnapshot.hasError) {
                          return const Center(
                            child: Text('Error loading user data'),
                          );
                        }

                        final userProfile =
                            userSnapshot.data ??
                            {'username': 'Unknown', 'profile_image_url': ''};

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User header
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    userProfile['profile_image_url']!.isNotEmpty
                                        ? NetworkImage(
                                          userProfile['profile_image_url']!,
                                        )
                                        : null,
                                child:
                                    userProfile['profile_image_url']!.isEmpty
                                        ? const Icon(Icons.person)
                                        : null,
                              ),
                              title: Text(
                                userProfile['username']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Post image
                            post.imageUrl.isNotEmpty
                                ? Image.network(
                                  post.imageUrl,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.broken_image,
                                            size: 200,
                                          ),
                                )
                                : const Icon(
                                  Icons.image_not_supported,
                                  size: 200,
                                ),

                            // Caption
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(post.caption),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

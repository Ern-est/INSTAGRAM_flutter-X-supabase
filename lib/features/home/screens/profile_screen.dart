// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:insta_clone/features/auth/screens/login_screen.dart'; // Replace with your login screen path

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response =
        await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

    return response;
  }

  void _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Failed to load user data.'));
        }

        final userData = snapshot.data!;
        final profileUrl = userData['profile_url'] ?? '';
        final username = userData['username'] ?? 'No username';
        final bio = userData['bio'] ?? 'No bio';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _signOut(context),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
                  child:
                      profileUrl.isEmpty
                          ? const Icon(Icons.person, size: 50)
                          : null,
                ),
                const SizedBox(height: 16),
                Text(username, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text(bio),
              ],
            ),
          ),
        );
      },
    );
  }
}

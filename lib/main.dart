import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insta_clone/features/auth/screens/splash_screen.dart';
import 'package:insta_clone/features/auth/screens/signup_screen.dart';
import 'package:insta_clone/features/auth/screens/login_screen.dart';
import 'package:insta_clone/features/home/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://yvqlxxukqnaxysrhcnpr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2cWx4eHVrcW5heHlzcmhjbnByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzOTg0NDUsImV4cCI6MjA2MDk3NDQ0NX0.Z_3F93S7ekzwR8ZK_5BsotDw0pwW2KemKItkUTWhvkw',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InstaClone',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

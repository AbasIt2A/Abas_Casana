// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/auth_services.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://abesvjbwyaywhpdnnykq.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiZXN2amJ3eWF5d2hwZG5ueWtxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzMyNDIsImV4cCI6MjA3NzQwOTI0Mn0.F9bWXCbEiOfdvkSoMzbGgz5-aueAK_uvVoDoYcwK0_Y',
    );
    print('Supabase initialized successfully');
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing Supabase: $e');
    // Show error widget if Supabase fails to initialize
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to initialize Supabase: $e')),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PartSmart',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
      ),
      home: const AuthWrapper(), // Use AuthWrapper as the home
      debugShowCheckedModeBanner: false,
    );
  }
}

// AuthWrapper listens to auth state and shows Login or Home screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<AuthState>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Check connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Check if user data exists (logged in)
        if (snapshot.hasData && snapshot.data?.session != null) {
          print("User is logged in: ${snapshot.data?.session?.user.id}");
          return const HomeScreen(); // Show Home screen if logged in
        }
        // User is logged out
        else {
          print("User is logged out.");
          return const LoginScreen(); // Show Login screen if not logged in
        }
      },
    );
  }
}

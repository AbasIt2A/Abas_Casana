// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/auth_services.dart';
import 'services/listings_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Wrap everything in a try-catch to prevent crashes
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Add error handling for Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    };
    
    print('Starting Supabase initialization...');
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://abesvjbwyaywhpdnnykq.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiZXN2amJ3eWF5d2hwZG5ueWtxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzMyNDIsImV4cCI6MjA3NzQwOTI0Mn0.F9bWXCbEiOfdvkSoMzbGgz5-aueAK_uvVoDoYcwK0_Y',
    );
    print('Supabase initialized successfully');
    
    print('Starting app...');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('CRITICAL ERROR: $e');
    print('Stack trace: $stackTrace');
    
    // Run a minimal error app
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 24),
                    const Text(
                      'App Error',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      e.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Try to restart
                        main();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
      title: 'Mobile Marketplace',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// AuthWrapper listens to auth state and shows Login or Home screen
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
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
        
        // Check for errors
        if (snapshot.hasError) {
          print("Auth stream error: ${snapshot.error}");
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Authentication Error',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Retry
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        // Check if user data exists (logged in)
        if (snapshot.hasData && snapshot.data?.session != null) {
          print("User is logged in: ${snapshot.data?.session?.user.id}");
          // Initialize listings service for the logged-in user
          ListingsService().initialize().catchError((e) {
            print("Error initializing ListingsService: $e");
          });
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

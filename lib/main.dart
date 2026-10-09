// File: lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'services/preferences_service.dart';
import 'screens/email_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('.env load notice: $e');
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    // Enable offline persistence for Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const TaskManagementApp());
}

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'TuList',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastUid;
  bool _hasSeenOnboarding = false;
  bool _isCheckingOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final seen = await PreferencesService.hasSeenOnboarding();
    if (mounted) {
      setState(() {
        _hasSeenOnboarding = seen;
        _isCheckingOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user != null) {
      // User is logged in: ensure onboarding flag is marked completed
      if (!_hasSeenOnboarding) {
        _hasSeenOnboarding = true;
        PreferencesService.setHasSeenOnboarding(true);
      }

      // Check if email is verified
      if (!authProvider.isEmailVerified) {
        return const EmailVerificationScreen();
      }

      if (_lastUid != user.uid) {
        _lastUid = user.uid;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Provider.of<TaskProvider>(context, listen: false).initialize(user.uid);
          }
        });
      }
      return const HomeScreen();
    } else {
      if (_lastUid != null) {
        _lastUid = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Provider.of<TaskProvider>(context, listen: false).initialize(null);
          }
        });
      }

      if (_isCheckingOnboarding) {
        return Scaffold(
          backgroundColor: AppTheme.scaffoldBackground,
          body: Center(
            child: Image.asset(
              'assets/check-list.png',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
        );
      }

      // If user has already seen onboarding (or logged out), show LoginScreen
      if (_hasSeenOnboarding) {
        return const LoginScreen();
      }

      // First-time launch: show OnboardingScreen
      return OnboardingScreen(
        onComplete: () {
          if (mounted) {
            setState(() {
              _hasSeenOnboarding = true;
            });
          }
        },
      );
    }
  }
}

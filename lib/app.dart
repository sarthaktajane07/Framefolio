import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'services/auth_service.dart';

/// Root widget. Starts with SplashScreen, then routes via _AuthGate.
class FrameFolioApp extends StatelessWidget {
  const FrameFolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashScreen(),
    );
  }
}

/// Listens to Firebase auth state and routes accordingly.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in — resolve role and go to HomeScreen
          return FutureBuilder(
            future: AuthService().fetchCurrentUserProfile(),
            builder: (context, profileSnap) {
              if (profileSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return HomeScreen(userProfile: profileSnap.data);
            },
          );
        }

        // Not signed in
        return const LoginScreen();
      },
    );
  }
}

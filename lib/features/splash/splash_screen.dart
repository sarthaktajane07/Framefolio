import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final user = _authService.currentUser;
      if (user != null) {
        final profile = await _authService.fetchCurrentUserProfile();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(userProfile: profile)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      body: Stack(
        children: [
          // Subtle background glow radial gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.7,
                  colors: [
                    const Color(AppConstants.primaryColor).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Aperture Camera Emblem Icon
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(AppConstants.cardColorValue),
                        border: Border.all(
                          color: const Color(AppConstants.primaryColor).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_rounded,
                        size: 48,
                        color: Color(AppConstants.textPrimaryValue),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // App Name
                    Text(
                      AppConstants.appName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        color: const Color(AppConstants.textPrimaryValue),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      AppConstants.appTagline,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.5,
                        color: const Color(AppConstants.textSecondaryValue),
                      ),
                    ),
                    const SizedBox(height: 54),
                    // Minimal subtle progress bar
                    SizedBox(
                      width: 40,
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: const Color(AppConstants.surfaceBorderValue),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(AppConstants.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

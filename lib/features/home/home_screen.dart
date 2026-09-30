import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../browse/browse_screen.dart';
import '../portfolio/portfolio_upload_screen.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

/// HomeScreen routes the user to the right main screen based on their role.
/// Photographers see their dashboard; clients see the browse screen.
class HomeScreen extends StatefulWidget {
  final UserModel? userProfile;

  const HomeScreen({super.key, this.userProfile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  UserModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolveProfile();
  }

  Future<void> _resolveProfile() async {
    if (widget.userProfile != null) {
      setState(() {
        _profile = widget.userProfile;
        _loading = false;
      });
      return;
    }
    // Fetch from Firestore if not passed
    final profile = await _authService.fetchCurrentUserProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isPhotographer = _profile?.isPhotographer ?? false;

    if (isPhotographer) {
      return _PhotographerDashboard(
        profile: _profile,
        onSignOut: _signOut,
      );
    }

    // Default: client goes to browse
    return BrowseScreen(profile: _profile, onSignOut: _signOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PHOTOGRAPHER DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

class _PhotographerDashboard extends StatelessWidget {
  final UserModel? profile;
  final VoidCallback onSignOut;

  const _PhotographerDashboard({
    required this.profile,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: onSignOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(AppConstants.primaryColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${profile?.name ?? 'Photographer'}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage your portfolio and bookings.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'What would you like to do?',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Upload portfolio tile
            _DashboardTile(
              icon: Icons.cloud_upload_outlined,
              title: 'Upload / Update Portfolio',
              subtitle: 'Add or change your portfolio images, bio, and pricing.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PortfolioUploadScreen(photographerUid: profile?.uid ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Browse as client tile
            _DashboardTile(
              icon: Icons.photo_library_outlined,
              title: 'Browse All Photographers',
              subtitle: 'See how your portfolio appears to clients.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BrowseScreen(profile: profile, onSignOut: onSignOut),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(AppConstants.accentColor)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

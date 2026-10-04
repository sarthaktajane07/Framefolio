import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../browse/browse_screen.dart';
import '../dashboard/photographer_dashboard.dart';
import '../portfolio/portfolio_management_screen.dart';
import '../booking/bookings_screen.dart';
import '../auth/login_screen.dart';

/// Main container frame featuring a minimal Material 3 NavigationBar.
class HomeScreen extends StatefulWidget {
  final UserModel? userProfile;

  const HomeScreen({super.key, this.userProfile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  UserModel? _profile;
  bool _loading = true;
  final AuthService _authService = AuthService();

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
    final profile = await _authService.fetchCurrentUserProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(AppConstants.backgroundColorValue),
        body: LoadingWidget(message: 'Loading FrameFolio...'),
      );
    }

    final isPhotographer = _profile?.isPhotographer ?? false;

    // Client Pages
    final List<Widget> clientPages = [
      BrowseScreen(profile: _profile),
      const BrowseScreen(), // Explore view
      const BookingsScreen(),
      _ProfileTab(profile: _profile, isPhotographer: false),
    ];

    // Photographer Pages
    final List<Widget> photographerPages = [
      PhotographerDashboard(
        userModel: _profile,
        onNavigateToPortfolio: () => setState(() => _currentIndex = 1),
        onNavigateToBookings: () => setState(() => _currentIndex = 2),
      ),
      const PortfolioManagementScreen(),
      const BookingsScreen(isPhotographer: true),
      _ProfileTab(profile: _profile, isPhotographer: true),
    ];

    final pages = isPhotographer ? photographerPages : clientPages;

    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(AppConstants.surfaceBorderValue),
              width: 1,
            ),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: const Color(AppConstants.cardColorValue),
            indicatorColor: const Color(AppConstants.textPrimaryValue),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(AppConstants.textPrimaryValue)
                    : const Color(AppConstants.textMutedValue),
                letterSpacing: 0.5,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: isSelected
                    ? const Color(AppConstants.backgroundColorValue)
                    : const Color(AppConstants.textMutedValue),
                size: 22,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: isPhotographer
                ? const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.photo_library_outlined),
                      selectedIcon: Icon(Icons.photo_library_rounded),
                      label: 'Portfolio',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today_rounded),
                      label: 'Bookings',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ]
                : const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore_rounded),
                      label: 'Explore',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month_rounded),
                      label: 'Bookings',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final UserModel? profile;
  final bool isPhotographer;

  const _ProfileTab({
    required this.profile,
    required this.isPhotographer,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      appBar: AppBar(
        title: Text(
          'Profile & Account',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(AppConstants.cardColorValue),
                border: Border.all(color: const Color(AppConstants.surfaceBorderValue)),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 48,
                color: Color(AppConstants.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile?.name ?? (isPhotographer ? 'Photographer Account' : 'Client Account'),
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(AppConstants.textPrimaryValue),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile?.email ?? 'user@framefolio.com',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(AppConstants.textSecondaryValue),
              ),
            ),
            const SizedBox(height: 12),
            Chip(
              avatar: Icon(
                isPhotographer ? Icons.camera_rounded : Icons.person_outline_rounded,
                size: 15,
                color: const Color(AppConstants.primaryColor),
              ),
              label: Text(
                isPhotographer ? 'PHOTOGRAPHER STUDIO' : 'CLIENT MEMBER',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: const Color(AppConstants.primaryColor),
                ),
              ),
              backgroundColor: const Color(AppConstants.cardColorValue),
              side: const BorderSide(
                color: Color(AppConstants.surfaceBorderValue),
              ),
            ),
            const SizedBox(height: 32),

            // Settings Tile options
            _ProfileTile(
              icon: Icons.edit_note_rounded,
              title: 'Edit Profile Information',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile details active')),
                );
              },
            ),
            _ProfileTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications & Alerts',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.security_rounded,
              title: 'Privacy & Security',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.help_outline_rounded,
              title: 'FrameFolio Support',
              onTap: () {},
            ),
            const SizedBox(height: 28),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  'SIGN OUT',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                onPressed: () async {
                  await authService.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(AppConstants.cardColorValue),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(AppConstants.surfaceBorderValue)),
          ),
          leading: Icon(icon, color: const Color(AppConstants.primaryColor), size: 20),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(AppConstants.textPrimaryValue),
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(AppConstants.textMutedValue)),
        ),
      ),
    );
  }
}

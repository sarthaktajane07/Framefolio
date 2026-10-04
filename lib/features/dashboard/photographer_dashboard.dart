import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import '../portfolio/portfolio_upload_screen.dart';
import '../portfolio/portfolio_management_screen.dart';
import '../booking/bookings_screen.dart';

/// Photographer Studio Workspace Dashboard with editorial statistics and visual archive controls.
class PhotographerDashboard extends StatelessWidget {
  final UserModel? userModel;
  final VoidCallback? onNavigateToPortfolio;
  final VoidCallback? onNavigateToBookings;

  const PhotographerDashboard({
    super.key,
    this.userModel,
    this.onNavigateToPortfolio,
    this.onNavigateToBookings,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    final user = userModel;
    final displayName = user?.name ?? authService.currentUser?.displayName ?? 'Aarav';

    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      appBar: AppBar(
        title: Text(
          'Studio Workspace',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authService.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Editorial Welcome Header (Requirement 22) ──────────────
            Text(
              'Good evening, $displayName.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(AppConstants.textPrimaryValue),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your visual archive.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(AppConstants.textSecondaryValue),
              ),
            ),
            const SizedBox(height: 24),

            // ── Primary Action (+ ADD NEW WORK) ─────────────────────────
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PortfolioUploadScreen(
                      photographerUid: user?.uid ?? '',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.textPrimaryValue),
                foregroundColor: const Color(AppConstants.backgroundColorValue),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+ ADD NEW WORK',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Minimalist Portfolio Statistics ─────────────────────────
            StreamBuilder<List<BookingModel>>(
              stream: firestoreService.bookingsStream(),
              builder: (context, snapshot) {
                final bookings = snapshot.data ?? [];
                final photographerBookings = user != null
                    ? bookings.where((b) => b.photographerId == user.uid).toList()
                    : bookings;

                final totalBookings = photographerBookings.length;
                final pendingBookings = photographerBookings
                    .where((b) => b.status.toLowerCase() == 'pending')
                    .length;

                return Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        number: '24',
                        label: 'Portfolio Works',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        number: totalBookings.toString(),
                        label: 'Bookings',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        number: pendingBookings < 10 ? '0$pendingBookings' : pendingBookings.toString(),
                        label: 'Upcoming Sessions',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // ── Quick Actions Section ──────────────────────────────────
            Text(
              'STUDIO CONTROLS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: const Color(AppConstants.primaryColor),
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _ActionTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Portfolio Grid',
                  subtitle: 'Manage portfolio works',
                  onTap: () {
                    if (onNavigateToPortfolio != null) {
                      onNavigateToPortfolio!();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PortfolioManagementScreen(),
                        ),
                      );
                    }
                  },
                ),
                _ActionTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'Session Requests',
                  subtitle: 'Client bookings',
                  onTap: () {
                    if (onNavigateToBookings != null) {
                      onNavigateToBookings!();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BookingsScreen(isPhotographer: true),
                        ),
                      );
                    }
                  },
                ),
                _ActionTile(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Upload Media',
                  subtitle: 'Add new photographs',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PortfolioUploadScreen(
                          photographerUid: user?.uid ?? '',
                        ),
                      ),
                    );
                  },
                ),
                _ActionTile(
                  icon: Icons.tune_outlined,
                  title: 'Studio Settings',
                  subtitle: 'Profile & rates',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Studio settings active'),
                        backgroundColor: Color(AppConstants.primaryColor),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String number;
  final String label;

  const _StatTile({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(AppConstants.cardColorValue),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(AppConstants.surfaceBorderValue)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(AppConstants.textPrimaryValue),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(AppConstants.textMutedValue),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(AppConstants.cardColorValue),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(AppConstants.surfaceBorderValue)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(AppConstants.primaryColor), size: 24),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(AppConstants.textPrimaryValue),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(AppConstants.textMutedValue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/photographer_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/user_model.dart';
import '../../models/photographer_model.dart';
import '../../services/firestore_service.dart';
import '../../services/seed_service.dart';
import '../auth/login_screen.dart';
import 'photographer_profile_screen.dart';

/// Main client screen: filterable grid of photographer portfolios from Firestore.
class BrowseScreen extends StatefulWidget {
  final UserModel? profile;
  final VoidCallback? onSignOut;

  const BrowseScreen({super.key, this.profile, this.onSignOut});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', ...AppConstants.specialties];

  Future<void> _signOut() async {
    if (widget.onSignOut != null) {
      widget.onSignOut!();
      return;
    }
    await _firestoreService.photographersStream().drain();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline),
            tooltip: 'Load Demo Data',
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Loading demo data...')),
                );
                await SeedService().seedDemoData();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load demo data: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Category filter chips ────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final selected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  selectedColor: const Color(AppConstants.primaryColor),
                  backgroundColor: const Color(0xFFF0EBE3),
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(AppConstants.accentColor),
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  checkmarkColor: Colors.white,
                  side: BorderSide.none,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          // ── Photographer grid ────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<PhotographerModel>>(
              stream: _firestoreService.photographersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Loading photographers…');
                }

                if (snapshot.hasError) {
                  return _ErrorState(message: snapshot.error.toString());
                }

                final allPhotographers = snapshot.data ?? [];

                // Apply category filter
                final filtered = _selectedCategory == 'All'
                    ? allPhotographers
                    : allPhotographers
                        .where((p) => p.specialty == _selectedCategory)
                        .toList();

                if (allPhotographers.isEmpty) {
                  return _EmptyState(
                    icon: Icons.photo_library_outlined,
                    title: 'No photographers yet',
                    subtitle: 'Be the first to upload a portfolio, or load demo data to preview the app.',
                    actionLabel: 'Load Demo Data',
                    onAction: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Loading demo data...')),
                        );
                        await SeedService().seedDemoData();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to load demo data: $e')),
                        );
                      }
                    },
                  );
                }

                if (filtered.isEmpty) {
                  return _EmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No "$_selectedCategory" photographers',
                    subtitle: 'Try a different category.',
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive: 1 column on phones < 400 px, else 2
                    final crossAxisCount = constraints.maxWidth < 400 ? 1 : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return PhotographerCard(
                          id: p.photographerId,
                          photographer: p.toMap(),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PhotographerProfileScreen(
                                photographerModel: p,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty / Error states ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.download_outlined),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

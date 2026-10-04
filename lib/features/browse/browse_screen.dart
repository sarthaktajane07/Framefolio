import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/photographer_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/user_model.dart';
import '../../models/photographer_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/seed_service.dart';
import '../auth/login_screen.dart';
import 'photographer_profile_screen.dart';

/// Main client discovery screen featuring Cinematic Hero, text-based category tabs, and responsive grid.
class BrowseScreen extends StatefulWidget {
  final UserModel? profile;
  final VoidCallback? onSignOut;

  const BrowseScreen({super.key, this.profile, this.onSignOut});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'ALL',
    'WEDDING',
    'PORTRAIT',
    'FASHION',
    'EVENTS',
    'TRAVEL',
    'PRE-WEDDING',
    'PRODUCT',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    if (widget.onSignOut != null) {
      widget.onSignOut!();
      return;
    }
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _scrollToGrid() {
    _scrollController.animateTo(
      340,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(AppConstants.cardColorValue),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(AppConstants.surfaceBorderValue),
                ),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Color(AppConstants.textPrimaryValue),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppConstants.appName,
              style: GoogleFonts.playfairDisplay(
                color: const Color(AppConstants.textPrimaryValue),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            tooltip: 'Load Demo Data',
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Re-seeding high-res demo photographers...')),
                );
                await SeedService().seedDemoData();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Demo photographers updated successfully!'),
                    backgroundColor: Color(AppConstants.primaryColor),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load demo data: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Cinematic Hero Section (Requirements 5 & 6) ────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(AppConstants.surfaceBorderValue),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Full Background Hero Image
                  Image.network(
                    'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&w=1600&q=80',
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 320,
                      color: const Color(AppConstants.secondaryBgValue),
                    ),
                  ),

                  // Dark Vignette Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.7),
                            Colors.black.withValues(alpha: 0.95),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Hero Text & Action Content
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'FRAMEFOLIO / PHOTOGRAPHY',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(AppConstants.primaryColor),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find the photographer\nbehind your next story.',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(AppConstants.textPrimaryValue),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover creative professionals and book your perfect session.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(AppConstants.textSecondaryValue),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // CTA Button Row
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              ElevatedButton(
                                onPressed: _scrollToGrid,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(AppConstants.textPrimaryValue),
                                  foregroundColor: const Color(AppConstants.backgroundColorValue),
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                  minimumSize: const Size(0, 46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Explore Photographers →',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(AppConstants.textPrimaryValue),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  minimumSize: const Size(0, 46),
                                  side: const BorderSide(
                                    color: Color(AppConstants.surfaceBorderValue),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Become a Photographer',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Search & Filter Controls ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Minimal Translucent Search Bar (Requirement 10)
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(AppConstants.textPrimaryValue),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search photographers, styles or locations...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: const Color(AppConstants.textMutedValue),
                        fontSize: 13.5,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(AppConstants.textSecondaryValue),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(AppConstants.cardColorValue),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(AppConstants.surfaceBorderValue),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(AppConstants.primaryColor),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section Title & Editorial Label (Requirement 7)
                  Text(
                    'EXPLORE THE ARTISTS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: const Color(AppConstants.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Featured Photographers',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(AppConstants.textPrimaryValue),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Editorial Text-Based Category Selector (Requirement 9)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  letterSpacing: 1.2,
                                  color: isSelected
                                      ? const Color(AppConstants.textPrimaryValue)
                                      : const Color(AppConstants.textMutedValue),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 2,
                                width: isSelected ? 24 : 0,
                                color: const Color(AppConstants.primaryColor),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Responsive Grid Stream (Requirements 7 & 26) ─────────────
          StreamBuilder<List<PhotographerModel>>(
            stream: _firestoreService.photographersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: LoadingWidget(message: 'Loading portfolio artists…'),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    description: snapshot.error.toString(),
                  ),
                );
              }

              final allPhotographers = snapshot.data ?? [];

              // Filter by Category & Query
              final filtered = allPhotographers.where((p) {
                final matchesCat = _selectedCategory == 'ALL' ||
                    p.specialty.toLowerCase() == _selectedCategory.toLowerCase();

                final query = _searchQuery.toLowerCase();
                final matchesQuery = query.isEmpty ||
                    p.name.toLowerCase().contains(query) ||
                    p.specialty.toLowerCase().contains(query) ||
                    p.bio.toLowerCase().contains(query);

                return matchesCat && matchesQuery;
              }).toList();

              if (allPhotographers.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.photo_camera_outlined,
                    title: 'No photographers found',
                    description: 'Be the first to upload a portfolio or load demo photographers.',
                    buttonText: 'Load Demo Photographers',
                    onButtonPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Loading demo data...')),
                        );
                        await SeedService().seedDemoData();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e')),
                        );
                      }
                    },
                  ),
                );
              }

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No photographers found',
                    description: _searchQuery.isNotEmpty
                        ? 'No match for "$_searchQuery" in category "$_selectedCategory".'
                        : 'No photographers available in "$_selectedCategory" category.',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    // Mobile = 2, Tablet = 3, Desktop = 4
                    int crossAxisCount = 2;
                    if (constraints.crossAxisExtent >= 1000) {
                      crossAxisCount = 4;
                    } else if (constraints.crossAxisExtent >= 600) {
                      crossAxisCount = 3;
                    }

                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                        childCount: filtered.length,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

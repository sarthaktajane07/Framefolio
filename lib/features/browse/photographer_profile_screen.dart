import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/portfolio_grid.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/photographer_model.dart';
import '../booking/booking_screen.dart';

/// Photographer profile screen: cover image, bio, gallery, Book Session button.
class PhotographerProfileScreen extends StatelessWidget {
  final PhotographerModel photographerModel;

  const PhotographerProfileScreen({
    super.key,
    required this.photographerModel,
  });

  @override
  Widget build(BuildContext context) {
    final p = photographerModel;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Large cover image in sliver app bar ──────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(AppConstants.primaryColor),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: p.coverPhotoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: p.coverPhotoUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const LoadingWidget(),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFF0EBE3),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: Color(AppConstants.accentColor),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFF0EBE3),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: Color(AppConstants.accentColor),
                        ),
                      ),
                    ),
  
            ),
          ),

          // ── Profile header ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + specialty row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(AppConstants.primaryColor),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Chip(
                              label: Text(p.specialty),
                              avatar: const Icon(
                                Icons.camera_outlined,
                                size: 14,
                                color: Color(AppConstants.accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Price badge
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Starting from',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '₹${p.startingPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(AppConstants.accentColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Bio
                  if (p.bio.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'About',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.bio,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  // Packages
                  if (p.packages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Packages',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: p.packages
                          .map((pkg) => Chip(label: Text(pkg)))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Portfolio (${p.portfolioImages.length} photos)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(AppConstants.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Portfolio grid ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverToBoxAdapter(
              child: PortfolioGrid(imageUrls: p.portfolioImages),
            ),
          ),
        ],
      ),

      // ── Sticky Book Session button ───────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BookingScreen(
                  photographerId: p.photographerId,
                  photographerName: p.name,
                ),
              ),
            ),
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('Book a Session'),
          ),
        ),
      ),
    );
  }
}

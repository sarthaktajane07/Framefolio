import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/portfolio_grid.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/photographer_model.dart';
import '../../models/review_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../booking/booking_screen.dart';
import '../reviews/widgets/review_card.dart';
import '../reviews/widgets/submit_review_dialog.dart';

/// Photographer profile screen: cover image, editorial metadata, bio, Selected Works gallery, Rating & Reviews, and Book Session button.
class PhotographerProfileScreen extends StatefulWidget {
  final PhotographerModel photographerModel;

  const PhotographerProfileScreen({
    super.key,
    required this.photographerModel,
  });

  @override
  State<PhotographerProfileScreen> createState() =>
      _PhotographerProfileScreenState();
}

class _PhotographerProfileScreenState extends State<PhotographerProfileScreen> {
  late PhotographerModel _photographer;

  @override
  void initState() {
    super.initState();
    _photographer = widget.photographerModel;
    _refreshPhotographerData();
  }

  Future<void> _refreshPhotographerData() async {
    final updated = await FirestoreService()
        .fetchPhotographer(_photographer.photographerId);
    if (updated != null && mounted) {
      setState(() => _photographer = updated);
    }
  }

  Future<void> _openReviewDialog({ReviewModel? existingReview}) async {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please log in to write or edit a review.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => SubmitReviewDialog(
        photographerId: _photographer.photographerId,
        userId: currentUser.uid,
        userName: currentUser.displayName ??
            currentUser.email?.split('@')[0] ??
            'Client',
        userProfileImage: currentUser.photoURL ?? '',
        existingReview: existingReview,
      ),
    );

    if (result == true) {
      _refreshPhotographerData();
    }
  }

  Future<void> _confirmDeleteReview(ReviewModel review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(AppConstants.cardColorValue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              const BorderSide(color: Color(AppConstants.surfaceBorderValue)),
        ),
        title: Text(
          'Delete Review?',
          style: GoogleFonts.playfairDisplay(
            color: const Color(AppConstants.textPrimaryValue),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your review? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(AppConstants.textSecondaryValue),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'CANCEL',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(AppConstants.textMutedValue),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'DELETE',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService().deleteReview(
          photographerId: _photographer.photographerId,
          reviewId: review.reviewId,
        );
        _refreshPhotographerData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Review deleted successfully.',
                style: GoogleFonts.plusJakartaSans(),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete review. Please try again.',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _photographer;
    final currentUser = AuthService().currentUser;

    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      body: CustomScrollView(
        slivers: [
          // ── Large cover image in sliver app bar with parallax gradient ───────
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: const Color(AppConstants.backgroundColorValue),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(AppConstants.backgroundColorValue)
                    .withValues(alpha: 0.75),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(AppConstants.surfaceBorderValue)),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Color(AppConstants.textPrimaryValue), size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'photographer_cover_${p.photographerId}',
                    child: AppNetworkImage(
                      imageUrl: p.coverPhotoUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.5),
                            const Color(AppConstants.backgroundColorValue),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PHOTOGRAPHER | MUMBAI, INDIA | ${p.specialty.toUpperCase()}',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(AppConstants.primaryColor),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(AppConstants.textPrimaryValue),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Profile details & Editorial Stats ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Starting Price Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Specialty: ${p.specialty}',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(AppConstants.textSecondaryValue),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'From ₹${p.startingPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(AppConstants.primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Experience / Rating Stats Bar ───────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.cardColorValue),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(AppConstants.surfaceBorderValue)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          p.averageRating > 0
                              ? '${p.averageRating.toStringAsFixed(1)} ★'
                              : 'NEW ★',
                          'RATING',
                        ),
                        Container(
                            width: 1,
                            height: 28,
                            color:
                                const Color(AppConstants.surfaceBorderValue)),
                        _buildStatItem('${p.reviewCount}', 'REVIEWS'),
                        Container(
                            width: 1,
                            height: 28,
                            color:
                                const Color(AppConstants.surfaceBorderValue)),
                        _buildStatItem('5+ YRS', 'EXPERIENCE'),
                      ],
                    ),
                  ),

                  // ── Bio Section ─────────────────────────────────────────
                  if (p.bio.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'BIOGRAPHY',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: const Color(AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.bio,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(AppConstants.textSecondaryValue),
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  // ── Packages Section ────────────────────────────────────
                  if (p.packages.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'EXPERIENCE PACKAGES',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: const Color(AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: p.packages.map((pkg) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(AppConstants.cardColorValue),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(
                                    AppConstants.surfaceBorderValue)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Color(AppConstants.primaryColor),
                                  size: 15),
                              const SizedBox(width: 6),
                              Text(
                                '$pkg Package',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(
                                      AppConstants.textPrimaryValue),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 28),
                  Text(
                    'PORTFOLIO / 2026',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 2.0,
                      color: const Color(AppConstants.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selected Works',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: const Color(AppConstants.textPrimaryValue),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Portfolio Grid ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            sliver: SliverToBoxAdapter(
              child: PortfolioGrid(imageUrls: p.portfolioImages),
            ),
          ),

          // ── RATING & REVIEWS SECTION ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              child: StreamBuilder<List<ReviewModel>>(
                stream: FirestoreService().reviewsStream(p.photographerId),
                builder: (context, snapshot) {
                  final reviews = snapshot.data ?? [];
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting;

                  ReviewModel? myReview;
                  if (currentUser != null) {
                    for (final r in reviews) {
                      if (r.userId == currentUser.uid) {
                        myReview = r;
                        break;
                      }
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header & Write/Edit Action Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CLIENT FEEDBACK',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 2.0,
                                  color: const Color(AppConstants.primaryColor),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rating & Reviews',
                                style: GoogleFonts.playfairDisplay(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color:
                                      const Color(AppConstants.textPrimaryValue),
                                ),
                              ),
                            ],
                          ),

                          // Write or Edit Review CTA
                          OutlinedButton.icon(
                            onPressed: () =>
                                _openReviewDialog(existingReview: myReview),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(AppConstants.primaryColor)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            icon: Icon(
                              myReview != null
                                  ? Icons.edit_rounded
                                  : Icons.star_border_rounded,
                              size: 16,
                              color: const Color(AppConstants.primaryColor),
                            ),
                            label: Text(
                              myReview != null
                                  ? 'Edit Review'
                                  : 'Write Review',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(AppConstants.primaryColor),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Rating Breakdown Summary Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.cardColorValue),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                                  const Color(AppConstants.surfaceBorderValue)),
                        ),
                        child: Row(
                          children: [
                            // Big Score Badge
                            Column(
                              children: [
                                Text(
                                  p.averageRating > 0
                                      ? p.averageRating.toStringAsFixed(1)
                                      : '0.0',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(
                                        AppConstants.textPrimaryValue),
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) {
                                    final starVal = index + 1;
                                    return Icon(
                                      starVal <= p.averageRating.round()
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: const Color(
                                          AppConstants.primaryColor),
                                      size: 14,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Based on ${reviews.length} reviews',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(
                                        AppConstants.textMutedValue),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Container(
                              width: 1,
                              height: 60,
                              color: const Color(
                                  AppConstants.surfaceBorderValue),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                myReview != null
                                    ? 'You have already reviewed this photographer. You can edit your review anytime.'
                                    : 'Share your experience to help others discover great photography talent.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(
                                      AppConstants.textSecondaryValue),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Reviews List / Loading / Empty State
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: LoadingWidget(
                              message: 'Loading client reviews...'),
                        )
                      else if (reviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(AppConstants.cardColorValue)
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(
                                    AppConstants.surfaceBorderValue)),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.rate_review_outlined,
                                color: Color(AppConstants.textMutedValue),
                                size: 36,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No reviews yet.',
                                style: GoogleFonts.playfairDisplay(
                                  color: const Color(
                                      AppConstants.textPrimaryValue),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Be the first to review this photographer.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(
                                      AppConstants.textMutedValue),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final rev = reviews[index];
                            final isOwner = currentUser != null &&
                                rev.userId == currentUser.uid;

                            return ReviewCard(
                              review: rev,
                              isOwner: isOwner,
                              onEdit: () =>
                                  _openReviewDialog(existingReview: rev),
                              onDelete: () => _confirmDeleteReview(rev),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // ── Sticky Book Session CTA Bar ──────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: const Color(AppConstants.backgroundColorValue)
              .withValues(alpha: 0.95),
          border: const Border(
              top: BorderSide(color: Color(AppConstants.surfaceBorderValue))),
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookingScreen(
                photographerId: p.photographerId,
                photographerName: p.name,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppConstants.textPrimaryValue),
            foregroundColor: const Color(AppConstants.backgroundColorValue),
            minimumSize: const Size.fromHeight(52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Book a Session',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(AppConstants.primaryColor),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(AppConstants.textMutedValue),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

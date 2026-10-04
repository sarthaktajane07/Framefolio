import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// Browse-screen photographer card with luxury editorial styling, vignette overlay, and metadata.
class PhotographerCard extends StatefulWidget {
  final String id;
  final Map<String, dynamic> photographer;
  final VoidCallback onTap;

  const PhotographerCard({
    super.key,
    required this.id,
    required this.photographer,
    required this.onTap,
  });

  @override
  State<PhotographerCard> createState() => _PhotographerCardState();
}

class _PhotographerCardState extends State<PhotographerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.photographer['name'] as String? ?? 'Unknown Photographer';
    final specialty = widget.photographer['specialty'] as String? ?? 'General';
    final price = widget.photographer['startingPrice'];
    final coverUrl = widget.photographer['coverPhotoUrl'] as String? ?? '';
    final avgRating = (widget.photographer['averageRating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = (widget.photographer['reviewCount'] as num?)?.toInt() ?? 0;
    final ratingText = avgRating > 0 ? '${avgRating.toStringAsFixed(1)} ★ ($reviewCount)' : 'NEW ★';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(AppConstants.cardColorValue),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? const Color(AppConstants.primaryColor)
                  : const Color(AppConstants.surfaceBorderValue),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.6 : 0.4),
                blurRadius: _isHovered ? 20 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover Photo Section (75-80% height focus) ─────────────
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover Image with Scale Animation
                    Hero(
                      tag: 'photographer_cover_${widget.id.isNotEmpty ? widget.id : widget.hashCode.toString()}',
                      child: AnimatedScale(
                        scale: _isHovered ? 1.04 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: _buildCoverImage(coverUrl),
                      ),
                    ),

                    // Dark Vignette Gradient Overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.2),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                            stops: const [0.3, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Top Left: Rating Badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.backgroundColorValue).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(AppConstants.surfaceBorderValue),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(AppConstants.primaryColor),
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              ratingText,
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(AppConstants.textPrimaryValue),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Right: Category Tag
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.cardColorValue).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(AppConstants.surfaceBorderValue),
                          ),
                        ),
                        child: Text(
                          specialty.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(AppConstants.primaryColor),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Editorial Metadata Footer ────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                color: const Color(AppConstants.cardColorValue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(AppConstants.textPrimaryValue),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$specialty Specialist'.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(AppConstants.textMutedValue),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            price != null ? 'Starting from ₹${price.toInt()}' : 'Price on request',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(AppConstants.textSecondaryValue),
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Portfolio',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(AppConstants.primaryColor),
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(AppConstants.primaryColor),
                              size: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: const Color(AppConstants.secondaryBgValue),
        child: const Center(
          child: Icon(
            Icons.camera_alt_outlined,
            color: Color(AppConstants.textMutedValue),
            size: 32,
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: const Color(AppConstants.secondaryBgValue),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(AppConstants.primaryColor),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(AppConstants.secondaryBgValue),
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 28),
          ),
        ),
      ),
    );
  }
}

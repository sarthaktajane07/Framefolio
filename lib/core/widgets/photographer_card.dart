import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Browse-screen photographer card. Shows cover photo, name, specialty and price.
class PhotographerCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final name = photographer['name'] as String? ?? 'Unknown Photographer';
    final specialty = photographer['specialty'] as String? ?? 'General';
    final price = photographer['startingPrice'];
    final coverUrl = photographer['coverPhotoUrl'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover photo — takes ~65% of card height
            Expanded(
              flex: 3,
              child: _buildCoverImage(coverUrl),
            ),

            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Photographer name
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Specialty
                    Text(
                      specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Starting price
                    Text(
                      price != null ? 'From ₹$price' : 'Price on request',
                      style: const TextStyle(
                        color: Color(0xFFA67C52),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: const Color(0xFFF0EBE3),
        child: const Center(
          child: Icon(Icons.camera_alt_outlined, color: Color(0xFFA67C52), size: 36),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFFF0EBE3),
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 28),
        ),
      ),
    );
  }
}

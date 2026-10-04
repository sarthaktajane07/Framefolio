import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/review_model.dart';

/// Clean Material 3 card widget for individual photographer reviews.
class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = review.createdAt != null
        ? DateFormat('MMM dd, yyyy').format(review.createdAt!)
        : 'Recent';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppConstants.cardColorValue),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOwner
              ? const Color(AppConstants.primaryColor).withValues(alpha: 0.5)
              : const Color(AppConstants.surfaceBorderValue),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar, Name, Rating & Action Icons
          Row(
            children: [
              // User Avatar Circle
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(AppConstants.secondaryBgValue),
                backgroundImage: review.userProfileImage.isNotEmpty
                    ? NetworkImage(review.userProfileImage)
                    : null,
                child: review.userProfileImage.isEmpty
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : 'C',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(AppConstants.primaryColor),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // User Name & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.userName,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(AppConstants.textPrimaryValue),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(AppConstants.primaryColor)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'YOU',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(AppConstants.primaryColor),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(AppConstants.textMutedValue),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Star Rating Display
              Row(
                children: List.generate(5, (index) {
                  final starVal = index + 1;
                  return Icon(
                    starVal <= review.rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(AppConstants.primaryColor),
                    size: 16,
                  );
                }),
              ),

              // Owner Edit / Delete Actions
              if (isOwner) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(AppConstants.textSecondaryValue),
                    size: 18,
                  ),
                  color: const Color(AppConstants.secondaryBgValue),
                  onSelected: (val) {
                    if (val == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (val == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined,
                              size: 16, color: Color(AppConstants.primaryColor)),
                          const SizedBox(width: 8),
                          Text(
                            'Edit Review',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(AppConstants.textPrimaryValue),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded,
                              size: 16, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Text(
                            'Delete Review',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),
          // Review Text Content
          Text(
            review.reviewText,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(AppConstants.textSecondaryValue),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/review_model.dart';
import '../../../services/firestore_service.dart';

/// Interactive dialog for submitting or editing a photographer review.
class SubmitReviewDialog extends StatefulWidget {
  final String photographerId;
  final String userId;
  final String userName;
  final String userProfileImage;
  final ReviewModel? existingReview;

  const SubmitReviewDialog({
    super.key,
    required this.photographerId,
    required this.userId,
    required this.userName,
    this.userProfileImage = '',
    this.existingReview,
  });

  @override
  State<SubmitReviewDialog> createState() => _SubmitReviewDialogState();
}

class _SubmitReviewDialogState extends State<SubmitReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  late double _rating;
  late TextEditingController _textController;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 5.0;
    _textController = TextEditingController(
      text: widget.existingReview?.reviewText ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating < 1.0) {
      setState(() => _errorMessage = 'Please select a star rating (1 to 5).');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final review = ReviewModel(
        reviewId: widget.existingReview?.reviewId ?? '',
        photographerId: widget.photographerId,
        userId: widget.userId,
        userName: widget.userName.isNotEmpty ? widget.userName : 'Client',
        userProfileImage: widget.userProfileImage,
        rating: _rating,
        reviewText: _textController.text.trim(),
        createdAt: widget.existingReview?.createdAt,
      );

      await FirestoreService().saveOrUpdateReview(review);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingReview != null
                  ? 'Your review has been updated!'
                  : 'Thank you! Your review has been published.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(AppConstants.primaryColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Failed to save review. Please check your internet connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;

    return Dialog(
      backgroundColor: const Color(AppConstants.cardColorValue),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(AppConstants.surfaceBorderValue)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Your Review' : 'Write a Review',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(AppConstants.textPrimaryValue),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Color(AppConstants.textMutedValue), size: 20),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Star Rating Selector
                Text(
                  'YOUR RATING',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: const Color(AppConstants.primaryColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1.0;
                    return IconButton(
                      iconSize: 32,
                      icon: Icon(
                        starValue <= _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(AppConstants.primaryColor),
                      ),
                      onPressed: () {
                        setState(() => _rating = starValue);
                      },
                    );
                  }),
                ),
                Center(
                  child: Text(
                    '${_rating.toInt()} of 5 Stars',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(AppConstants.textSecondaryValue),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Review Text Input
                Text(
                  'YOUR REVIEW',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: const Color(AppConstants.primaryColor),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _textController,
                  maxLines: 4,
                  maxLength: 500,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(AppConstants.textPrimaryValue),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Share your experience working with this photographer...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: const Color(AppConstants.textMutedValue),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(AppConstants.secondaryBgValue),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(AppConstants.surfaceBorderValue)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(AppConstants.surfaceBorderValue)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(AppConstants.primaryColor)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your review text.';
                    }
                    if (value.trim().length < 5) {
                      return 'Review must be at least 5 characters long.';
                    }
                    return null;
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Submit Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(AppConstants.textPrimaryValue),
                      foregroundColor:
                          const Color(AppConstants.backgroundColorValue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(AppConstants.backgroundColorValue),
                            ),
                          )
                        : Text(
                            isEditing ? 'Update Review' : 'Submit Review',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

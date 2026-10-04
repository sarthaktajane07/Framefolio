import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a client review for a photographer stored in `photographers/{photographerId}/reviews/{reviewId}`.
class ReviewModel {
  final String reviewId;
  final String photographerId;
  final String userId;
  final String userName;
  final String userProfileImage;
  final double rating;
  final String reviewText;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.reviewId,
    required this.photographerId,
    required this.userId,
    required this.userName,
    this.userProfileImage = '',
    required this.rating,
    required this.reviewText,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() => {
        'reviewId': reviewId,
        'photographerId': photographerId,
        'userId': userId,
        'userName': userName,
        'userProfileImage': userProfileImage,
        'rating': rating,
        'reviewText': reviewText,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel(
      reviewId: doc.id,
      photographerId: data['photographerId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous Client',
      userProfileImage: data['userProfileImage'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      reviewText: data['reviewText'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'reviewId': reviewId,
        'photographerId': photographerId,
        'userId': userId,
        'userName': userName,
        'userProfileImage': userProfileImage,
        'rating': rating,
        'reviewText': reviewText,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a photographer's portfolio stored in Firestore `photographers` collection.
class PhotographerModel {
  final String photographerId;
  final String name;
  final String specialty;
  final String coverPhotoUrl;
  final double startingPrice;
  final String bio;
  final List<String> portfolioImages;
  final List<String> packages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PhotographerModel({
    required this.photographerId,
    required this.name,
    required this.specialty,
    required this.coverPhotoUrl,
    required this.startingPrice,
    required this.bio,
    required this.portfolioImages,
    required this.packages,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() => {
        'photographerId': photographerId,
        'name': name,
        'specialty': specialty,
        'coverPhotoUrl': coverPhotoUrl,
        'startingPrice': startingPrice,
        'bio': bio,
        'portfolioImages': portfolioImages,
        'packages': packages,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory PhotographerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotographerModel(
      photographerId: doc.id,
      name: data['name'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      coverPhotoUrl: data['coverPhotoUrl'] as String? ?? '',
      startingPrice: (data['startingPrice'] as num?)?.toDouble() ?? 0.0,
      bio: data['bio'] as String? ?? '',
      portfolioImages: List<String>.from(data['portfolioImages'] ?? []),
      packages: List<String>.from(data['packages'] ?? ['Basic', 'Standard', 'Premium']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to plain Map for passing between screens (avoids Firestore import in UI).
  Map<String, dynamic> toMap() => {
        'photographerId': photographerId,
        'name': name,
        'specialty': specialty,
        'coverPhotoUrl': coverPhotoUrl,
        'startingPrice': startingPrice,
        'bio': bio,
        'portfolioImages': portfolioImages,
        'packages': packages,
      };
}

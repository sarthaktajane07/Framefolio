import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

/// Seeds Firestore with 6 demo photographer portfolios for client preview.
/// Uses real high-res photography images — no upload needed.
class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const List<Map<String, dynamic>> _demoPhotographers = [
    {
      'photographerId': 'demo_aarav',
      'name': 'Aarav Photography',
      'specialty': 'Wedding',
      'startingPrice': 15000.0,
      'rating': 4.9,
      'bio':
          'Capturing timeless wedding moments for over 8 years. '
          'I believe every wedding tells a unique story, '
          'and my job is to preserve it beautifully forever.',
      'coverPhotoUrl': 'https://picsum.photos/id/1059/800/600',
      'portfolioImages': [
        'https://picsum.photos/id/1059/600/600',
        'https://picsum.photos/id/1062/600/600',
        'https://picsum.photos/id/1025/600/600',
        'https://picsum.photos/id/1069/600/600',
        'https://picsum.photos/id/1084/600/600',
        'https://picsum.photos/id/1015/600/600',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
    {
      'photographerId': 'demo_meera',
      'name': 'Meera Studios',
      'specialty': 'Portrait',
      'startingPrice': 8000.0,
      'rating': 4.8,
      'bio':
          'Specialising in natural-light portrait photography. '
          'I work closely with each subject to bring out their '
          'authentic personality in every frame.',
      'coverPhotoUrl': 'https://picsum.photos/id/1025/800/600',
      'portfolioImages': [
        'https://picsum.photos/id/1025/600/600',
        'https://picsum.photos/id/1062/600/600',
        'https://picsum.photos/id/1005/600/600',
        'https://picsum.photos/id/1011/600/600',
        'https://picsum.photos/id/1027/600/600',
        'https://picsum.photos/id/1069/600/600',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
    {
      'photographerId': 'demo_lenscraft',
      'name': 'LensCraft Studio',
      'specialty': 'Fashion',
      'startingPrice': 12000.0,
      'rating': 4.95,
      'bio':
          'High-fashion and editorial photography for brands, '
          'magazines, and independent artists. '
          'My work has been featured in Vogue India and Elle.',
      'coverPhotoUrl': 'https://picsum.photos/id/1062/800/600',
      'portfolioImages': [
        'https://picsum.photos/id/1062/600/600',
        'https://picsum.photos/id/1025/600/600',
        'https://picsum.photos/id/1005/600/600',
        'https://picsum.photos/id/1059/600/600',
        'https://picsum.photos/id/1069/600/600',
        'https://picsum.photos/id/1084/600/600',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
    {
      'photographerId': 'demo_riya',
      'name': 'Riya Kapoor Clicks',
      'specialty': 'Pre-Wedding',
      'startingPrice': 18000.0,
      'rating': 4.85,
      'bio':
          'Creating magical pre-wedding stories in the most '
          'breathtaking locations across India. '
          'Let us turn your love story into a visual poem.',
      'coverPhotoUrl': 'https://picsum.photos/id/1084/800/600',
      'portfolioImages': [
        'https://picsum.photos/id/1084/600/600',
        'https://picsum.photos/id/1059/600/600',
        'https://picsum.photos/id/1015/600/600',
        'https://picsum.photos/id/1062/600/600',
        'https://picsum.photos/id/1025/600/600',
        'https://picsum.photos/id/1069/600/600',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
    {
      'photographerId': 'demo_vikram',
      'name': 'Vikram Events',
      'specialty': 'Event',
      'startingPrice': 10000.0,
      'rating': 4.75,
      'bio':
          'Covering corporate events, birthday parties, concerts, '
          'and cultural festivals with sharp detail and vibrant energy. '
          'Every event deserves to be remembered vividly.',
      'coverPhotoUrl': 'https://picsum.photos/id/1069/800/600',
      'portfolioImages': [
        'https://picsum.photos/id/1069/600/600',
        'https://picsum.photos/id/1059/600/600',
        'https://picsum.photos/id/1062/600/600',
        'https://picsum.photos/id/1015/600/600',
        'https://picsum.photos/id/1084/600/600',
        'https://picsum.photos/id/1025/600/600',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
    {
      'photographerId': 'demo_priya',
      'name': 'Priya Lens Art',
      'specialty': 'Portrait',
      'startingPrice': 6500.0,
      'rating': 4.9,
      'bio':
          'Affordable, warm, and artistic portrait sessions for '
          'individuals and families. '
          'Specialising in newborn, maternity, and family portraits '
          'in studio and outdoor settings.',
      'coverPhotoUrl': 'https://picsum.photos/id/1005/800/600',
      'portfolioImages': [
        'https://picsum.photos/id/1005/600/600',
        'https://picsum.photos/id/1025/600/600',
        'https://picsum.photos/id/1062/600/600',
        'https://picsum.photos/id/1059/600/600',
        'https://picsum.photos/id/1069/600/600',
        'https://picsum.photos/id/1084/600/600',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
  ];

  Future<void> seedDemoData() async {
    final batch = _db.batch();

    for (final data in _demoPhotographers) {
      final id = data['photographerId'] as String;
      final ref = _db.collection(AppConstants.photographersCollection).doc(id);
      batch.set(ref, {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<bool> isDemoSeeded() async {
    final doc = await _db
        .collection(AppConstants.photographersCollection)
        .doc('demo_aarav')
        .get();
    return doc.exists;
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

/// Seeds Firestore with 6 demo photographer portfolios for client preview.
/// Uses real Unsplash photography images — no upload needed.
/// Call [seedDemoData] once from the Browse screen's empty state.
class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Demo photographer data ──────────────────────────────────────────────────
  static const List<Map<String, dynamic>> _demoPhotographers = [
    {
      'photographerId': 'demo_aarav',
      'name': 'Aarav Photography',
      'specialty': 'Wedding',
      'startingPrice': 15000.0,
      'bio':
          'Capturing timeless wedding moments for over 8 years. '
          'I believe every wedding tells a unique story, '
          'and my job is to preserve it beautifully forever.',
      'coverPhotoUrl':
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
      'portfolioImages': [
        'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=600&q=75',
        'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=600&q=75',
        'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=600&q=75',
        'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=600&q=75',
        'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=600&q=75',
        'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=600&q=75',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
    {
      'photographerId': 'demo_meera',
      'name': 'Meera Studios',
      'specialty': 'Portrait',
      'startingPrice': 8000.0,
      'bio':
          'Specialising in natural-light portrait photography. '
          'I work closely with each subject to bring out their '
          'authentic personality in every frame.',
      'coverPhotoUrl':
          'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800&q=80',
      'portfolioImages': [
        'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=600&q=75',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&q=75',
        'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=600&q=75',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&q=75',
        'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=600&q=75',
        'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=600&q=75',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
    {
      'photographerId': 'demo_lenscraft',
      'name': 'LensCraft',
      'specialty': 'Fashion',
      'startingPrice': 12000.0,
      'bio':
          'High-fashion and editorial photography for brands, '
          'magazines, and independent artists. '
          'My work has been featured in Vogue India and Elle.',
      'coverPhotoUrl':
          'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800&q=80',
      'portfolioImages': [
        'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=600&q=75',
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=75',
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600&q=75',
        'https://images.unsplash.com/photo-1492707892479-7bc8d5a4ee93?w=600&q=75',
        'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600&q=75',
        'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=600&q=75',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
    {
      'photographerId': 'demo_riya',
      'name': 'Riya Kapoor Clicks',
      'specialty': 'Pre-Wedding',
      'startingPrice': 18000.0,
      'bio':
          'Creating magical pre-wedding stories in the most '
          'breathtaking locations across India. '
          'Let us turn your love story into a visual poem.',
      'coverPhotoUrl':
          'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=800&q=80',
      'portfolioImages': [
        'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=600&q=75',
        'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=600&q=75',
        'https://images.unsplash.com/photo-1523438885200-e635ba2c371e?w=600&q=75',
        'https://images.unsplash.com/photo-1502877338535-766e1452684a?w=600&q=75',
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=600&q=75',
        'https://images.unsplash.com/photo-1529636798458-92182e662485?w=600&q=75',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
    {
      'photographerId': 'demo_vikram',
      'name': 'Vikram Events',
      'specialty': 'Event',
      'startingPrice': 10000.0,
      'bio':
          'Covering corporate events, birthday parties, concerts, '
          'and cultural festivals with sharp detail and vibrant energy. '
          'Every event deserves to be remembered vividly.',
      'coverPhotoUrl':
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=80',
      'portfolioImages': [
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=600&q=75',
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&q=75',
        'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=600&q=75',
        'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=600&q=75',
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&q=75',
        'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=600&q=75',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
    {
      'photographerId': 'demo_priya',
      'name': 'Priya Lens Art',
      'specialty': 'Portrait',
      'startingPrice': 6500.0,
      'bio':
          'Affordable, warm, and artistic portrait sessions for '
          'individuals and families. '
          'Specialising in newborn, maternity, and family portraits '
          'in studio and outdoor settings.',
      'coverPhotoUrl':
          'https://images.unsplash.com/photo-1554151228-14d9def656e4?w=800&q=80',
      'portfolioImages': [
        'https://images.unsplash.com/photo-1554151228-14d9def656e4?w=600&q=75',
        'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=600&q=75',
        'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=600&q=75',
        'https://images.unsplash.com/photo-1548544149-4835e62ee5b3?w=600&q=75',
        'https://images.unsplash.com/photo-1502980426475-b83966705988?w=600&q=75',
        'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=600&q=75',
      ],
      'packages': ['Basic', 'Standard', 'Premium'],
    },
  ];

  /// Writes all demo photographers to Firestore.
  /// Safe to call multiple times — uses [set] with the fixed demo ID.
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

  /// Returns true if any demo document already exists in Firestore.
  Future<bool> isDemoSeeded() async {
    final doc = await _db
        .collection(AppConstants.photographersCollection)
        .doc('demo_aarav')
        .get();
    return doc.exists;
  }
}

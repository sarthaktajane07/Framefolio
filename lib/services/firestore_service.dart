import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photographer_model.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';
import '../core/constants/app_constants.dart';

/// Handles all Firestore read/write operations for FrameFolio.
/// Performs filtering and sorting client-side to avoid any Firestore index requirements.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ────────────────────────────── PHOTOGRAPHERS ──────────────────────────────

  /// Real-time stream of all photographers (used in BrowseScreen).
  Stream<List<PhotographerModel>> photographersStream() {
    return _db
        .collection(AppConstants.photographersCollection)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PhotographerModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) {
        final d1 = a.createdAt ?? DateTime(2020);
        final d2 = b.createdAt ?? DateTime(2020);
        return d2.compareTo(d1);
      });
      return list;
    });
  }

  /// Save / overwrite a photographer's portfolio document.
  Future<void> savePhotographer(PhotographerModel model) async {
    await _db
        .collection(AppConstants.photographersCollection)
        .doc(model.photographerId)
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  /// Fetch one photographer by Firestore document ID.
  Future<PhotographerModel?> fetchPhotographer(String id) async {
    final doc = await _db
        .collection(AppConstants.photographersCollection)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return PhotographerModel.fromFirestore(doc);
  }

  // ────────────────────────────── REVIEWS ───────────────────────────────────

  /// Real-time stream of reviews for a given photographer ID.
  Stream<List<ReviewModel>> reviewsStream(String photographerId) {
    return _db
        .collection(AppConstants.photographersCollection)
        .doc(photographerId)
        .collection(AppConstants.reviewsCollection)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) {
        final d1 = a.createdAt ?? DateTime(2020);
        final d2 = b.createdAt ?? DateTime(2020);
        return d2.compareTo(d1);
      });
      return list;
    });
  }

  /// Check if a given user already submitted a review for a photographer.
  Future<ReviewModel?> fetchUserReview(String photographerId, String userId) async {
    if (userId.isEmpty) return null;
    final query = await _db
        .collection(AppConstants.photographersCollection)
        .doc(photographerId)
        .collection(AppConstants.reviewsCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return ReviewModel.fromFirestore(query.docs.first);
  }

  /// Save or update a review document and recalculate photographer's average rating.
  Future<void> saveOrUpdateReview(ReviewModel review) async {
    final reviewRef = _db
        .collection(AppConstants.photographersCollection)
        .doc(review.photographerId)
        .collection(AppConstants.reviewsCollection)
        .doc(review.reviewId.isNotEmpty ? review.reviewId : null);

    final finalReview = ReviewModel(
      reviewId: reviewRef.id,
      photographerId: review.photographerId,
      userId: review.userId,
      userName: review.userName,
      userProfileImage: review.userProfileImage,
      rating: review.rating,
      reviewText: review.reviewText,
      createdAt: review.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await reviewRef.set(finalReview.toFirestore(), SetOptions(merge: true));

    // Recalculate photographer rating & review count
    await _recalculatePhotographerRating(review.photographerId);
  }

  /// Delete a review document and recalculate photographer's average rating.
  Future<void> deleteReview({
    required String photographerId,
    required String reviewId,
  }) async {
    await _db
        .collection(AppConstants.photographersCollection)
        .doc(photographerId)
        .collection(AppConstants.reviewsCollection)
        .doc(reviewId)
        .delete();

    await _recalculatePhotographerRating(photographerId);
  }

  /// Recalculates average rating and total review count for a photographer.
  Future<void> _recalculatePhotographerRating(String photographerId) async {
    final reviewsSnap = await _db
        .collection(AppConstants.photographersCollection)
        .doc(photographerId)
        .collection(AppConstants.reviewsCollection)
        .get();

    if (reviewsSnap.docs.isEmpty) {
      await _db
          .collection(AppConstants.photographersCollection)
          .doc(photographerId)
          .set({
        'averageRating': 0.0,
        'reviewCount': 0,
      }, SetOptions(merge: true));
      return;
    }

    double totalRating = 0.0;
    for (final doc in reviewsSnap.docs) {
      final r = (doc.data()['rating'] as num?)?.toDouble() ?? 5.0;
      totalRating += r;
    }

    final count = reviewsSnap.docs.length;
    final avg = (totalRating / count);

    await _db
        .collection(AppConstants.photographersCollection)
        .doc(photographerId)
        .set({
      'averageRating': double.parse(avg.toStringAsFixed(1)),
      'reviewCount': count,
    }, SetOptions(merge: true));
  }

  // ────────────────────────────── BOOKINGS ───────────────────────────────────

  /// Write a booking document to Firestore and return the generated ID.
  Future<String> saveBooking(BookingModel booking) async {
    final docRef = _db.collection(AppConstants.bookingsCollection).doc();
    final withId = BookingModel(
      bookingId: docRef.id,
      clientId: booking.clientId,
      photographerId: booking.photographerId,
      photographerName: booking.photographerName,
      clientName: booking.clientName,
      clientEmail: booking.clientEmail,
      clientPhone: booking.clientPhone,
      packageName: booking.packageName,
      bookingDate: booking.bookingDate,
      timeSlot: booking.timeSlot,
      message: booking.message,
      status: 'pending',
    );
    await docRef.set(withId.toFirestore());
    return docRef.id;
  }

  /// Real-time stream of all bookings (raw collection snapshot, client-side sorted).
  Stream<List<BookingModel>> bookingsStream() {
    return _db
        .collection(AppConstants.bookingsCollection)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
      list.sort((a, b) {
        final d1 = a.createdAt ?? DateTime(2020);
        final d2 = b.createdAt ?? DateTime(2020);
        return d2.compareTo(d1);
      });
      return list;
    });
  }

  /// Real-time stream of bookings for a given client user ID (100% index-free).
  Stream<List<BookingModel>> clientBookingsStream(String clientId) {
    return bookingsStream().map((list) {
      if (clientId.isEmpty) return list;
      return list.where((b) => b.clientId == clientId).toList();
    });
  }

  /// Real-time stream of bookings for a given photographer user ID (100% index-free).
  Stream<List<BookingModel>> photographerBookingsStream(String photographerId) {
    return bookingsStream().map((list) {
      if (photographerId.isEmpty) return list;
      return list.where((b) => b.photographerId == photographerId).toList();
    });
  }

  /// Update status of a booking document (e.g. pending -> confirmed, cancelled, completed).
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await _db
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

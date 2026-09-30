import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photographer_model.dart';
import '../models/booking_model.dart';
import '../core/constants/app_constants.dart';

/// Handles all Firestore read/write operations for FrameFolio.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ────────────────────────────── PHOTOGRAPHERS ──────────────────────────────

  /// Real-time stream of all photographers (used in BrowseScreen).
  Stream<List<PhotographerModel>> photographersStream() {
    return _db
        .collection(AppConstants.photographersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PhotographerModel.fromFirestore(doc))
            .toList());
  }

  /// Save / overwrite a photographer's portfolio document.
  Future<void> savePhotographer(PhotographerModel model) async {
    await _db
        .collection(AppConstants.photographersCollection)
        .doc(model.photographerId)
        .set(model.toFirestore());
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

  /// Real-time stream of bookings for a given client user ID.
  Stream<List<BookingModel>> clientBookingsStream(String clientId) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
  }
}

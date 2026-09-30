import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a session booking stored in Firestore `bookings` collection.
class BookingModel {
  final String bookingId;
  final String clientId;
  final String photographerId;
  final String photographerName;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String packageName;
  final String bookingDate; // ISO yyyy-MM-dd
  final String timeSlot;
  final String message;
  final String status; // 'pending' | 'confirmed' | 'cancelled'
  final DateTime? createdAt;

  const BookingModel({
    required this.bookingId,
    required this.clientId,
    required this.photographerId,
    required this.photographerName,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.packageName,
    required this.bookingDate,
    required this.timeSlot,
    required this.message,
    this.status = 'pending',
    this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
        'bookingId': bookingId,
        'clientId': clientId,
        'photographerId': photographerId,
        'photographerName': photographerName,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'clientPhone': clientPhone,
        'packageName': packageName,
        'bookingDate': bookingDate,
        'timeSlot': timeSlot,
        'message': message,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: data['bookingId'] as String? ?? doc.id,
      clientId: data['clientId'] as String? ?? '',
      photographerId: data['photographerId'] as String? ?? '',
      photographerName: data['photographerName'] as String? ?? '',
      clientName: data['clientName'] as String? ?? '',
      clientEmail: data['clientEmail'] as String? ?? '',
      clientPhone: data['clientPhone'] as String? ?? '',
      packageName: data['packageName'] as String? ?? '',
      bookingDate: data['bookingDate'] as String? ?? '',
      timeSlot: data['timeSlot'] as String? ?? '',
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

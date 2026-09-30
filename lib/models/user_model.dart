import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a FrameFolio user stored in Firestore `users` collection.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'photographer' | 'client'
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  bool get isPhotographer => role == 'photographer';
  bool get isClient => role == 'client';

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'client',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

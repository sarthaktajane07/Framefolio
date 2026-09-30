/// App-wide constants for FrameFolio
class AppConstants {
  // App name
  static const String appName = 'FrameFolio';

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String photographersCollection = 'photographers';
  static const String bookingsCollection = 'bookings';

  // Cloudinary (free image hosting – no Firebase Storage billing required)
  static const String cloudinaryCloudName = 'vuuwn7i2';
  static const String cloudinaryUploadPreset = 'framefolio_preset';

  // User roles
  static const String rolePhotographer = 'photographer';
  static const String roleClient = 'client';

  // Photography specialties
  static const List<String> specialties = [
    'Wedding',
    'Portrait',
    'Fashion',
    'Event',
    'Pre-Wedding',
  ];

  // Photography packages
  static const List<String> packages = ['Basic', 'Standard', 'Premium'];

  // Available time slots for booking
  static const List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
  ];

  // Theme colours
  static const int primaryColor = 0xFF222222;
  static const int accentColor = 0xFFA67C52;
  static const int backgroundColorValue = 0xFFF7F5F0;
  static const int cardColorValue = 0xFFFFFFFF;
}

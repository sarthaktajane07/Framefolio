/// Centralized constants for FrameFolio — Cinematic Editorial Photography System
class AppConstants {
  // App name & tagline
  static const String appName = 'FrameFolio';
  static const String appTagline = 'Capture Moments. Create Memories.';

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String photographersCollection = 'photographers';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';

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
    'Events',
    'Travel',
    'Pre-Wedding',
    'Product',
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

  // ── Cinematic Editorial Monochromatic Color System ─────────────────────────
  static const int backgroundColorValue = 0xFF0B0C0D; // Main Scaffold Near-Black
  static const int secondaryBgValue = 0xFF121315;     // Secondary Dark Surface
  static const int cardColorValue = 0xFF17191B;       // Card Fill
  static const int cardElevatedValue = 0xFF1D1F21;    // Elevated Cards / Floating
  static const int textPrimaryValue = 0xFFF5F3EE;     // Warm Off-White Text
  static const int textSecondaryValue = 0xFFA5A29B;   // Secondary Label Text
  static const int textMutedValue = 0xFF77746E;       // Muted Text
  static const int surfaceBorderValue = 0xFF303133;   // Subtle Grey Borders
  static const int primaryColor = 0xFFC8A97E;         // Warm Champagne Accent
  static const int accentColor = 0xFFD8B98E;          // Light Warm Champagne
}

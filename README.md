# 📸 FrameFolio — Photography Portfolio & Booking App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Cloudinary-Image%20Storage-3448C5?logo=cloudinary&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS-informational" />
  <img src="https://img.shields.io/badge/Material%203-Design%20System-blueviolet" />
</p>

> A cross-platform Flutter application where photographers showcase their portfolios and clients book photography sessions — all backed by the cloud.

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Problem Statement](#-problem-statement)
- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [App Architecture](#-app-architecture)
- [File Structure](#-file-structure)
- [Dart Files Explained](#-dart-files-explained)
- [App Flow](#-app-flow)
- [Screenshots](#-screenshots)
- [Setup & Installation](#-setup--installation)
- [Firebase Configuration](#-firebase-configuration)
- [Cloudinary Configuration](#-cloudinary-configuration)
- [Demo Data](#-demo-data)
- [Academic Details](#-academic-details)

---

## 🎯 Project Overview

**FrameFolio** is a full-stack cross-platform application built with Flutter and Firebase. It connects two types of users:

| User Type | What they can do |
|-----------|-----------------|
| **Photographer** | Register, create profile, upload cover photo & portfolio images, manage their dashboard |
| **Client** | Browse photographers, filter by specialty, view portfolios, and book photography sessions |

---

## 📌 Problem Statement

> *FrameFolio wants an app where a photographer showcases a portfolio of shoots with high-quality images, and clients browse portfolios by category and book a session slot, all backed by the cloud.*

**B.Tech Computer Science Engineering & AI — Cross Platform Application (Problem #48)**

### Objectives
- **UI/Widgets**: Portfolio Upload, Browse Photographers, and Session Booking screens using `GridView`, `Image`, and `Form` widgets.
- **Styling/Theming**: Minimal, image-forward Material 3 theme that lets photography stand out.
- **Dart Logic**: Use `async/await` while uploading portfolio images and writing session bookings to the cloud.
- **Figma**: Design a clean, guided flow covering every screen with progress cues.

### Outcomes
- Photographers log in with Firebase Authentication before uploading a portfolio.
- Portfolio images are stored in Cloudinary (cloud image hosting).
- Clients browse and filter photographers by specialty category.
- Session bookings are saved to Cloud Firestore in real time.

---

## ✨ Key Features

### Photographer Side
- 🔐 **Role-based Authentication** — Register as Photographer or Client
- 🖼️ **Cover Photo Upload** — Upload a profile cover photo via Cloudinary
- 📷 **Portfolio Management** — Upload multiple portfolio images, displayed in a `GridView`
- ✏️ **Profile Editing** — Set bio, specialty, and starting price
- 📊 **Dashboard** — View full profile and current portfolio

### Client Side
- 🔍 **Browse Photographers** — Scrollable `GridView` of photographer cards
- 🏷️ **Specialty Filter** — Filter chips: All / Wedding / Portrait / Event / Fashion / Landscape
- 👁️ **Portfolio View** — Full profile screen with cover hero image and gallery grid
- 📅 **Session Booking** — Pick package (Basic/Standard/Premium), date, and time slot
- ✅ **Booking Confirmation** — Clean summary screen with all booking details

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **UI Framework** | Flutter 3.x + Dart | Cross-platform app (Web, Android, iOS) |
| **Design System** | Material 3 | Modern, accessible UI theming |
| **Authentication** | Firebase Authentication | Email/Password sign-in with role assignment |
| **Database** | Cloud Firestore | Real-time NoSQL document storage for profiles & bookings |
| **Image Storage** | Cloudinary | Cloud-based image upload & delivery (avoids Firebase Storage billing) |
| **State Management** | `StatefulWidget` + `StreamBuilder` / `FutureBuilder` | Built-in Flutter reactive patterns |
| **Image Loading** | `cached_network_image` | Efficient network image caching with placeholders |
| **Image Picking** | `image_picker` | Camera/Gallery access for uploads |

---

## 🏗️ App Architecture

The app follows a **clean, feature-based architecture** for maintainability and readability:

```
lib/
├── main.dart                   # App entry point, Firebase init
├── app.dart                    # Root widget, AuthGate, routing logic
├── firebase_options.dart       # Auto-generated Firebase config
│
├── core/                       # Shared, reusable building blocks
│   ├── constants/
│   │   └── app_constants.dart  # Global constants, categories
│   ├── theme/
│   │   └── app_theme.dart      # Material 3 theme configuration
│   └── widgets/
│       ├── loading_widget.dart     # Reusable loading indicator
│       ├── photographer_card.dart  # Browse screen card widget
│       └── portfolio_grid.dart     # Image grid with lightbox
│
├── models/                     # Plain Dart data classes (no logic)
│   ├── user_model.dart         # AppUser: uid, email, name, role
│   ├── photographer_model.dart # PhotographerProfile data
│   └── booking_model.dart      # BookingModel: session details
│
├── services/                   # All backend/cloud interactions
│   ├── auth_service.dart       # Firebase Auth + user profile management
│   ├── firestore_service.dart  # Firestore CRUD operations
│   ├── storage_service.dart    # Cloudinary image upload
│   └── seed_service.dart       # Demo data seeder (6 photographers)
│
└── features/                   # Individual app screens, grouped by feature
    ├── auth/
    │   └── login_screen.dart         # Login & Registration screen
    ├── home/
    │   └── home_screen.dart          # Role-based home/navigation shell
    ├── browse/
    │   ├── browse_screen.dart              # Client browse + filter
    │   └── photographer_profile_screen.dart # Photographer detail view
    ├── booking/
    │   ├── booking_screen.dart             # Session booking form
    │   └── booking_confirmation_screen.dart # Booking success screen
    └── portfolio/
        └── portfolio_upload_screen.dart    # Photographer dashboard & upload
```

---

## 📄 Dart Files Explained

### Entry & App Root

| File | Role |
|------|------|
| `main.dart` | App entry point. Initializes Firebase then runs `FrameFolioApp` |
| `app.dart` | Root `MaterialApp`. `_AuthGate` listens to Firebase auth stream and routes to Login or Home |
| `firebase_options.dart` | Firebase platform configuration (auto-generated by FlutterFire CLI) |

### Core Layer

| File | Role |
|------|------|
| `core/constants/app_constants.dart` | App name, specialty list, fallback image URLs |
| `core/theme/app_theme.dart` | Material 3 `ThemeData`: Cream `#F7F5F0`, Charcoal `#222222`, Bronze `#A67C52` |
| `core/widgets/photographer_card.dart` | Card widget showing cover photo, name, specialty, and price |
| `core/widgets/portfolio_grid.dart` | Responsive `GridView` of portfolio images with tap-to-expand lightbox |
| `core/widgets/loading_widget.dart` | Centered `CircularProgressIndicator` wrapper |

### Models

| File | Role |
|------|------|
| `models/user_model.dart` | Dart class for app user with `fromMap()` / `toMap()` for Firestore |
| `models/photographer_model.dart` | Dart class for photographer profile data |
| `models/booking_model.dart` | Dart class for session booking (package, date, time, price, status) |

### Services

| File | Role |
|------|------|
| `services/auth_service.dart` | Firebase Auth: signIn, signUp, fetchProfile, signOut |
| `services/firestore_service.dart` | Firestore: fetch photographers (with filter), save bookings, update profiles |
| `services/storage_service.dart` | Cloudinary REST API: upload image bytes, return secure URL |
| `services/seed_service.dart` | Inserts 6 demo photographer profiles into Firestore for presentation |

### Feature Screens

| File | Role | Used By |
|------|------|---------|
| `features/auth/login_screen.dart` | Email/password login & registration, role selection | `app.dart` → `_AuthGate` |
| `features/home/home_screen.dart` | Post-login shell: shows Browse (client) or Dashboard (photographer) | `app.dart` |
| `features/browse/browse_screen.dart` | GridView of photographers + specialty filter chips | `home_screen.dart` |
| `features/browse/photographer_profile_screen.dart` | Full photographer profile with hero image & gallery | `browse_screen.dart` on card tap |
| `features/booking/booking_screen.dart` | Package + date + time + notes form for booking | `photographer_profile_screen.dart` |
| `features/booking/booking_confirmation_screen.dart` | Success screen with booking summary | `booking_screen.dart` on submit |
| `features/portfolio/portfolio_upload_screen.dart` | Photographer dashboard: edit profile, upload photos | `home_screen.dart` |

---

## 🔄 App Flow

```
App Launch
    │
    ▼
Firebase Auth Check (AuthGate)
    │
    ├── Not Logged In ──► LoginScreen
    │                         │
    │                     Sign In / Sign Up
    │                     (Select Role: Client or Photographer)
    │
    └── Logged In ──► HomeScreen
                          │
              ┌───────────┴──────────────┐
              │ Role = Client            │ Role = Photographer
              ▼                          ▼
         BrowseScreen              PortfolioUploadScreen
              │                         │
         Filter by specialty        Edit Profile (Bio, Specialty, Price)
         Tap Photographer Card      Upload Cover Photo
              │                         │
              ▼                     Upload Portfolio Images
    PhotographerProfileScreen           │
              │                     Save to Cloudinary + Firestore
         View Gallery
         Tap "Book Session"
              │
              ▼
         BookingScreen
         (Pick Package + Date + Time)
              │
              ▼
    BookingConfirmationScreen ✅
```

---

## 📐 Design System (Material 3 Theme)

| Token | Color | Usage |
|-------|-------|-------|
| **Background** | `#F7F5F0` Warm Cream | All screen backgrounds |
| **Primary** | `#222222` Charcoal | Text, buttons, icons |
| **Accent** | `#A67C52` Bronze | Highlights, chips, price badge |
| **Surface / Card** | `#FFFFFF` White | Cards, dialogs |
| **Error** | `#B00020` | Form validation, errors |

**Typography**: Inter / Roboto — clean, modern, image-forward.

---

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK `3.x` installed ([flutter.dev](https://flutter.dev/docs/get-started/install))
- A Firebase project created at [console.firebase.google.com](https://console.firebase.google.com)
- A Cloudinary account at [cloudinary.com](https://cloudinary.com)
- A device/emulator or Chrome (for Web)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/sarthaktajane07/Framefolio.git
cd Framefolio

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (Web)
flutter run -d chrome

# 4. Run on Android emulator
flutter run -d android

# 5. Build APK
flutter build apk --release
```

---

## 🔥 Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com) → Your Project.
2. Enable **Authentication** → Sign-in method → **Email/Password**.
3. Enable **Cloud Firestore** → Create database (Start in test mode for development).
4. Run `flutterfire configure` to auto-generate `lib/firebase_options.dart`.

### Firestore Collections

| Collection | Documents |
|------------|-----------|
| `users` | `{uid}` → `{ name, email, role }` |
| `photographers` | `{docId}` → `{ name, specialty, bio, startingPrice, coverPhotoUrl, portfolioUrls[] }` |
| `bookings` | `{bookingId}` → `{ clientId, photographerId, package, price, date, time, status }` |

---

## ☁️ Cloudinary Configuration

Cloudinary is used instead of Firebase Storage to avoid requiring the **Firebase Blaze (paid)** billing plan.

1. Create a free account at [cloudinary.com](https://cloudinary.com).
2. Go to **Settings → Upload → Upload presets** → Create an **unsigned** preset.
3. Update `lib/services/storage_service.dart` with your Cloud Name and Upload Preset:

```dart
const _cloudName = 'your_cloud_name';
const _uploadPreset = 'your_unsigned_preset';
```

---

## 🌱 Demo Data

For presentations, the app includes a **"Load Demo Data"** button in the Browse screen AppBar.

Tapping it seeds **6 pre-configured photographer profiles** into Firestore with:
- High-quality Unsplash portfolio images
- Realistic bios, specialties, pricing, and ratings

No manual data entry needed for demos!

---

## 📚 Academic Details

| Detail | Info |
|--------|------|
| **Course** | B.Tech Computer Science Engineering & AI |
| **Subject** | Cross Platform Application Development |
| **Problem No.** | 48 |
| **App Name** | FrameFolio |
| **Student** | Sarthak Tajane |

### Concepts Demonstrated
- ✅ Flutter `StatefulWidget` & `StatelessWidget`
- ✅ Firebase Authentication (Email/Password)
- ✅ Cloud Firestore CRUD with `async/await`
- ✅ Image upload via REST API (Cloudinary)
- ✅ `StreamBuilder` for real-time auth state
- ✅ `FutureBuilder` for async data loading
- ✅ `GridView.builder` for responsive image grids
- ✅ Material 3 custom theme system
- ✅ Role-based navigation (Client vs Photographer)
- ✅ Form validation with `GlobalKey<FormState>`
- ✅ `image_picker` for camera/gallery access
- ✅ `cached_network_image` for efficient image caching
- ✅ Clean feature-based project architecture

---

## 📝 License

This project is created for academic purposes as part of a college assignment.

---

<p align="center">Built with ❤️ using Flutter & Firebase</p>

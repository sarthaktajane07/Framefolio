# FrameFolio — UI Architecture & Widget Breakdown

This document provides a detailed breakdown of the User Interface (UI) in the **FrameFolio** application. It explains exactly which UI widgets are used, where they are located in the codebase, and how different screens connect to each other.

---

## 🎨 1. Core Styling & Theming
**File:** `lib/core/theme/app_theme.dart`
**Called By:** `lib/app.dart` (Passed to the `MaterialApp`'s `theme` property).

* **Concept:** The app uses a highly customized **Material 3** theme.
* **Colors Used:**
  * Background: `#F7F5F0` (Off-white/creamy color for a premium look)
  * Cards/Surfaces: `#FFFFFF` (Pure white)
  * Primary Text/Icons: `#222222` (Dark gray/black)
  * Accent Color: `#A67C52` (Warm brown/gold for buttons and highlights)
* **Widgets Affected Globally:** All `AppBar`, `ElevatedButton`, `OutlinedButton`, `TextFormField`, and `Card` widgets automatically inherit this theme.

---

## 🧩 2. Reusable UI Components (Core Widgets)
These are independent UI widgets built once and reused across multiple screens.

### A. Photographer Card
**File:** `lib/core/widgets/photographer_card.dart`
**Called By:** `lib/features/browse/browse_screen.dart`
* **Widgets Used:** `Card`, `ClipRRect` (for rounded image corners), `CachedNetworkImage` (for loading the cover photo), `Text`.
* **Purpose:** Displays the summary of a photographer (Cover photo, Name, Specialty, and Starting Price) in the Browse grid.

### B. Portfolio Grid
**File:** `lib/core/widgets/portfolio_grid.dart`
**Called By:** `lib/features/browse/photographer_profile_screen.dart`
* **Widgets Used:** `GridView.builder` (using `SliverGridDelegateWithFixedCrossAxisCount`), `CachedNetworkImage`.
* **Purpose:** A clean, 3-column grid that displays the photographer's uploaded portfolio images. 

### C. Loading Widget
**File:** `lib/core/widgets/loading_widget.dart`
**Called By:** Used across the app (Profile screen, Browse screen) when fetching data.
* **Widgets Used:** `Center`, `CircularProgressIndicator`, `Text`.

---

## 📱 3. Screens & Features Breakdown

### A. App Entry & Authentication Gate
**File:** `lib/app.dart`
* **UI Used:** `StreamBuilder`
* **Flow:** This is the root widget. It checks if the user is logged in. If NO, it shows `LoginScreen`. If YES, it shows `HomeScreen`.

### B. Authentication Screens (Login & Register)
**File:** `lib/features/auth/login_screen.dart`
* **Widgets Used:** `SafeArea`, `SingleChildScrollView`, `Form`, `TextFormField` (with email/password regex validation), `ElevatedButton`.
* **Custom UI:** Inside `RegisterScreen`, there is a custom **Role Selector** (Client vs Photographer) built using `Row`, `Expanded`, `AnimatedContainer`, and `GestureDetector`.
* **Flow:** On successful login or registration, the user is navigated via `Navigator.pushReplacement` to the `HomeScreen`.

### C. Home Router & Photographer Dashboard
**File:** `lib/features/home/home_screen.dart`
* **Flow Logic:** This screen checks the logged-in user's role from Firestore.
  * If role == 'client', it returns the `BrowseScreen`.
  * If role == 'photographer', it returns the `_PhotographerDashboard` (built inside this same file).
* **Photographer Dashboard UI:** Uses a modern Welcome `Container` (colored in Primary #222222) and custom `ListTile` cards (using `_DashboardTile`) to navigate to the Upload screen or Browse screen.

### D. Browse Photographers (Client View)
**File:** `lib/features/browse/browse_screen.dart`
* **Top Section UI:** Uses a horizontal `ListView.separated` containing `FilterChip` widgets. This allows the user to tap and filter photographers by specialty (Wedding, Fashion, etc.).
* **Bottom Section UI:** Uses a `StreamBuilder` connected to Firestore.
  * **Responsive UI:** Uses a `LayoutBuilder`. If the screen is narrow (mobile), it shows a 1-column `GridView.builder`. If wide (tablet/web), it shows a 2-column grid.
* **Flow:** Tapping a `PhotographerCard` navigates to `PhotographerProfileScreen`.

### E. Photographer Profile Screen
**File:** `lib/features/browse/photographer_profile_screen.dart`
* **Main UI Structure:** Uses a `CustomScrollView` with Slivers instead of a standard Scaffold body. This creates a highly premium, scrollable parallax effect.
* **Widgets Used:** 
  * `SliverAppBar`: Holds the massive Cover Photo at the top. It shrinks dynamically when scrolled up.
  * `SliverToBoxAdapter`: Holds the Profile Header (Name, Price, Bio, Package `Chip`s).
  * `SliverPadding` -> `PortfolioGrid`: Embeds the reusable grid component at the bottom.
* **Sticky Button:** The `bottomNavigationBar` is used to hold a persistent `ElevatedButton` ("Book a Session") that stays fixed at the bottom while scrolling.

### F. Session Booking Form
**File:** `lib/features/booking/booking_screen.dart`
* **Widgets Used:** 
  * `Form` and `TextFormField` for text inputs (Name, Email, Phone).
  * `DropdownButtonFormField`: For selecting the Photography Package.
  * `showDatePicker` (System Dialog): Triggered via `InkWell`. It restricts users from selecting past dates.
  * `ChoiceChip` inside a `Wrap`: A clean, tap-able grid of Time Slots (Morning, Afternoon, etc.) instead of a boring dropdown.
  * Custom `_buildStep()` UI: A visual 1-2-3 progress indicator at the top of the form.
* **Flow:** Tapping "Confirm Booking" validates the form, shows a `CircularProgressIndicator` on the button, saves to Firestore, and navigates to `BookingConfirmationScreen`.

### G. Booking Confirmation Screen
**File:** `lib/features/booking/booking_confirmation_screen.dart`
* **Widgets Used:** `Card`, custom `_DetailRow` (Row with Icon and Text columns). 
* **Purpose:** A clean success screen showing a big green checkmark and the generated `Booking ID`.
* **Flow:** The "Back to Home" button uses `Navigator.pushAndRemoveUntil` to clear the routing stack and send the user back to the `BrowseScreen`.

### H. Portfolio Upload Screen
**File:** `lib/features/portfolio/portfolio_upload_screen.dart`
* **Widgets Used:** 
  * standard `TextFormField`s for Bio, Name, Price.
  * **Custom Image Pickers:** Uses `GestureDetector` wrapped around `Container`s. If an image is selected via the `image_picker` package, it displays it using `Image.file` (or `Image.network` on web).
  * **Preview Grid:** A small `GridView.builder` with `Stack` and `Positioned` close (X) icons to allow users to remove selected images before uploading.
  * `LinearProgressIndicator`: A horizontal loading bar that fills up as images are sequentially uploaded to the cloud.

---

## 🔄 Summary of UI Navigation Flow

1. `app.dart` ➔ `LoginScreen`
2. `LoginScreen` ➔ (Success) ➔ `HomeScreen`
3. `HomeScreen` (if Client) ➔ `BrowseScreen`
4. `HomeScreen` (if Photographer) ➔ `Photographer Dashboard`
5. `Photographer Dashboard` ➔ `PortfolioUploadScreen`
6. `BrowseScreen` ➔ (Tap Card) ➔ `PhotographerProfileScreen`
7. `PhotographerProfileScreen` ➔ (Tap Book Button) ➔ `BookingScreen`
8. `BookingScreen` ➔ (Submit Form) ➔ `BookingConfirmationScreen`
9. `BookingConfirmationScreen` ➔ (Tap Home Button) ➔ `BrowseScreen`

# FrameFolio — Proper Justification

## Project Overview
FrameFolio is a cross-platform Photography Portfolio & Booking Application built as a B.Tech CSE (Semester V) case study, targeting Android, iOS, and Web from a single Dart codebase.

---

## Why Flutter?

**1. Single Codebase, Three Platforms**
Flutter compiles one Dart codebase to Android, iOS, and Web — eliminating platform-specific branches. For a portfolio app, visual consistency across devices is critical: clients and photographers must see identical UI.

**2. Widget-Native Rendering**
Flutter renders via Skia/Impeller (not platform bridges), giving pixel-perfect control over typography, grid spacing, and image presentation — essential for an image-forward photography app.

**3. Material 3 Design System**
Flutter ships first-class Material 3 support (`useMaterial3: true`). `ColorScheme.fromSeed` generates harmonious palettes from one seed colour, keeping the design minimal and photography-forward.

**4. Hot Reload**
Reduced UI iteration time dramatically when fine-tuning card layouts, grid proportions, and animation timings.

**5. Rich Null-Safe Ecosystem**
`cached_network_image`, `image_picker`, `google_fonts`, `provider` — all maintained by the Flutter/Google community with full null-safety.

---

## Why Firebase?

**1. Serverless Architecture**
No custom backend needed. Auth, database, and storage are managed services — ideal for a case study where delivery speed matters.

**2. Firebase Authentication**
Email/password auth with `FirebaseAuthException` error codes enables specific, user-friendly messages (wrong-password vs user-not-found).

**3. Cloud Firestore (Realtime)**
`snapshots()` streams enable real-time booking status updates via `StreamBuilder` — no polling. The document model maps naturally to app entities.

**4. Firebase Cloud Storage**
Portfolio images stored at `portfolios/{uid}/{uuid}.jpg`. Upload progress streamed via `UploadTask.snapshotEvents`, powering the `LinearProgressIndicator`.

**5. Security Rules as Code**
Firestore and Storage rules are co-located with source, deployed via Firebase CLI, ensuring owner-only writes without a separate auth middleware.

---

## Why Each Key Widget?

| Widget | Justification |
|--------|--------------|
| `GridView.builder` | Lazy renders large image grids; column count adapts via `LayoutBuilder` (2/3/4 columns) |
| `CachedNetworkImage` | Disk-caches images, avoids re-downloads; built-in placeholder and error widgets |
| `Form` + `TextFormField` | Inline validation prevents invalid data reaching Firestore |
| `StreamBuilder` | Connects Firestore streams to UI; rebuilds on booking status changes |
| `InteractiveViewer` | Pinch-to-zoom for full-screen portfolio images, no extra dependency |
| `Hero` | Shared-element transitions from card cover to detail screen |
| `SliverAppBar` | Collapses cover photo on scroll, keeping images prominent |
| `SegmentedButton` | Material 3 role selector; accessible and keyboard-navigable |
| `FilledButton` | High-contrast CTA; `minSize: 52px` satisfies 48dp tap-target guidelines |

---

## Why Minimal Material 3 Theme?

Photography is the product — the UI must not compete. The design achieves this by:
- **Near-zero elevation** cards and **0.5px dividers** — no drop shadows distracting from images.
- **Neutral seed (#1A1A1A)** generates a muted grey palette; images occupy full card area edge-to-edge.
- **Warm gold accent (#B88A4A)** adds personality without overpowering.
- **Playfair Display (headings) + Inter (body)**: editorial elegance meets legibility.
- **ThemeMode.system**: dark mode respected automatically.

---

## Why Provider?

`provider` was chosen over Riverpod, Bloc, or GetX because:

1. **Simplicity**: Three `ChangeNotifier` classes (Auth, Portfolio, Booking) cover all state without code generators.
2. **Officially recommended**: Featured in Flutter's official state management documentation for medium-complexity apps.
3. **Testable**: Pure Dart `ChangeNotifier` classes can be unit-tested without Flutter widget infrastructure.
4. **Right-sized**: Bloc's event-state boilerplate and Riverpod's annotation generation are unnecessary for three isolated state domains.

---

*FrameFolio — B.Tech CSE Semester V Cross-Platform Application Case Study*

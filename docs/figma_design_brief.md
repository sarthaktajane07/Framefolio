# FrameFolio — Figma Design Brief

## 1. Overview
FrameFolio is a photography-first product. The design philosophy is: **images lead, UI follows**.
All frames must feel like a premium editorial magazine — minimal chrome, generous whitespace, and bold photography.

---

## 2. Design Tokens

### Colour Palette
| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `color/primary` | `#1A1A1A` | `#E8E8E8` | Buttons, icons, headings |
| `color/secondary` | `#B88A4A` | `#B88A4A` | Accent, specialty badges, price highlights |
| `color/surface` | `#FAFAFA` | `#121212` | Page background |
| `color/surfaceVariant` | `#F0F0F0` | `#1E1E1E` | Cards, input fills |
| `color/outline` | `#DDDDDD` | `#333333` | Dividers, borders |
| `color/error` | `#B3261E` | `#F2B8B5` | Validation errors |

### Typography (8pt grid)
| Role | Font | Size | Weight | Usage |
|------|------|------|--------|-------|
| `type/displaySmall` | Playfair Display | 36sp | 400 | Hero taglines |
| `type/headlineMedium` | Playfair Display | 28sp | 600 | Screen titles |
| `type/headlineSmall` | Playfair Display | 24sp | 600 | Section headings |
| `type/titleLarge` | Inter | 22sp | 600 | App bar |
| `type/titleMedium` | Inter | 16sp | 600 | Card names |
| `type/titleSmall` | Inter | 14sp | 600 | Form labels |
| `type/bodyMedium` | Inter | 14sp | 400 | Body text, bio |
| `type/bodySmall` | Inter | 12sp | 400 | Captions, meta |
| `type/labelSmall` | Inter | 11sp | 500 | Chips, badges |

### Spacing (8pt Grid)
`4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64`

### Border Radius
`12dp` for cards and inputs · `100dp` (pill) for chips and status badges

### Elevation
Cards: `0dp shadow` · Dialogs: `3dp shadow` · FAB: `6dp shadow`

---

## 3. Frames

### Frame 1 — Login / Sign-up (Mobile 390px)
**Layout:** Centred single column, max-width 480dp
- **Header block** (top-centre): 72×72dp camera icon in `color/primary` rounded square, `FrameFolio` in `type/headlineMedium`, subtitle in `type/bodySmall/60% opacity`
- **Role selector**: Material 3 SegmentedButton — "Client" | "Photographer"; selected segment filled `color/primary`
- **Inputs** (Name, Email, Password): Filled style, `12dp` radius, no border in rest state; `1.5dp primary` border on focus; inline error text in `color/error`
- **CTA**: `FilledButton` full-width `52dp` tall, `color/primary` background
- **Toggle link**: "Already have an account? Sign In" — secondary text + `color/primary` span

**Desktop 1440px variant:** Same layout centred in a 480dp card placed on a full-bleed photography hero image occupying left 55% of screen.

---

### Frame 2 — Browse Photographers (Mobile 390px + Desktop 1440px)
**Mobile Layout:**
- **AppBar**: Title "FrameFolio" left, logout icon right; `0dp` elevation
- **Subhead** 16dp padding: "Find Your Photographer" `type/headlineSmall`, subtitle `type/bodySmall`
- **Category chips**: Horizontal scroll row, `44dp` height, `StadiumBorder`, `12dp` horizontal padding between chips
- **Grid**: 2 columns, `12dp` gap, `CardAspectRatio 0.72`
  - Card: image fills top 60%, footer 40% with name `type/titleSmall`, specialty in `color/secondary`, price in `type/labelSmall/60%`

**Desktop 1440px variant:** 4-column grid, `48dp` page padding, chips wrap into two rows if needed, max-content-width `1280dp` centred.

---

### Frame 3 — Portfolio Detail (Mobile 390px)
**Layout:** `CustomScrollView` with `SliverAppBar`
- **Cover image**: `300dp` expanded height, pinned `56dp` collapsed; `Hero` transition tag from browse card
- **Info section** (`24dp` horizontal padding):
  - Name `type/headlineSmall` | Specialty badge (pill, `color/secondary 12% alpha`)
  - Price "From ₹X,XXX" right-aligned `type/titleMedium`
  - Bio paragraph `type/bodyMedium` `1.6` line-height
  - "Portfolio (N photos)" label `type/titleSmall`
- **Image grid**: 2 columns, `4dp` gap, square cells; tap → full-screen `InteractiveViewer`
- **FAB**: `FloatingActionButton.extended` centred at bottom — "Book a Session", `color/primary`

---

### Frame 4 — Portfolio Upload (3-Step, Mobile 390px)
**Step Indicator**: `32dp` circles connected by `2dp` lines; done = filled primary; current = primary ring; future = outline grey
**Step Labels Row**: labels below circles, active = `color/primary` weight 600

**Step 0 — Details:**
- Title input, Specialty dropdown, Price input, Bio textarea (4 rows, char count)

**Step 1 — Images:**
- Cover photo: `180dp` dashed border container; tap opens gallery picker
- Portfolio images: horizontal `120dp` scroll row; each thumbnail `100×120dp` with `×` remove button top-right
- "Add Images" button: `TextButton.icon` with plus icon

**Step 2 — Uploading:**
- Overall: labelled `LinearProgressIndicator` `8dp` tall
- Per-image: smaller `6dp` indicator in `color/secondary`
- Status text: "Image N of M", keep-app-open notice

**Success State:** Check circle icon, "Portfolio Published!" headline, "Upload Another" `FilledButton`

---

### Frame 5 — Session Booking (3-Step, Mobile 390px)
**Step 0 — Date & Slot:**
- Date selector: tappable container row (calendar icon, formatted date, chevron right)
- Time slots: `Wrap` of `ChoiceChip` pills; selected = `color/primary`

**Step 1 — Package & Contact:**
- Package cards: 3 radio-style selectable tiles (Basic / Standard / Premium with ₹ price); selected = `color/primary 8%` fill + `1.5dp` primary border
- Name, Phone, Notes inputs

**Step 2 — Confirmation:**
- 72dp check-circle icon centred, `color/primary 10%` circle background
- "Booking Confirmed!" `type/headlineSmall`
- Summary card: `surfaceVariant` background, rows of label/value pairs separated by `0.5dp` dividers
- "Done" `FilledButton`

---

## 4. Components

| Component | Variants |
|-----------|---------|
| `PhotographerCard` | Default, Hover (scale 1.02, shadow 12dp blur) |
| `CategoryChip` | Unselected, Selected |
| `PackageOption` | Unselected, Selected |
| `StatusChip` | Pending (secondary), Confirmed (green) |
| `StepCircle` | Future, Current, Done |
| `BookingCard` | Client view, Photographer view + Confirm button |

---

## 5. Prototype Connections

```
Login ──[Sign In / Sign Up]──► AuthGate
                                  ├──[Photographer]──► Upload Screen (tab 0)
                                  │                    └── My Bookings (tab 1)
                                  └──[Client]──► Browse Screen (tab 0)
                                                  ├── Portfolio Detail
                                                  │     └── Booking Screen
                                                  │           └── Confirmation
                                                  └── My Bookings (tab 1)
```

---

## 6. Mobile (390px) vs Desktop (1440px) Variants

| Element | Mobile | Desktop |
|---------|--------|---------|
| Grid columns | 2 | 4 |
| Page padding | 16dp | 48dp |
| AppBar | Standard | Wide with logo left |
| Login form | Full-width | 480dp card on hero bg |
| Portfolio cover | 300dp | 420dp |
| Image grid | 2 cols, 4dp gap | 4 cols, 8dp gap |
| Category chips | Horizontal scroll | Wrap (two rows) |

---

*Use Figma Variables to bind all colour and typography tokens. Apply Auto Layout on all frames using the 8pt grid.*

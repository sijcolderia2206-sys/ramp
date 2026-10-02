# 🎨 Design System Specification — RAMP

**Brand System:** RAMP (Rental Administration and Maintenance Platform)  
**Aesthetic Theme:** Modern Fintech / PropTech Operational Dashboard  
**Framework:** Flutter Material 3 (`lib/core/theme/ramp_theme.dart` & `lib/core/theme/app_colors.dart`)  
**Design Tokens:** 8-Point Grid System, Soft Drop Shadows, Pure White Cards, Brand Blue Primary  
**Document Version:** 2.0.0  

---

## 1. Visual Strategy & Aesthetic Principles

The RAMP design system delivers a clean, data-dense, professional fintech aesthetic. It minimizes visual noise while prioritizing financial clarity, operational efficiency, and rapid action scanning.

### Core Design Rules
- **Surface Contrast:** Pure white cards (`#FFFFFF`) elevated over a subtle, off-white scaffold background (`#F8FAFC`).
- **Soft Borderless Elevation:** Elimination of harsh 1px solid card borders. Cards use a standardized soft drop shadow (`Color(0x0D000000)`, blur radius 10, offset `(0, 4)`).
- **Focused Brand Color Palette:** Deep royal blue (`#1E40AF`) for primary brand elements, active tab indicators, and interactive states. Random pastel background fills or colored card borders are strictly forbidden.
- **Flaticon Vector Integration:** Icons are rendered exclusively using custom SVG vector assets via `flutter_svg` (`assets/icons/`).
- **Data Densification:** Compact 80px progress rings, vertical data stacking (labels stacked above bold values), and clear badge hierarchy.

---

## 2. Color System & Palette Tokens

### 2.1 Brand & Core Palette

| Token Name | Hex Code | Purpose / Usage |
|---|---|---|
| `AppColors.primary` | `#1E40AF` | Primary Brand Blue, active buttons, main navigation tab, key focus states |
| `AppColors.primaryLight` | `#3B82F6` | Accent highlights, secondary interactive states, links |
| `AppColors.background` | `#F8FAFC` | Main app scaffold background |
| `AppColors.surface` | `#FFFFFF` | Card containers, dialog backgrounds, bottom sheets |
| `AppColors.textPrimary` | `#0F172A` | Primary headers, body text, data values |
| `AppColors.textSecondary` | `#64748B` | Secondary labels, captions, subtitles, inactive icons |
| `AppColors.border` | `#E2E8F0` | Light dividers, subtle input container borders |

### 2.2 Semantic & Status Colors

| Token Name | Hex Code | Purpose / Usage |
|---|---|---|
| `AppColors.success` | `#10B981` | Paid status, Green tenant health dot, verified revenue, complete stage |
| `AppColors.warning` | `#F59E0B` | Pending status, Yellow tenant health dot, visit scheduled |
| `AppColors.danger` | `#EF4444` | Overdue rent, Red tenant health dot, emergency maintenance, errors |
| `AppColors.info` | `#3B82F6` | Informational chips, estimate stage badges |

---

## 3. Typography Tokens

Typography is powered by **Google Fonts (Inter / Poppins)** configured through Material 3 `TextTheme`.

```
Display Header 1  ─  24px Bold (700) ────── Page Titles / Key Metrics
Title Header 2    ─  18px SemiBold (600) ── Card Titles / Section Headers
Subtitle 3        ─  16px Medium (500) ──── Subheaders / List Item Titles
Body Large        ─  14px Regular (400) ── Standard Body Text / Input Fields
Body Small        ─  12px Regular (400) ── Metadata / Secondary Captions
Micro Label       ─  11px SemiBold (600) ─ Badges / All-Caps Micro Labels
```

### Typography Scale Table

| Token Style | Size | Weight | Line Height | Usage Context |
|---|---|---|---|---|
| `headlineLarge` | `24.0` | `FontWeight.bold` | `32.0` | Dashboard revenue header, modal titles |
| `titleMedium` | `18.0` | `FontWeight.w600` | `24.0` | Card header titles, dialog headings |
| `titleSmall` | `16.0` | `FontWeight.w500` | `22.0` | List section titles, unit card names |
| `bodyLarge` | `14.0` | `FontWeight.w400` | `20.0` | Standard form fields, body paragraphs |
| `bodySmall` | `12.0` | `FontWeight.w400` | `16.0` | Timestamp labels, secondary metadata |
| `labelSmall` | `11.0` | `FontWeight.w600` | `14.0` | Status chip text, uppercase section tags |

---

## 4. Spacing, Layout Grid & Elevation

### 4.1 8-Point Grid System
All padding, margin, gap, and widget sizing must strictly follow the 8-point spatial system:

```
4px   ── Micro Spacing (Chip inner padding, icon-text gap)
8px   ── Compact Spacing (List item gaps, row spacing)
16px  ── Standard Padding (Card padding, screen horizontal margins)
24px  ── Section Spacing (Spacing between distinct card groups)
32px  ── Macro Spacing (Screen top/bottom major margins)
```

### 4.2 Elevation & Shadow Token
- **Standard Card Elevation:**
  ```dart
  BoxShadow(
    color: Color(0x0D000000), // 5% opacity black
    blurRadius: 10.0,
    offset: Offset(0, 4),
  )
  ```
- **Modal / Bottom Sheet Elevation:**
  ```dart
  BoxShadow(
    color: Color(0x1A000000), // 10% opacity black
    blurRadius: 20.0,
    offset: Offset(0, -4),
  )
  ```

---

## 5. Core UI Component Guidelines

### 5.1 Card Components (`RampCard`)
- **Background:** `#FFFFFF` (Pure White)
- **Border Radius:** `12.0` or `16.0` pixels
- **Padding:** Standard `16.0` pixels
- **Shadow:** Standard soft drop shadow
- **Rule:** Never apply dark or high-contrast 1px solid borders around cards.

```dart
Container(
  padding: const EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16.0),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: contentWidget,
)
```

### 5.2 Buttons & Interactive Elements

#### Primary Action Button
- **Background:** `AppColors.primary` (`#1E40AF`)
- **Text Color:** `#FFFFFF`
- **Border Radius:** `12.0` pixels
- **Height:** `48.0` pixels (Touch target minimum)

#### Secondary / Outlined Button
- **Background:** `Transparent` or `#F1F5F9`
- **Border:** `1px` solid `#CBD5E1`
- **Text Color:** `#0F172A`

### 5.3 Badges & Health Indicators

#### Tenant Health Dot (`TenantHealthDot`)
Consistently rendered in Tenant Directory and Tenant Profile views:
- 🟢 **Green (`#10B981`):** Pays reliably on or before due date.
- 🟡 **Yellow (`#F59E0B`):** Occasional reminders or upcoming due date.
- 🔴 **Red (`#EF4444`):** Frequently overdue or severely past due.

#### Maintenance Stage Chips
Stage status badges matching the 4-stage pipeline:
- `Schedule Visit`: Blue Badge (`#DBEAFE` container, `#1E40AF` text)
- `Estimate`: Amber Badge (`#FEF3C7` container, `#D97706` text)
- `Schedule Repair`: Purple Badge (`#F3E8FF` container, `#6B21A8` text)
- `Completed`: Green Badge (`#D1FAE5` container, `#065F46` text)

---

## 6. Iconography & SVG Asset Conventions

Custom Flaticon assets are placed in `assets/icons/` and rendered via `flutter_svg`:

```dart
SvgPicture.asset(
  'assets/icons/icon_name.svg',
  width: 24.0,
  height: 24.0,
  colorFilter: const ColorFilter.mode(
    AppColors.primary,
    BlendMode.srcIn,
  ),
)
```

### Icon Rules
1. Always apply explicit `width` and `height`.
2. Tint vector icons using `AppColors.primary` for active/interactive states or `AppColors.textSecondary` for inactive states.
3. Avoid wrapping icons in arbitrary pastel-colored circles.

---

## 7. Responsive Shells & Dark Mode Adaptability

### 7.1 Responsive Shell Guidelines
- **Mobile Viewports (< 600dp):** Single-column layout with 5-tab bottom navigation (`LandlordShell`).
- **Tablet / Desktop Viewports (>= 600dp):** Collapsible sidebar menu (`RampDrawerScaffold`) with multi-column grid dashboard.

### 7.2 Dark Mode Adaptation
In dark mode:
- Scaffold Background transitions to `#0F172A` (Slate 900).
- Card Surface transitions to `#1E293B` (Slate 800).
- Text Primary transitions to `#F8FAFC`.
- Soft shadows adjust to `#000000` with 20% opacity for distinct layer separation.

# 🎨 Shop Store Page - Visual Breakdown

## 📐 Layout Estrutura

```
┌─────────────────────────────────────────────────┐
│ SliverAppBar (pinned: true, expandedHeight: 200)
│ ┌───────────────────────────────────────────────┐
│ │ FlexibleSpaceBar Background                   │
│ │ ┌─────────────────────────────────────────────┐
│ │ │ _StoreBanner (PageView + dots)              │
│ │ │                                             │
│ │ │ ┌────────────────────────────────────────┐ │
│ │ │ │ [Banner Image 1]                       │ │
│ │ │ │                                        │ │
│ │ │ │            ● ○ ○ (page indicator)     │ │
│ │ │ └────────────────────────────────────────┘ │
│ │ └─────────────────────────────────────────────┘
│ │                                               │
│ │ title: "Store Name" (scrolls with app bar)  │
│ └───────────────────────────────────────────────┘
│ [← back arrow]
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ SliverToBoxAdapter                              │
│ ┌─────────────────────────────────────────────┐ │
│ │ _StoreHeader                                │ │
│ │                                             │ │
│ │ [Logo]  Store Name      ← Logo (64x64)     │ │
│ │  ╭─╮   Premium 👑                          │ │
│ │  │ │   BrawePass ✨                        │ │
│ │  ╰─╯   ⭐ 4.8 (234 reviews)               │ │
│ │                                             │ │
│ │ Description of the store... [Read More ▼]  │ │
│ │                                             │ │
│ │ [Electronics] [Games] [Books]               │ │
│ │ (horizontal scroll of categories)           │ │
│ │                                             │ │
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ SliverToBoxAdapter                              │
│ ┌─────────────────────────────────────────────┐ │
│ │ _StoreContactRow (if has contacts)          │ │
│ │                                             │ │
│ │ Contact Section                             │ │
│ │                                             │ │
│ │ [WhatsApp] [Instagram] [Facebook]           │ │
│ │ [TikTok]   [Email]                          │ │
│ │                                             │ │
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ SliverPadding                                    │
│ ┌─────────────────────────────────────────────┐ │
│ │ "Products" section title                    │ │
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ SliverGrid (responsivo)                         │
│                                                 │
│ 2 columns (mobile)                              │
│ ┌──────────────┬──────────────┐                 │
│ │              │              │                 │
│ │ [Product 1]  │ [Product 2]  │                 │
│ │              │              │                 │
│ │ Name         │ Name         │                 │
│ │ R$ 99,90     │ R$ 149,90    │                 │
│ │ ⭐ 4.5       │ ⭐ 4.2       │                 │
│ ├──────────────┼──────────────┤                 │
│ │ [Product 3]  │ [Product 4]  │                 │
│ │              │              │                 │
│ └──────────────┴──────────────┘                 │
│                                                 │
│ 3 columns (tablet)  / 4 columns (desktop)      │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 🎬 _StoreBanner Component Detail

### Quando tem múltiplos banners
```
┌──────────────────────────────────┐
│                                  │ 200px
│       [Banner Image]             │
│     (CachedNetworkImage)         │
│                                  │
│          ● ○ ○                    │ (indicator dots)
└──────────────────────────────────┘

Page 0 → ● ○ ○
Page 1 → ○ ● ○
Page 2 → ○ ○ ●
```

### Quando não tem banners (fallback)
```
┌──────────────────────────────────┐
│                                  │
│    Gradient (accentPrimary      │ 200px
│           ↘ accentSecondary)   │
│                                  │
│           [Logo]                 │ (circular, 64x64)
│         ou Store icon            │
│                                  │
└──────────────────────────────────┘
```

**Gradiente Colors**:
```dart
gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    context.colors.accentPrimary,    // Brawe Blue
    context.colors.accentSecondary,  // Lighter shade
  ],
)
```

---

## 👤 _StoreHeader Component Detail

### Layout
```
┌───────────────────────────────────────────────────────┐
│                                                       │
│ [Circle Logo] Store Name         ← 64x64 circular    │
│  ClipOval    Premium 👑 BrawePass ✨                │
│             ⭐ 4.8 (234)                            │
│                                                       │
│ Description text that might wrap to multiple lines   │
│ and can be expanded to show full content...          │
│ [Read More ▼] or [Read Less ▲]                      │
│                                                       │
│ [Electronics] [Games] [Livros]                       │
│  (horizontal scroll for more categories)              │
│                                                       │
└───────────────────────────────────────────────────────┘
```

### Badges
```
┌──────────────┐          ┌─────────────────┐
│ 👑 PREMIUM   │          │ ✨ BRAWE PASS   │
└──────────────┘          └─────────────────┘

Background: color.withValues(alpha: 0.15)
Border: color.withValues(alpha: 0.4)
Icon size: 12
Text size: 11 (fontWeight: bold)
Padding: 8h x 4v
Border radius: 999 (pill shape)
```

### Rating Display
```
┌─────────────────────────┐
│ ⭐ 4.8  (234 reviews)  │
│ • Star icon (gold)      │
│ • Rating number (bold)  │
│ • Review count (gray)   │
└─────────────────────────┘
```

---

## 📞 _StoreContactRow Component Detail

### Layout (if has any contact)
```
┌─────────────────────────────────────────────────┐
│                                                 │
│ Contact Section (label)                         │
│                                                 │
│ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐            │
│ │ 💬 │ │ 📷 │ │ 👥 │ │ 🎵 │ │ ✉️ │            │
│ │ WA │ │ IG │ │ FB │ │ TK │ │ EML│            │
│ └────┘ └────┘ └────┘ └────┘ └────┘            │
│  Tooltip on hover                               │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Contact Icon Detail
```
    ┌──────────────┐
    │ Tooltip text │
    └──────────────┘
           ↓
    ┌──────────────┐
    │ ○ (circle)   │  40x40
    │   Icon (16)  │  
    └──────────────┘
    
Border: context.colors.border
Background: context.colors.surfaceHighest
onTap: launchUrl(uri, mode: LaunchMode.externalApplication)
```

### Contact Types
```
WhatsApp:
  URL: https://wa.me/{digitsOnly(phone)}
  Color: #25D366
  Icon: FontAwesomeIcons.whatsapp

Instagram:
  URL: https://instagram.com/{stripHandle(handle)}
  Color: #E1306C
  Icon: FontAwesomeIcons.instagram

Facebook:
  URL: https://facebook.com/{stripHandle(handle)}
  Color: #1877F2
  Icon: FontAwesomeIcons.facebook

TikTok:
  URL: https://www.tiktok.com/@{stripHandle(handle)}
  Color: context.colors.textPrimary
  Icon: FontAwesomeIcons.tiktok

Email:
  URL: mailto:{email}
  Color: context.colors.textSecondary
  Icon: Icons.mail_outline
```

---

## 🛍️ _StoreProductCard Component Detail

### Layout
```
┌──────────────────────────────────┐
│                                  │
│      [Product Image]             │ aspectRatio: 1
│      (CachedNetworkImage)        │
│      fit: BoxFit.cover           │
│                                  │
├──────────────────────────────────┤
│                                  │
│ Product Name (max 2 lines)       │ 13pt, w600
│ R$ 99,90                         │ 14pt, bold
│                                  │ accentPrimary
│ ⭐ 4.5 (if has rating)          │ 11pt, gold
│                                  │
│                                  │
└──────────────────────────────────┘
     onTap → /shop/product/{id}
```

### Image Placeholder (if no image)
```
┌──────────────────────────────────┐
│        [Color background]        │
│           surface color          │
│                                  │
│           [Image icon]           │
│        (Icons.image_outlined)    │
│           size: 32               │
│                                  │
└──────────────────────────────────┘
```

### Product Card Container
```dart
decoration: BoxDecoration(
  color: context.colors.surfaceElevated,  // Card background
  borderRadius: BorderRadius.circular(12),
)
clipBehavior: Clip.antiAlias
padding: EdgeInsets.all(8)  // Inner padding
```

---

## 📱 Responsive Grid

### Mobile (< 640px)
```
┌─────────────┬─────────────┐
│ Product 1   │ Product 2   │
├─────────────┼─────────────┤
│ Product 3   │ Product 4   │
├─────────────┼─────────────┤
│ Product 5   │ Product 6   │
└─────────────┴─────────────┘

crossAxisCount: 2
crossAxisSpacing: 12
mainAxisSpacing: 12
childAspectRatio: 0.68
```

### Tablet (640px - 1280px)
```
┌─────────┬─────────┬─────────┐
│ Prod 1  │ Prod 2  │ Prod 3  │
├─────────┼─────────┼─────────┤
│ Prod 4  │ Prod 5  │ Prod 6  │
└─────────┴─────────┴─────────┘

crossAxisCount: 3
crossAxisSpacing: 12
mainAxisSpacing: 12
childAspectRatio: 0.68
```

### Desktop (> 1280px)
```
┌─────┬─────┬─────┬─────┐
│ P1  │ P2  │ P3  │ P4  │
├─────┼─────┼─────┼─────┤
│ P5  │ P6  │ P7  │ P8  │
└─────┴─────┴─────┴─────┘

crossAxisCount: 4
crossAxisSpacing: 12
mainAxisSpacing: 12
childAspectRatio: 0.68
```

---

## 🎨 Color Scheme

| Element | Color | Notes |
|---------|-------|-------|
| Background | `context.colors.background` | Page background |
| Cards | `context.colors.surfaceElevated` | Product cards |
| Text Primary | `context.colors.textPrimary` | Titles, names |
| Text Secondary | `context.colors.textSecondary` | Descriptions, dates |
| Accents | `context.colors.accentPrimary` | Rating, CTAs |
| Gold | `context.colors.accentGold` | Stars, ratings |
| Border | `context.colors.border` | Dividers, borders |

---

## ⏱️ Loading States

### Loading Product Page
```
┌──────────────────────────────┐
│      [← back] Store Name     │ SliverAppBar
└──────────────────────────────┘
           ↓
┌──────────────────────────────┐
│                              │
│        [Spinner] 🔄         │
│                              │
│    Carregando loja...        │
│                              │
└──────────────────────────────┘
```

### Loading Products
```
┌──────────────────────────────┐
│ [Logo] Store Name            │
│ Premium 👑  ⭐ 4.8          │
├──────────────────────────────┤
│ Description...               │
│ [Electronics] [Games]        │
├──────────────────────────────┤
│ Produtos                     │
│                              │
│        [Spinner] 🔄         │
│                              │
└──────────────────────────────┘
```

---

## ⚠️ Error States

### Store Error
```
┌──────────────────────────────┐
│      [← back]                │
└──────────────────────────────┘
           ↓
┌──────────────────────────────┐
│                              │
│      [Error icon]            │
│         ⚠️                    │
│                              │
│    Erro ao carregar loja     │
│                              │
│      [Retry button]          │
│                              │
└──────────────────────────────┘
```

### Products Error
```
┌──────────────────────────────┐
│ Store information OK...      │
├──────────────────────────────┤
│ Produtos                     │
│                              │
│      [Error icon]            │
│                              │
│   Erro ao carregar produtos  │
│                              │
│      [Retry button]          │
│                              │
└──────────────────────────────┘
```

---

## 📭 Empty State

### No Products
```
┌──────────────────────────────┐
│ Store information OK...      │
├──────────────────────────────┤
│ Produtos                     │
│                              │
│   [Package icon]             │
│                              │
│   Nenhum produto disponível  │
│                              │
└──────────────────────────────┘
```

---

## 🎬 Animation & Transitions

### Page Transition
```dart
// slide_up transition
// From: bottom of screen
// To: full screen
// Duration: default (250ms?)
// Curve: easeInOut (default)
```

### Banner PageView
```dart
// Smooth scroll animation
// When user swipes to next/prev banner
// No explicit animation needed (PageView handles it)
```

### Description Expand/Collapse
```dart
// setState(() => _descriptionExpanded = !_descriptionExpanded)
// No explicit animation (just state change)
// Could be enhanced with AnimatedSize/AnimatedOpacity
```

---

## 🔍 Accessibility

### Touch Targets
- Minimum 44x44dp (Material Design spec)
- Contact icons: 40x40
- Product cards: full width

### Text
- Headings: titleLarge, bold
- Body: bodyMedium
- Labels: labelSmall, labelLarge
- Sufficient color contrast

### Semantics
- Back button with leading arrow
- Product names clearly visible
- Price in separate text element
- Rating with visual + numeric indicator

---

## 📐 Spacing & Padding

```dart
// Outer padding
padding: EdgeInsets.fromLTRB(16, 16, 16, 0)  // Header

// Product grid padding
padding: EdgeInsets.symmetric(horizontal: 12)

// Card spacing
crossAxisSpacing: 12
mainAxisSpacing: 12

// Internal card padding
padding: EdgeInsets.all(8)

// Contact row spacing
spacing: 12   // horizontal
runSpacing: 8 // vertical

// Category chips
spacing: 8    // between chips
```

---

## 🧪 Test Scenarios

| Scenario | Expected |
|----------|----------|
| Load store with all data | All sections display |
| No banners | Gradient fallback + logo |
| No categories | Categories section hidden |
| No contacts | Contact row hidden |
| No products | Empty state shown |
| API error | Error state with retry |
| Small screen | 2-column grid |
| Large screen | 4-column grid |
| Long description | Read More/Less toggle |
| Single product image | Display + fallback works |

---

**Status**: ✅ LAYOUT COMPLETE & DOCUMENTED
**Last Updated**: 2026-07-11

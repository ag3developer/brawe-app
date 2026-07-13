# PROFILE SCREEN - QUICK REFERENCE GUIDE

## File Inventory

### Flutter Files
| File | Purpose | Key Classes | Lines |
|------|---------|-------------|-------|
| `lib/ui/profile/widgets/profile_screen.dart` | Main profile UI | `ProfileScreen`, `_ProfileHeader`, `_BannerSection`, `_CompactStats` | 1-1500 |
| `lib/ui/core/view_models/profile_view_model.dart` | State management | `ProfileViewModel` | 1-65 |
| `lib/ui/core/view_models/follow_view_model.dart` | Follow state | `FollowViewModel` | 1-50 |
| `lib/ui/core/ui/follow_button.dart` | Follow button widget | `FollowButton` | 1-50 |
| `lib/data/services/profile_service.dart` | HTTP calls | `ProfileService` | 1-150 |
| `lib/data/repositories/profile_repository.dart` | Data layer | `ProfileRepository` | 1-100 |
| `lib/routing/router.dart` | Routing config | Profile routes | 240-270 |
| `lib/l10n/app_en.arb` | Translations | Profile strings | All |

### Backend Files
| File | Purpose | Key Endpoints | Lines |
|------|---------|---------------|-------|
| `brawe-connect/backend/app/api/v1/profile.py` | Profile API | GET /profile/me, /:userId, /top-streamers | 1-400+ |
| `brawe-connect/backend/app/api/v1/social.py` | Follow API | POST /social/follow, /followers, /following | 1-500+ |
| `brawe-connect/backend/app/api/v1/shopping.py` | Store API | GET /shopping/stores/user/:userId/storefront | 1-500+ |

---

## Component Structure

```
ProfileScreen (userId)
├── _ProfileHeader
│   ├── _BannerSection
│   │   ├── Banner image (if exists)
│   │   ├── Avatar (with story ring)
│   │   └── Edit button (if isMe)
│   ├── Name + Verified badge + Tier badge
│   ├── @username + Join date
│   ├── _CompactStats
│   │   ├── Followers count
│   │   ├── Following count
│   │   └── Total views
│   ├── Bio + Social links
│   └── _buildActions()
│       ├── FollowButton (if !isMe)
│       └── Message Button (if !isMe)
├── TabBar (Posts, Videos, Gallery)
└── TabBarView
    ├── _PostsGrid
    ├── ProfileVideosGrid
    └── ProfileGalleryGrid

AppBar Actions:
├── Back button
├── "@username" title (if !isMe)
├── Find Friends icon (if isMe)
├── Storefront icon (if products.isNotEmpty)
├── Quests icon (if isMe)
├── Notifications icon (if isMe)
├── Wallet icon (if isMe)
└── 3-dot Menu
    └── _showOptions()
        ├── Share Profile (if !isMe)
        ├── Copy Link (if !isMe)
        ├── Block (if !isMe)
        ├── Report (if !isMe)
        ├── Daily Quests (if isMe)
        ├── Creator Program (if isMe)
        ├── Wallet (if isMe && kEnableMonetization)
        ├── Earnings (if isMe && kEnableMonetization)
        ├── Notifications (if isMe)
        ├── Settings (if isMe)
        └── Logout (if isMe)
```

---

## Critical Logic Points

### isMe Flag Decision
```dart
final currentUserId = ref.watch(authStateProvider).value?.id;
final isMe = currentUserId == widget.userId;
```
- **Location:** Line 127 in profile_screen.dart
- **Impact:** Controls entire UI branching

### Profile Endpoint Selection
```dart
final profile = (currentUserId != null && currentUserId == userId)
    ? await repo.getMyProfile()           // GET /profile/me
    : await repo.getUserProfile(userId); // GET /profile/:userId
```
- **Location:** profile_view_model.dart, lines 19-20
- **Impact:** Different endpoints based on isMe

### Store Icon Visibility
```dart
if (products.isNotEmpty)  // Data-driven, not isMe-driven
  IconButton(icon: Icons.storefront, onPressed: () => context.push('/shop/creator/${widget.userId}'))
```
- **Location:** profile_screen.dart, lines 190-200
- **Impact:** Icon shows only if API returns products

### Follow Button (BUG)
```dart
if (isFollowing) {
  return const SizedBox.shrink();  // ❌ WRONG: Should show "Unfollow"
}
return buildFollowButton();  // Only shows when NOT following
```
- **Location:** follow_button.dart, lines 20-25
- **Impact:** Cannot unfollow from button

---

## API Response Schemas

### GET /profile/:userId
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "username": "@handle",
    "display_name": "Full Name",
    "bio": "Bio text",
    "avatar_url": "https://cdn.../avatar.jpg",
    "banner_url": "https://cdn.../banner.jpg",
    "social_links": {},
    "followers_count": 1234,
    "following_count": 567,
    "is_following": false,
    "is_streamer": true,
    "is_verified": true,
    "total_lives": 42,
    "total_viewers": 50000,
    "total_earnings": 5000.00,  // Excluded if viewer != owner
    "level": 5,
    "xp_points": 2500,
    "badges": [],
    "account_type": "creator",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

### POST /social/follow/:userId
```json
{
  "success": true,
  "message": "Seguindo com sucesso"
}
```

### GET /shopping/stores/user/:userId/storefront
```json
{
  "success": true,
  "data": [
    {
      "store_id": "uuid",
      "store_name": "Store Name",
      "store_slug": "slug",
      "products": [
        {
          "id": "product-uuid",
          "name": "Product",
          "slug": "product-slug",
          "price": 99.99,
          "image_url": "https://...",
          "quantity": 1
        }
      ]
    }
  ]
}
```

---

## String Keys (i18n)

| Key | Usage | Value |
|-----|-------|-------|
| `profileEditButton` | Edit button (deprecated, now icon) | "Edit profile" |
| `profileMessageButton` | Message button label | "Message" |
| `profileFollowers` | Stat label | "followers" |
| `profileFollowing` | Stat label | "following" |
| `profileViews` | Stat label | "views" |
| `profileOptionShareProfile` | Menu item | "Share profile" |
| `profileOptionCopyLink` | Menu item | "Copy link" |
| `profileOptionReport` | Menu item | "Report" |
| `profileBlockTitle` | Menu/Dialog title | "Block" |
| `profileBlockBody` | Dialog message | "Are you sure..." |
| `profileReportQuestion` | Report sheet header | "Why are you reporting?" |
| `profileTooltipShop` | Icon tooltip | "Shop" |
| `profileTooltipNotifications` | Icon tooltip | "Notifications" |
| `profileTooltipWallet` | Icon tooltip | "Wallet" |
| `profileTooltipQuests` | Icon tooltip | "Quests" |

---

## Color System

### Theme-Aware (Provider-based)
```dart
context.colors.textPrimary        // Main text
context.colors.textSecondary      // Secondary text
context.colors.textTertiary       // Tertiary text
context.colors.background         // Page bg
context.colors.surfaceElevated    // Buttons, surfaces
context.colors.divider            // Divider lines
context.colors.border             // Borders
context.colors.accentGold         // Creator accent
```

### Hardcoded (Should be migrated)
```dart
AppColors.electricPurple          // Purple accent
AppColors.mutedRed                // Red for logout
Color(0xFFE040FB)                 // Magenta (story ring)
Color(0xFFFF6B35)                 // Orange (story ring)
Color(0xFF7C4DFF)                 // Purple (story ring)
Colors.white24                    // Already-viewed ring
```

---

## Responsive Concerns

| Component | Screen Size | Risk | Note |
|-----------|------------|------|------|
| Avatar overlap | 320px | Medium | `Positioned(bottom: -48)` might clip |
| Stats wrap | 320px | Low | `spacing: 18` might overflow |
| TabBar | 320px | Low | 3 tabs might wrap labels |
| Menu | All | Low | Bottom sheet full width |
| Message button | All | None | Uses Expanded (responsive) |

---

## URL Schemes

### Deep Links
- `/profile/:userId` → ProfileScreen
- `/connect/u/:userId` → ProfileScreen (alias)
- `/shop/creator/:userId` → Shop vitrine page

### Web URLs
- `https://brawe.app/connect/u/:handle` → Profile

---

## State Providers

| Provider | Type | Family Param | Purpose |
|----------|------|-------------|---------|
| `profileViewModelProvider` | StateNotifier | userId | Manages profile data + refresh |
| `followViewModelProvider` | AsyncNotifier | userId | Manages follow state |
| `userStoriesProvider` | FutureProvider | userId | Fetches user stories |
| `storefrontProductsProvider` | FutureProvider | userId | Fetches store products |
| `authStateProvider` | StateNotifier | - | Current user info |
| `profileRepositoryProvider` | Provider | - | Profile data access |
| `socialRepositoryProvider` | Provider | - | Follow/stats access |
| `chatRepositoryProvider` | Provider | - | Chat access |

---

## Known Issues

| Issue | Severity | Root Cause | Location |
|-------|----------|-----------|----------|
| Follow button inverted | HIGH | Logic bug | follow_button.dart:20-25 |
| Story ring colors hardcoded | LOW | No theme migration | profile_screen.dart:1160-1175 |
| Avatar overlap on tiny screens | MEDIUM | Fixed offset | profile_screen.dart:1100 |
| Notification badge hardcoded red | LOW | Not semantic | profile_screen.dart:1110-1125 |

---

## Testing Checklist

- [ ] **Follow:** Tap "Follow" → "Following" → tap again → "Follow"
- [ ] **Unfollow:** Works from Follow button when already following
- [ ] **Message:** Creates conversation correctly
- [ ] **Share:** Native share dialog appears
- [ ] **Copy Link:** Copies correct URL to clipboard
- [ ] **Block:** Shows confirmation dialog
- [ ] **Report:** Shows reason selection sheet
- [ ] **Store Icon:** Shows only when products exist
- [ ] **Menu:** Different items for own vs public
- [ ] **Responsive:** Layout works on 320px, 360px, 380px screens
- [ ] **i18n:** All strings appear translated
- [ ] **Stats:** Click followers/following → opens correct list
- [ ] **Bio:** Renders with line breaks
- [ ] **Social Links:** Icons and links display
- [ ] **Verified Badge:** Shows when applicable
- [ ] **Creator Tier Badge:** Shows correct tier
- [ ] **Stories Ring:** Gradient for unviewed, gray for viewed
- [ ] **Tap Avatar:** Opens story viewer if stories exist
- [ ] **Refresh:** Pull-to-refresh reloads data

---

## Performance Optimizations

✅ **Already Implemented:**
- Batch user queries (no N+1)
- Optimistic UI updates (follow/unfollow)
- FutureProvider auto-refresh behavior
- Lazy-create profiles on first access
- Background tasks for notifications (don't block response)

⚠️ **Potential Improvements:**
- Cache profile data after first load
- Debounce rapid follow/unfollow clicks
- Lazy-load images in gallery/video grids
- Consider pagination on stats lists

---

**Last Updated:** 2026-07-13  
**Status:** Complete - Ready for Implementation

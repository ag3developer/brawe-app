# 🧪 Shop Store Page - Testing Guide

## 📋 Test Cases

### 1. Navigation Tests

#### Test 1.1: Navigate via ProductStoreCard
```
PRECONDITION: App is on a page with ProductStoreCard
ACTION: Click "Ver Loja" button on ProductStoreCard
EXPECTED:
  ✓ Navigate to ShopStorePage
  ✓ URL changes to /shop/store/{storeSlug}
  ✓ Page transitions with slideUp animation
  ✓ Store details load and display
```

#### Test 1.2: Navigate via deep link
```
PRECONDITION: App is at any page
ACTION: Use deep link: /shop/store/brawe-official
EXPECTED:
  ✓ Navigate to ShopStorePage
  ✓ Store "brawe-official" loads correctly
  ✓ All details display properly
```

#### Test 1.3: Back button
```
PRECONDITION: On ShopStorePage
ACTION: Click back button (arrow in AppBar)
EXPECTED:
  ✓ Navigate back to previous page
  ✓ Previous page state restored
```

---

### 2. Data Loading Tests

#### Test 2.1: Load store with complete data
```
PRECONDITION: Network is available
ACTION: Navigate to /shop/store/brawe-official
EXPECTED:
  ✓ Loading spinner appears initially
  ✓ API call: GET /marketplace/affiliate/showcase/brawe-official
  ✓ Response contains: id, name, slug, logo, banners, etc
  ✓ UI renders all elements
  ✓ No errors in console
```

#### Test 2.2: Load store with minimal data
```
PRECONDITION: Store has only required fields
ACTION: Navigate to store
EXPECTED:
  ✓ Page still renders correctly
  ✓ Fallback placeholders show for missing data
  ✓ No crashes or errors
```

#### Test 2.3: API Error handling
```
PRECONDITION: Network error or 404
ACTION: Navigate to store
EXPECTED:
  ✓ Loading spinner shows briefly
  ✓ Error state displays with icon and message
  ✓ "Retry" button appears
  ✓ Click retry attempts request again
```

#### Test 2.4: Load products
```
PRECONDITION: On ShopStorePage with data
ACTION: Page scrolls down to products section
EXPECTED:
  ✓ Loading spinner in products section
  ✓ API call: GET /marketplace/products/store/{storeId}?page=1&limit=20
  ✓ Products grid renders with 2-4 columns (based on screen size)
  ✓ Each product shows: image, name, price, rating
  ✓ No console errors
```

---

### 3. Visual Tests

#### Test 3.1: Banner Display - Single Banner
```
PRECONDITION: Store has 1 banner in banners list
EXPECTED:
  ✓ Banner displays in FlexibleSpaceBar
  ✓ Image fills area (BoxFit.cover)
  ✓ No page indicator dots (single banner)
  ✓ Logo visible as fallback if image fails
```

#### Test 3.2: Banner Display - Multiple Banners
```
PRECONDITION: Store has 3+ banners
EXPECTED:
  ✓ PageView carousel works
  ✓ Page indicator dots appear at bottom
  ✓ Swipe left/right changes banner
  ✓ Dots update to show current page
  ✓ Smooth animation between banners
```

#### Test 3.3: Banner Fallback - No Banners
```
PRECONDITION: Store has no bannerUrl and no banners list
EXPECTED:
  ✓ Gradient background appears (accentPrimary → accentSecondary)
  ✓ Store logo appears centered (if logoUrl exists)
  ✓ Store icon appears if no logo
  ✓ No broken image errors
```

#### Test 3.4: Header Display - All Badges
```
PRECONDITION: Store has isPremium=true and hasBrawePass=true
EXPECTED:
  ✓ Premium badge (👑) displays
  ✓ BrawePass badge (✨) displays
  ✓ Badges have correct colors
  ✓ Badges have correct icons
  ✓ Badges don't overlap with other elements
```

#### Test 3.5: Rating Display
```
PRECONDITION: Store has rating=4.8 and ratingCount=234
EXPECTED:
  ✓ Star icon (⭐) displays
  ✓ Rating number displays correctly (4.8)
  ✓ Review count displays (234 reviews)
  ✓ Colors match theme
```

#### Test 3.6: Categories Display
```
PRECONDITION: Store has categories: ["Electronics", "Games", "Books"]
EXPECTED:
  ✓ Chips display horizontally
  ✓ Each category name visible
  ✓ Horizontal scrolling works
  ✓ Chips have correct styling
  ✓ No text overflow
```

#### Test 3.7: Contact Row Display - All Contacts
```
PRECONDITION: Store has all contact fields populated
EXPECTED:
  ✓ WhatsApp icon (💬) displays with correct color
  ✓ Instagram icon (📷) displays with correct color
  ✓ Facebook icon (👥) displays with correct color
  ✓ TikTok icon (🎵) displays with correct color
  ✓ Email icon (✉️) displays
  ✓ Icons are circular and properly spaced
  ✓ Tooltips show on hover
```

#### Test 3.8: Contact Row Hidden - No Contacts
```
PRECONDITION: Store has all contact fields empty/null
EXPECTED:
  ✓ Contact row section is completely hidden
  ✓ No empty space left where row should be
  ✓ Page layout not affected
```

---

### 4. Responsive Tests

#### Test 4.1: Mobile Layout (< 640px)
```
PRECONDITION: Screen width < 640px
EXPECTED:
  ✓ Product grid shows 2 columns
  ✓ Products not squished or overlapping
  ✓ All text readable
  ✓ Images have correct aspect ratio
  ✓ Touch targets >= 44x44
```

#### Test 4.2: Tablet Layout (640px - 1280px)
```
PRECONDITION: Screen width 640-1280px
EXPECTED:
  ✓ Product grid shows 3 columns
  ✓ Good use of screen space
  ✓ All elements properly spaced
  ✓ Readable on typical tablet
```

#### Test 4.3: Desktop Layout (> 1280px)
```
PRECONDITION: Screen width > 1280px
EXPECTED:
  ✓ Product grid shows 4 columns
  ✓ Optimal use of large screen
  ✓ Well-balanced layout
  ✓ Easy to scan products
```

#### Test 4.4: Orientation Change
```
PRECONDITION: On ShopStorePage
ACTION: Rotate device (portrait ↔ landscape)
EXPECTED:
  ✓ Grid columns update appropriately
  ✓ No layout breaking
  ✓ Content remains visible
  ✓ Scroll position maintained
```

---

### 5. Interaction Tests

#### Test 5.1: Expand/Collapse Description
```
PRECONDITION: Store has long description
ACTION: 
  1. See description truncated to 3 lines
  2. Click "Ler Mais" button
  3. Full description displays
  4. Click "Ler Menos" button
EXPECTED:
  ✓ Description expands smoothly
  ✓ Text fully visible when expanded
  ✓ Button text changes
  ✓ Description collapses back to 3 lines
```

#### Test 5.2: Product Card Click
```
PRECONDITION: On ShopStorePage with products
ACTION: Click on any product card
EXPECTED:
  ✓ Navigate to /shop/product/{productId}
  ✓ Product page loads correctly
  ✓ Product details display
  ✓ No navigation errors
```

#### Test 5.3: Contact Link - WhatsApp
```
PRECONDITION: Store has contactWhatsapp populated
ACTION: Click WhatsApp icon
EXPECTED:
  ✓ URL formatted correctly: wa.me/{digits}
  ✓ Opens WhatsApp in new tab/app
  ✓ No errors launching URL
```

#### Test 5.4: Contact Link - Instagram
```
PRECONDITION: Store has socialInstagram = "@brawe.official"
ACTION: Click Instagram icon
EXPECTED:
  ✓ URL: instagram.com/brawe.official (@ stripped)
  ✓ Opens Instagram in new tab/app
  ✓ Correct profile loads
```

#### Test 5.5: Contact Link - Email
```
PRECONDITION: Store has contactEmail populated
ACTION: Click Email icon
EXPECTED:
  ✓ URL: mailto:contact@brawe.io
  ✓ Opens email client with correct recipient
  ✓ No errors launching URL
```

#### Test 5.6: Retry on Error
```
PRECONDITION: Error state showing
ACTION: Click Retry button
EXPECTED:
  ✓ Loading spinner appears
  ✓ API request retried
  ✓ Data loads if network restored
  ✓ Error state clears on success
```

---

### 6. Security Tests

#### Test 6.1: Affiliate Commission Not Visible
```
PRECONDITION: Store object has defaultAffiliateCommission
ACTION: Inspect page HTML/DOM
EXPECTED:
  ✓ defaultAffiliateCommission NOT displayed anywhere
  ✓ No text showing "10.5%" or similar
  ✓ No reference to commission in UI
  ✓ Only visible in DevTools if debugging
```

#### Test 6.2: Private Data Not Visible
```
PRECONDITION: Store object has sensitive fields
ACTION: View page source / inspect element
EXPECTED:
  ✓ applicationStatus not visible to buyer
  ✓ applicationId not visible
  ✓ storeResponse not visible (only for store owner)
  ✓ Public data only: name, logo, description, products, etc
```

---

### 7. Edge Case Tests

#### Test 7.1: Empty Products List
```
PRECONDITION: Store has totalProducts=0
ACTION: Navigate to store
EXPECTED:
  ✓ Products section displays "empty" state
  ✓ Package icon (📦) displays
  ✓ Message: "Nenhum produto disponível"
  ✓ No grid, no crash
```

#### Test 7.2: Store with No Logo
```
PRECONDITION: Store has logoUrl=null
EXPECTED:
  ✓ Header still displays
  ✓ Placeholder icon appears instead
  ✓ No broken image icon
  ✓ Layout not affected
```

#### Test 7.3: Product with No Image
```
PRECONDITION: Product has imageUrl=null and images=[]
EXPECTED:
  ✓ Product card displays
  ✓ Placeholder with image icon appears
  ✓ Name and price still visible
  ✓ No broken image error
```

#### Test 7.4: Very Long Store Name
```
PRECONDITION: Store name is very long (50+ chars)
ACTION: Navigate to store
EXPECTED:
  ✓ Name displayed with ellipsis/truncation
  ✓ No layout breaking
  ✓ Readable (max 2 lines in header)
  ✓ Title in AppBar also truncated
```

#### Test 7.5: Store with No Description
```
PRECONDITION: Store has description=""
EXPECTED:
  ✓ Description section hidden
  ✓ No empty space
  ✓ Other sections display normally
```

#### Test 7.6: Store with No Categories
```
PRECONDITION: Store has categories=[]
EXPECTED:
  ✓ Categories section hidden
  ✓ Header still displays normally
  ✓ No layout issues
```

---

### 8. Performance Tests

#### Test 8.1: Initial Load Time
```
ACTION: Navigate to store
EXPECTED:
  ✓ Loading spinner appears within 100ms
  ✓ API response within 2 seconds (typical)
  ✓ UI renders within 100ms of response
  ✓ No jank or stutter
```

#### Test 8.2: Scroll Performance
```
PRECONDITION: On store page with many products
ACTION: Scroll up/down rapidly
EXPECTED:
  ✓ 60 FPS smooth scrolling
  ✓ No dropped frames
  ✓ Images lazy load efficiently
  ✓ No memory leaks
```

#### Test 8.3: Image Loading
```
PRECONDITION: On store page
EXPECTED:
  ✓ Banner image loads quickly
  ✓ Logo loads quickly
  ✓ Product images load progressively
  ✓ Placeholders show while loading
  ✓ Error widget if network fails
```

#### Test 8.4: State Management
```
ACTION: Navigate away and back to store
EXPECTED:
  ✓ Provider properly invalidates on load
  ✓ Fresh data loaded (not stale cache)
  ✓ No memory leaks from providers
  ✓ Widgets dispose properly
```

---

### 9. Theme Tests

#### Test 9.1: Light Theme
```
PRECONDITION: App in light theme
EXPECTED:
  ✓ All colors use light theme colors
  ✓ Text readable on light background
  ✓ Good contrast ratios
  ✓ Icons visible
```

#### Test 9.2: Dark Theme
```
PRECONDITION: App in dark theme
EXPECTED:
  ✓ All colors use dark theme colors
  ✓ Text readable on dark background
  ✓ Good contrast ratios
  ✓ Icons visible
```

#### Test 9.3: Theme Switching
```
PRECONDITION: On store page
ACTION: Toggle between light/dark theme
EXPECTED:
  ✓ Page updates immediately
  ✓ All elements recolor correctly
  ✓ No layout breaking
  ✓ Smooth transition
```

---

### 10. Localization Tests

#### Test 10.1: PT-BR Strings
```
PRECONDITION: App language set to Portuguese (BR)
EXPECTED:
  ✓ "Ver Loja" button displays
  ✓ "Ler Mais" / "Ler Menos" display
  ✓ "Produtos" section header
  ✓ "Seção de Contato" header
  ✓ Error messages in Portuguese
```

#### Test 10.2: EN-US Strings
```
PRECONDITION: App language set to English (US)
EXPECTED:
  ✓ "View Store" button displays
  ✓ "Read More" / "Read Less" display
  ✓ "Products" section header
  ✓ "Contact Section" header
  ✓ Error messages in English
```

---

## 🧬 Test Data

### Sample Store JSON
```json
{
  "id": "store-123",
  "name": "Brawe Official Store",
  "slug": "brawe-official",
  "description": "Premium electronics and gadgets from Brawe.",
  "logo_url": "https://api.brawe.io/files/stores/brawe-official/logo.png",
  "banner_url": "https://api.brawe.io/files/stores/brawe-official/banner.jpg",
  "banners": [
    {
      "id": "banner-1",
      "image_url": "https://api.brawe.io/files/stores/brawe-official/banner1.jpg",
      "title": "Summer Sale",
      "subtitle": "Up to 50% off",
      "link_url": "/",
      "link_text": "Shop Now",
      "position": 1
    }
  ],
  "currency": "BRL",
  "default_affiliate_commission": 10.5,
  "total_products": 150,
  "total_orders": 5000,
  "total_sales": 500000.00,
  "rating": 4.8,
  "rating_count": 234,
  "is_premium": true,
  "has_brawe_pass": true,
  "contact_email": "contact@brawe.io",
  "contact_whatsapp": "(11) 98765-4321",
  "social_instagram": "@brawe.official",
  "social_facebook": "brawe.official",
  "social_tiktok": "@brawe",
  "categories": ["Electronics", "Games", "Gadgets"],
  "created_at": "2024-01-15T10:30:00Z"
}
```

### Sample Products JSON
```json
{
  "items": [
    {
      "id": "prod-1",
      "name": "Headphones Pro",
      "price": "299.90",
      "image_url": "https://api.brawe.io/files/products/headphones.jpg",
      "images": [],
      "category_name": "Electronics",
      "quantity": 50,
      "rating": 4.5,
      "rating_count": 45,
      "total_sold": 230,
      "store_id": "store-123",
      "store_name": "Brawe Official",
      "store_slug": "brawe-official"
    }
  ],
  "total": 1,
  "page": 1,
  "per_page": 20,
  "pages": 1
}
```

---

## ✅ Pre-Test Checklist

- [ ] Device/emulator has internet connection
- [ ] Backend services are running
- [ ] API endpoints are responding
- [ ] Test data is populated in database
- [ ] App is built for current platform (iOS/Android/Web)
- [ ] No previous state cached from old builds
- [ ] Theme is set to expected value
- [ ] Locale is set to expected language
- [ ] DevTools are available for debugging
- [ ] Network inspector is ready for monitoring API calls

---

## 📸 Screenshots to Take

1. [ ] Store page on mobile (2 columns)
2. [ ] Store page on tablet (3 columns)
3. [ ] Store page on desktop (4 columns)
4. [ ] Banner carousel with multiple banners
5. [ ] Store header with all badges
6. [ ] Contact row with all 5 icons
7. [ ] Loading state (spinner)
8. [ ] Error state (error icon + retry button)
9. [ ] Empty products state
10. [ ] Product card detail

---

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Products not loading | Check storeId in provider matches API call |
| Banners not showing | Verify banners array has items + imageUrl |
| Contact links not working | Check URL formatting + launchUrl permission |
| Layout breaking on small screen | Verify responsive grid logic (2/3/4 cols) |
| Images not caching | Check CachedNetworkImage configuration |
| Theme colors wrong | Verify context.colors are correct extensions |
| Scroll jank | Check image sizes optimized + lazy loading |
| Memory leak | Verify providers invalidated + disposed |

---

## 📊 Test Coverage

- Unit Tests: Page widget tests
- Widget Tests: Individual component tests
- Integration Tests: Navigation + API flows
- E2E Tests: Full user journey
- Performance Tests: Load times + scroll smoothness
- Security Tests: No sensitive data exposed
- Accessibility Tests: Touch targets + contrast
- Localization Tests: Multiple languages

---

**Test Status**: Ready for execution
**Last Updated**: 2026-07-11

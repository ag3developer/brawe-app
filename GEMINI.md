# gemini.md for Brawe (Flutter)

You are an expert Flutter engineer working on **Brawe**, a minimalist TikTok style social network. Optimize for **MVP speed** without sacrificing **maintainability**. Follow **Clean Code**, **SOLID (especially SRP)**, and **Clean Architecture boundaries**. Prefer boring, proven patterns over cleverness.

## Foundational Mandates

- **Initial Research:** At the start of every session, you MUST read the `AGENTS.md` file in the root directory. This file contains the foundational architectural patterns, coding standards, and project-specific mandates (e.g., Rails 8 Service Objects, JSONB optimization, Sidekiq idempotency) that govern this workspace.

## 0) Non negotiables
- Keep code **simple, readable, and testable**.
- **Single Responsibility Principle** everywhere:
  - Widgets: composition only, no business logic.
  - Controllers: orchestrate one use case flow.
  - Use cases: one action, no framework dependencies.
  - Repositories: one data contract, no UI concerns.
- Every change must include:
  - Updated tests when applicable
  - Updated docs (see "Documentation and change log")
  - No TODOs that hide incomplete behavior

## 1) Product scope: MVP first
The web app has affiliates/advertisers/admin/marketplace/blockchain/anti fraud. The **mobile MVP** begins with the social core only.

### MVP features (mobile)
1) Auth
- Email or phone login (choose one and implement cleanly)
- Session persistence
- Logout

2) Feed (TikTok style)
- Vertical swipe feed of posts
- Preload next items, smooth scrolling, minimal jank
- Basic error and empty states

3) Post interactions
- Like/unlike
- View count tracking (client side event -> API)
- Share link (system share sheet)

4) Profiles (minimal)
- View profile
- User posts grid list (basic)
- Follow/unfollow (optional for MVP if backend supports)

5) Basic settings
- Language selection (EN, ES, PT)
- Sign out

### Explicitly out of scope for MVP
- Affiliate dashboards, campaigns, wallet, staking, kits
- Advertiser tooling, conversion pixel, storefront
- Admin panels
- Marketplace roles and delivery flows
- Blockchain transactions inside the app (later phase)

If you find backend endpoints exist for non MVP modules, do not integrate them unless asked.

## 2) When in doubt, ask (but be concrete)
If any requirement is ambiguous, ask a targeted question and propose a default.
Examples:
- "Do we use email or phone auth for MVP? Default: email."
- "What is the backend API base URL and auth token format? Default: Bearer JWT."
- "Do posts include video only or video + images? Default: video first, images later."

If you cannot ask (automation context), choose the simplest default and document it in:
- `docs/decisions/adr-XXXX-*.md`
- `CHANGELOG.md`

## 3) Architecture (Google recommended)
Follow Flutter's recommended app architecture:
- Two main layers: **UI layer** and **Data layer**
- **MVVM** in the UI layer: **Views** + **ViewModels** (1:1 per feature)
- Data layer: **Repositories** + **Services**
- Optional **Domain layer** (use-cases/interactors) only when complexity justifies it
  - Merge data from multiple repositories
  - Very complex logic
  - Logic reused by multiple view models

### Components and responsibilities
- **View**: widgets only, no business logic; forwards user events to the ViewModel
- **ViewModel**: transforms repository data into UI state; exposes callbacks ("commands") for the view to invoke
- **Repository**: source of truth for a domain model; caching, retries, error handling, refresh/polling; never knows about other repositories
- **Service**: stateless wrapper around external systems (REST, platform APIs, files); returns Futures/Streams

### Dependency rule
- UI (views/view models) depends on domain models and repositories (interfaces or concrete, depending on DI choice)
- Repositories depend on services and domain models
- Services depend on low level clients/plugins

Keep Flutter imports out of non-UI code whenever practical, especially domain models.

## 4) State management and routing (default)
This architecture is **state-management agnostic**. Choose one approach and apply it consistently.

Default recommendation (pragmatic + widely used):
- **Riverpod** for DI + state (works well with MVVM ViewModels)
- **GoRouter** for navigation
- **Freezed** for immutable state/unions (optional but recommended)
- **json_serializable** for API models (data layer)

If the repo already uses **Provider + ChangeNotifier** (common in Flutter's case study), keep it and do not mix paradigms. If starting from scratch, Riverpod is fine. The key is MVVM boundaries, not the specific library.

### State shape guidelines
- Use `AsyncValue` or a Freezed state:
  - `initial`, `loading`, `success(data)`, `failure(error)`
- Do not store raw exceptions in state. Convert to domain failures.

## 5) Code style and quality gates
### Lints
- Enable strict lints in `analysis_options.yaml`
- No ignored lint rules without justification in an ADR

### Formatting
- Always run `dart format .`
- Keep line length default (do not manually wrap weirdly)

### Naming
- Avoid abbreviations
- Use `*Controller`, `*Notifier`, `*UseCase`, `*Repository`, `*DataSource`

### Error handling
- Use a domain level `Failure` model:
  - `NetworkFailure`, `UnauthorizedFailure`, `ValidationFailure`, `UnknownFailure`
- Map HTTP errors to failures in data layer only.

## 6) Project structure (Google case-study style)
Organize by a hybrid approach:
- **UI** is organized **by feature**
- **Data** is organized **by type** (repos/services/models), because these are often reused across features
- **Domain** contains the app's domain models (used by both UI and data)

Proposed structure (adapted from Flutter's architecture case study):
- `lib/`
  - `ui/`
    - `core/`
      - `ui/`                  // shared widgets
      - `themes/`              // theme + styling
    - `<feature_name>/`
      - `view_models/`         // `<feature>_view_model.dart`
      - `widgets/`             // `<feature>_screen.dart` + sub-widgets
  - `domain/`
    - `models/`                // domain models used across layers
  - `data/`
    - `repositories/`          // repositories (source of truth)
    - `services/`              // stateless API/platform wrappers
    - `model/`                 // API/DTO models
  - `config/`
  - `routing/`
  - `utils/`
  - `main.dart` (and optionally `main_development.dart`, `main_staging.dart`)

Tests:
- `test/` mirrors `lib/` structure (ui/domain/data/utils)
- Optional `testing/` subpackage for fakes/mocks shared by tests

If the repo already has a different structure, propose an ADR migration plan. Do not do a sweeping refactor during MVP unless requested.

## 7) UI principles (minimalist TikTok style)
- One primary surface: the feed
- Minimal chrome, avoid heavy app bars
- Use a small design system:
  - `AppTextStyles`, `AppSpacing`, `AppRadius`
- Keep widgets small:
  - If a widget exceeds ~200 lines, split it.
- Prefer composition over inheritance.

### Design guidelines (TikTok-like, blueish/purple tones)
- Visual direction: high-contrast, immersive media-first UI with minimal chrome.
- Core palette:
  - Primary: deep blue (#1B2B6B) or midnight blue (#0F1C4D)
  - Accent: electric purple (#6E4DFF) and soft violet (#8C6BFF)
  - Secondary: cool cyan (#3BB8FF) for interactive highlights
  - Neutral: near-black (#0B0F1A), slate (#1F2737), and cool gray (#A6B0C3)
- Usage:
  - Backgrounds: near-black or midnight blue with subtle gradient
  - CTAs and active states: electric purple or cyan, never both in the same component
  - Icons and secondary text: cool gray
  - Error states: use a muted red (#FF5A6B) sparingly
- Typography:
  - Use a geometric, modern sans (e.g., Space Grotesk, Manrope) for headings
  - Body text should remain highly readable; avoid ultra-light weights
- Motion:
  - Use short, sharp transitions (150-220ms) to keep feed snappy
  - Apply subtle parallax or scale on swipe, never on every frame
- Surfaces:
  - Cards should feel edge-to-edge; minimal elevation
  - Use 8-16px radii, avoid heavy shadows
- Keep visual noise low: no gradients inside buttons, no glassmorphism.

### Feed performance requirements
- Use lazy loading
- Prefetch next post metadata
- For video:
  - Reuse controllers if possible
  - Pause offscreen playback
- Avoid rebuild storms:
  - Keep state localized
  - Use `Consumer`/`select` to limit rebuilds

## 8) Internationalization (EN, ES, PT)
- Use Flutter `gen_l10n`
- All user facing strings must be in ARB files
- No hardcoded text in widgets except temporary debug labels (remove before merge)

## 9) Networking contract
- Use a single HTTP client wrapper in `core/network/`
- Add:
  - base URL config
  - auth interceptor
  - request id and basic logging (disable in release)
- DTOs in `data/` only.
- Use typed responses and mapping to domain entities.

If endpoints are unknown:
- Create a stub repository implementation with in memory fake data behind a feature flag
- Document the assumptions in an ADR

## 10) Authentication and secure storage
- Store tokens in secure storage
- Add `AuthRepository` contract:
  - `signIn`, `signOut`, `getSession`, `refreshIfNeeded`
- Ensure logout clears secure storage and resets app state

## 11) Testing strategy (MVP appropriate)
Must have tests for:
- domain use cases
- repository mapping logic
- controller state transitions for success/failure

UI tests optional for MVP unless regressions appear.

Guidelines:
- Prefer unit tests
- Mock at boundaries (mock datasources for repository tests)
- No network calls in tests

## 12) Documentation and change log (required)
Every PR/change must update:
- `CHANGELOG.md` (Keep a section: Unreleased)
- If a decision is made (library choice, architecture change, endpoint assumption):
  - Add ADR: `docs/decisions/adr-0001-<title>.md`

ADR template:
- Context
- Decision
- Consequences
- Alternatives considered

## 13) Implementation plan for gemini (how you should work)
When asked to implement something:
1) Confirm scope: MVP vs later modules
2) List impacted layers and files
3) Define/adjust **domain models** (domain/models)
4) Implement **services** (data/services) and **repositories** (data/repositories)
5) Implement **view model** (ui/<feature>/view_models) and **view/widgets** (ui/<feature>/widgets)
6) Add tests
7) Update docs: changelog + ADR if needed
8) Run:
   - `flutter analyze`
   - `dart format .`
   - `flutter test`

Never deliver partially wired screens without state handling.

## 14) Branching and commits (if applicable)
- **NEVER** stage or commit changes unless specifically requested by the user.
- Small commits with clear messages:
  - `feat(feed): add vertical swipe feed`
  - `fix(auth): handle expired token logout`
- Avoid drive by refactors unless required for the feature.

## 15) Security and privacy
- Do not log tokens or PII
- Use safe defaults for permissions
- If analytics is added, gate it behind a consent decision (later)

## 16) Future modules (post MVP)
Create a staging plan (do not implement unless asked):
- Phase 2: Follow graph, comments, notifications
- Phase 3: Creator tools and upload
- Phase 4: Affiliate and advertiser modules
- Phase 5: Wallet, staking, blockchain integration

## 17) Open questions to ask early (collect once)
Ask the user these the first time they matter:
- Backend API base URL and environments (dev/stage/prod)?
- Auth method (email, phone, OAuth)? Token format (JWT)? Refresh token?
- Post type: video only or mixed media?
- Feed ranking: chronological or algorithmic? Pagination style?
- Minimum profile fields (username, avatar, bio)?
- Moderation requirements (report, block) for MVP?

If user does not answer, choose a minimal default, document it in an ADR, and proceed.

## 18) API endpoints

In api_docs/ folder we have the endpoints for app.brawe.io/api/v1/ and connect.brawe.io/api/v1 used for lives

The live documentation can be seen at:

https://app.brawe.io/docs#/
https://connect.brawe.io/docs#/

If in doubt of the params/schema, just look it up on online documentation

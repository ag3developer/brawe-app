# Changelog

## Unreleased
- Move live initiation entrypoint to Home bottom navigation and remove `Go Live` button from Live feed screen.
- Add a Live feed category switch (`For You` and `All Lives`) in the live view.
- Wire `For You` category to `GET /api/v1/live/feed` and `All Lives` to `GET /api/v1/live/rooms`.
- Add a full "Go Live" initiation flow with a dedicated `StartLiveScreen` and `StartLiveViewModel`.
- Implement live room creation and start actions in `LiveService` and `LiveRepository` using `POST /live/rooms` and `POST /live/rooms/{room_id}/start`.
- Add resilient live-response parsing to handle multiple backend payload shapes when creating/starting a live.
- Add route `/live/start` and a `Go Live` CTA in the live feed.
- Add unit tests for live initiation repository logic and start-live view model success/failure transitions.
- Implement Regular Social Feed (TikTok-style) using vertical `PageView` for immersive browsing.
- Introduce `Post` and `PostAuthor` domain models with corresponding `PostResponseDto` and `PostFeedResponseDto` mapping.
- Implement `PostService` and `PostRepository` to handle social feed fetching, post liking, and view tracking.
- Create `FeedViewModel` with optimistic updates for likes to ensure a snappy user experience.
- Refactor `HomeScreen` top bar into a cleaner, minimalist layout, moving profile details to an interactive bottom sheet.
- Synchronize local user sessions with the backend on app launch to ensure up-to-date profile data.
- Connect to `connect.brawe.io/api/v1` Live API by adding `liveDioProvider`.
- Introduce `LiveRoom` domain model and `LiveRoomDto` mapping.
- Implement `LiveService` and `LiveRepository` for fetching the Live Feed.
- Create a TikTok-style `LiveFeedScreen` and `LiveFeedViewModel`.
- Add `/live` route to handle live streaming module navigation.
- Add a comprehensive discovery-style Home screen with live stream battles, top streamers, categories, and commerce sections.
- Replace starter counter app with a TikTok-style feed landing screen.
- Add core UI theme, colors, spacing, and typography helpers.
- Add an email login screen with a simple MVVM view model and styling.
- Refresh login screen with a modern, minimal card layout.
- Add logo image to the login card header.
- Replace login background circles with a modern grid/diagonal texture.

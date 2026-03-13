# ADR 0003: Live Streaming Integration (Playback and Broadcasting)

## Context
The live streaming feature was not functional. The backend (Brawe Connect via Mux) requires:
1. HLS playback for viewers.
2. Socket.IO connection for real-time events (chat, viewer count).
3. RTMP for broadcasters.

## Decision
We have decided to:
1. **Separate Modules**: Split the live functionality into `live_feed` (watching) and `broadcaster` (going live) to avoid dependency conflicts and improve maintainability.
2. **Playback**: Use `video_player` for HLS playback with optimized `VideoPlayerOptions` (mixWithOthers).
3. **Resilient URL**: Construct the Mux HLS URL (`stream.mux.com`) from `playbackId` as a fallback.
4. **Broadcasting**: Use `rtmp_broadcaster` for in-app RTMP broadcasting. While `apivideo_live_stream` was initially considered, `rtmp_broadcaster` provides better control over the camera preview aspect ratio (Scale & Crop) and alignment with the standard Flutter `camera` plugin API, which is essential for the TikTok-style immersive UI.
5. **Real-time**: Use `socket_io_client` (^3.1.4) and a centralized `SocketService`.
6. **Device State**: Use `wakelock_plus` to prevent screen timeout.
7. **Permissions**: Use `permission_handler` to explicitly manage camera and microphone access.

## Consequences
- **Positive:**
  - Full end-to-end live flow aligned with Mux recommendations.
  - Simplified RTMP state management with native success/fail callbacks.
  - Native camera preview feedback is correctly displayed using `ApiVideoCameraPreview`.
  - Cleaner architecture with separated UI modules.
- **Neutral:**
  - Replaces `rtmp_broadcaster` which was a fork of the standard camera plugin.
- **Negative:**
  - Project still cannot include the standard `camera` package simultaneously with the streaming plugin due to potential namespace conflicts.

## Alternatives Considered
- `rtmp_broadcaster`: Initially implemented but required more manual handling of RTMP statistics and state than `apivideo_live_stream`.
- `haishinkit` (direct): Too low-level for the current MVP speed requirement.
- `webviewx` (mux_player): Rejected to maintain a native UI and better performance.

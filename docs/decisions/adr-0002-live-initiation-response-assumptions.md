# ADR-0002: Live Room Creation Contract for Broadcast Start

## Context
The Connect integration docs were updated on March 8, 2026. The broadcaster
flow now starts by creating a room with `POST /api/v1/live/rooms`, receiving
`stream_config` credentials, and then going live when RTMP publishing starts.
The `/live/rooms/{room_id}/start` step is no longer part of the documented
contract. The mobile MVP needs a reliable room creation flow aligned with this
backend behavior.

## Decision
`LiveRepository.initiateLive` now performs a single create-room call and does
not invoke `/start`. Parsing remains defensive for the create response:
- direct room object (`id`, `title`, etc.)
- nested object (`room`, `live`, `data`, `result`, `payload`)
- fallback identifiers (`room_id`, `live_id`)

Stream playback URL is extracted from either top-level keys
(`stream_url`, `hls_url`, `playback_url`) or `stream_config.playback_url`.
Broadcast setup credentials are extracted from `stream_config.rtmp_url` and
`stream_config.stream_key`.
Default room status for inferred payloads is `waiting`.

## Consequences
- The app behavior matches the new backend room-first contract.
- Mobile can surface room readiness before RTMP publish starts.
- Parsing complexity stays isolated in the repository (data layer boundary).

## Alternatives considered
- Keep calling `/live/rooms/{room_id}/start` (would fail with updated backend).
- Hard-fail on non-strict payload shape (would reduce MVP robustness).

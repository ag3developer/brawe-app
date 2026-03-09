# ADR-0002: Live Initiation Response Parsing Assumptions

## Context
The Connect API documents `POST /api/v1/live/rooms` and
`POST /api/v1/live/rooms/{room_id}/start` but both responses are defined as a
generic object without a concrete schema. The mobile MVP needs a reliable
"initiate live" flow now.

## Decision
Implement defensive parsing in `LiveRepository.initiateLive` for multiple
response shapes:
- direct room object (`id`, `title`, etc.)
- nested room object (`room`, `live`, `data`, `result`, `payload`)
- fallback identifiers (`room_id`, `live_id`)

If start response does not return a full room payload, keep the created room and
force status to `live`, optionally extracting stream URL from known keys
(`stream_url`, `hls_url`, `playback_url`).

## Consequences
- The app can start lives even while backend response contracts are still loose.
- Parsing complexity is isolated to the repository (data layer boundary).
- If backend finalizes a strict schema, this fallback logic should be simplified.

## Alternatives considered
- Blocking feature implementation until strict response schemas are available.
- Hard-failing on unknown payload shape (would reduce robustness for MVP).

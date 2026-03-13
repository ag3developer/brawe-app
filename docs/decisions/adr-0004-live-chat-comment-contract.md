# ADR-0004: Live Chat Comment Contract

## Context

The mobile live viewer experience needed an in-stream comment box and visible live chat messages. The backend documentation available in `docs/backend_live/NATIVE_APP_INTEGRATION.md` documents Socket.IO events for live chat (`chat_message` and `new_message`) but does not define a REST endpoint for fetching or posting live comments.

## Decision

Use the Brawe Connect Socket.IO contract as the source of truth for live comments in the mobile MVP.

- Join the live room through `join_room`.
- Send comments through `chat_message` with `{ room_id, message }`.
- Render incoming comments from `new_message`.
- Render live viewer count updates from `viewer_count`.
- Keep chat state room-scoped in the UI layer via a dedicated live comments view model.

## Consequences

- Live comments are real-time only for the MVP and do not include message history hydration from REST.
- The live screen must keep socket subscriptions scoped to the active room to avoid cross-room event leakage.
- If the backend later adds comment history or room-specific event payloads, the repository can be extended without changing the widget contract.

## Alternatives Considered

- Add a temporary fake local comment system.
- Poll a REST endpoint for comments despite no documented backend contract.
- Handle socket events directly in widgets without a repository/view model boundary.

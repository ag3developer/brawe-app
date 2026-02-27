# ADR-0001: Email Authentication for MVP

## Context
The MVP needs an authentication entry point. No backend auth contract has been
provided yet, but the UI and state flow need a default to proceed.

## Decision
Use **email + password** as the MVP authentication method.

## Consequences
- Login UI and validation are built around email/password inputs.
- Backend integration can later map to the email auth endpoint.

## Alternatives considered
- Phone/SMS login (would require additional UX and backend contracts).
- OAuth/social login (adds complexity and dependencies for MVP).

# 🏗️ ARQUITETURA DE CO-HOST - DIAGRAMAS

---

## 1️⃣ ARQUITETURA GERAL (Frontend + Backend)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃                   FLUTTER (BRAWE-APP)                     ┃
┃                                                           ┃
┃  ┌──────────────────────────────────────────────────┐   ┃
┃  │  UI Layer                                        │   ┃
┃  │  ┌────────────────────────────────────────────┐  │   ┃
┃  │  │ broadcaster_screen.dart                    │  │   ┃
┃  │  │ • _showCoHostSheet()                       │  │   ┃
┃  │  │ • ListView com followers                  │  │   ┃
┃  │  │ • Botão "Enviar Convite"                  │  │   ┃
┃  │  │ • "Como funciona" com emojis              │  │   ┃
┃  │  └────────────────────────────────────────────┘  │   ┃
┃  │  ┌────────────────────────────────────────────┐  │   ┃
┃  │  │ live_action_bar.dart                       │  │   ┃
┃  │  │ • Botão "Co-host" (Icons.people_alt)     │  │   ┃
┃  │  │ • Color: blue quando clicado              │  │   ┃
┃  │  └────────────────────────────────────────────┘  │   ┃
┃  └──────────────────────────────────────────────────┘   ┃
┃                       ▲                                   ┃
┃                       │ (UI Updates)                      ┃
┃                       │                                   ┃
┃  ┌──────────────────────────────────────────────────┐   ┃
┃  │  State Management (Riverpod)                     │   ┃
┃  │  ┌────────────────────────────────────────────┐  │   ┃
┃  │  │ coHostEligibilityProvider                  │  │   ┃
┃  │  │ followersOnlineProvider                    │  │   ┃
┃  │  │ coHostInviteNotifier                       │  │   ┃
┃  │  │ socketEventsProvider                       │  │   ┃
┃  │  └────────────────────────────────────────────┘  │   ┃
┃  └──────────────────────────────────────────────────┘   ┃
┃                       ▲                                   ┃
┃                       │ (State changes)                   ┃
┃                       │                                   ┃
┃  ┌──────────────────────────────────────────────────┐   ┃
┃  │  Repository Layer                                │   ┃
┃  │  ┌────────────────────────────────────────────┐  │   ┃
┃  │  │ live_repository.dart                       │  │   ┃
┃  │  │ • checkCoHostEligibility()                 │  │   ┃
┃  │  │ • fetchFollowersOnline()                   │  │   ┃
┃  │  │ • inviteCoHost()                           │  │   ┃
┃  │  │ • acceptCoHostInvite()                     │  │   ┃
┃  │  │ • leaveCoHost()                            │  │   ┃
┃  │  └────────────────────────────────────────────┘  │   ┃
┃  │  ┌────────────────────────────────────────────┐  │   ┃
┃  │  │ socket_service.dart                        │  │   ┃
┃  │  │ • socket.on('cohost_invite')               │  │   ┃
┃  │  │ • socket.on('cohost_accepted')             │  │   ┃
┃  │  │ • socket.on('screen_split_ready')          │  │   ┃
┃  │  │ • socket.on('cohost_left')                 │  │   ┃
┃  │  └────────────────────────────────────────────┘  │   ┃
┃  └──────────────────────────────────────────────────┘   ┃
┗━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
               │ HTTP REST + WebSocket
               │ (Dio + Socket.IO)
┏━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃          BACKEND (BRAWE-CONNECT / FastAPI)             ┃
┃                                                       ┃
┃  ┌──────────────────────────────────────────────┐   ┃
┃  │  API Routes (live.py)                        │   ┃
┃  │  ┌────────────────────────────────────────┐  │   ┃
┃  │  │ GET  /cohost/eligibility               │  │   ┃
┃  │  │ Returns: can_invite_cohost, tier, etc  │  │   ┃
┃  │  └────────────────────────────────────────┘  │   ┃
┃  │  ┌────────────────────────────────────────┐  │   ┃
┃  │  │ GET  /followers/online  ❌ FALTA       │  │   ┃
┃  │  │ Returns: list of followers              │  │   ┃
┃  │  └────────────────────────────────────────┘  │   ┃
┃  │  ┌────────────────────────────────────────┐  │   ┃
┃  │  │ POST /cohost/invite                    │  │   ┃
┃  │  │ Input: guest_user_id                   │  │   ┃
┃  │  │ Emits: cohost_invite Socket.IO event   │  │   ┃
┃  │  └────────────────────────────────────────┘  │   ┃
┃  │  ┌────────────────────────────────────────┐  │   ┃
┃  │  │ POST /cohost/accept                    │  │   ┃
┃  │  │ Emits: cohost_accepted Socket.IO       │  │   ┃
┃  │  └────────────────────────────────────────┘  │   ┃
┃  │  ┌────────────────────────────────────────┐  │   ┃
┃  │  │ POST /cohost/leave                     │  │   ┃
┃  │  │ Emits: cohost_left Socket.IO           │  │   ┃
┃  │  └────────────────────────────────────────┘  │   ┃
┃  └──────────────────────────────────────────────┘   ┃
┃                      ▲                                ┃
┃                      │                                ┃
┃  ┌──────────────────────────────────────────────┐   ┃
┃  │  Business Logic (Services)                  │   ┃
┃  │  ┌────────────────────────────────────────┐  │   ┃
┃  │  │ streamer_eligibility.py                │  │   ┃
┃  │  │ • checkEligibility()                   │  │   ┃
┃  │  │ • Regras: tier ≥ CREATOR, 500 followers│  │   ┃
┃  │  └────────────────────────────────────────┘  │   ┃
┃  │  ┌────────────────────────────────────────┐  │   ┃
┃  │  │ cohost_service.py                      │  │   ┃
┃  │  │ • createInvite()                       │  │   ┃
┃  │  │ • acceptInvite()                       │  │   ┃
┃  │  │ • endCohost()                          │  │   ┃
┃  │  └────────────────────────────────────────┘  │   ┃
┃  │  ┌────────────────────────────────────────┐  │   ┃
┃  │  │ notification_service.py                │  │   ┃
┃  │  │ • sendCoHostInvite()                   │  │   ┃
┃  │  └────────────────────────────────────────┘  │   ┃
┃  └──────────────────────────────────────────────┘   ┃
┃                      ▲                                ┃
┃                      │                                ┃
┃  ┌──────────────────────────────────────────────┐   ┃
┃  │  Database & Cache                           │   ┃
┃  │  ┌────────────────────────────────────────┐  │   ┃
┃  │  │ PostgreSQL                             │  │   ┃
┃  │  │ • users table                          │  │   ┃
┃  │  │ • user_follows table                   │  │   ┃
┃  │  │ • user_stats table                     │  │   ┃
┃  │  │ • cohost_invites table                 │  │   ┃
┃  │  │ • live_rooms table                     │  │   ┃
┃  │  └────────────────────────────────────────┘  │   ┃
┃  │  ┌────────────────────────────────────────┐  │   ┃
┃  │  │ Redis (Real-time)                      │  │   ┃
┃  │  │ • Active users cache                   │  │   ┃
┃  │  │ • Live room participants               │  │   ┃
┃  │  └────────────────────────────────────────┘  │   ┃
┃  └──────────────────────────────────────────────┘   ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

---

## 2️⃣ FLUXO DE DADOS (Sequência)

### Caso A: Streamer Clica em "Co-host"

```
┌─────────────────────────────────────────────────────────┐
│ Step 1: UI Trigger                                      │
│ User taps "Co-host" button in live_action_bar.dart     │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Step 2: Show Bottom Sheet                               │
│ _showCoHostSheet() opens BottomSheet widget             │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Step 3: Check Eligibility (ASYNC)                       │
│ ref.read(coHostEligibilityProvider).fetch()             │
│   → GET /cohost/eligibility                             │
└───────────────────────┬─────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
   ELIGIBLE                         NOT ELIGIBLE
        │                               │
        ▼                               ▼
┌──────────────────┐        ┌──────────────────────┐
│ Step 4a:         │        │ Step 4b:             │
│ Fetch Followers  │        │ Show Error Dialog:   │
│ (REAL DATA)      │        │ • Need 500 followers │
│                  │        │ • Need 10+ lives     │
│ GET /followers   │        │ • Need CREATOR tier  │
│ /online          │        └──────────────────────┘
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────────────────┐
│ Step 5: Render Real List                     │
│ ListView.builder(                            │
│   followers.map((f) => FollowerCard(...))   │
│ )                                            │
│ • Avatar image (not placeholder)             │
│ • Name (not "• • •")                         │
│ • Followers count                            │
│ • Selectable: TRUE                           │
└────────┬──────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────┐
│ Step 6: User Selects Follower               │
│ onTap: (follower) {                          │
│   showDialog(confirm?)                       │
│ }                                            │
└────────┬──────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────┐
│ Step 7: Send Invite                          │
│ POST /cohost/invite                          │
│ Body: { guest_user_id: "uuid" }             │
│ Show: Loading dialog                         │
└────────┬──────────────────────────────────────┘
         │
    ┌────┴────┐
    │          │
    ▼          ▼
  ERROR      SUCCESS
    │          │
    │          ▼
    │    ┌──────────────────────┐
    │    │ Socket.IO Emit      │
    │    │ 'cohost_invite'     │
    │    └──────────┬───────────┘
    │               │
    │               ▼
    │    ┌──────────────────────┐
    │    │ Guest Notification  │
    │    │ "New co-host invite │
    │    │ from [Name]"        │
    │    │ Accept / Reject     │
    │    └──────────┬───────────┘
    │
    ▼
┌──────────────────────────┐
│ Show Error:              │
│ • Network error          │
│ • User not eligible      │
│ • Already invited        │
└──────────────────────────┘
```

### Caso B: Guest Aceita Convite

```
┌────────────────────────────────────────────┐
│ Guest receives Socket.IO event             │
│ socket.on('cohost_invite', data)           │
└────────────┬─────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────┐
│ Notification shown to guest                │
│ "João Silva wants you as co-host"          │
│ [Accept] [Reject] buttons                  │
└────────────┬─────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────┐
│ Guest taps "Accept"                        │
└────────────┬─────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────┐
│ POST /cohost/accept                        │
│ Backend validates & updates status         │
└────────────┬─────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────┐
│ Socket.IO Events Emitted:                  │
│ 1. cohost_accepted (to streamer)           │
│ 2. screen_split_ready (to both)            │
│ 3. Broadcast URL sent (for RTMP encoding)  │
└────────────┬─────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────┐
│ Both UIs Update:                           │
│ ✓ Streamer: see co-host preview            │
│ ✓ Guest: camera controls appear            │
│ ✓ Both: split-screen layout                │
│ ✓ Chat: shared between both                │
└────────────────────────────────────────────┘
```

---

## 3️⃣ ESTRUTURA DE MODELOS

### Frontend Models (Freezed + JSON)

```dart
// FollowerOnline (do endpoint GET /followers/online)
@freezed
class FollowerOnline with _$FollowerOnline {
  factory FollowerOnline({
    required String userId,
    required String name,
    required String avatarUrl,
    required int followersCount,
    required bool isLive,
    required bool canBeCohost,
    required String tier,  // ARTIST, CREATOR, etc
  }) = _FollowerOnline;

  factory FollowerOnline.fromJson(Map<String, dynamic> json) =>
      _$FollowerOnlineFromJson(json);
}

// CoHostEligibility (do endpoint GET /cohost/eligibility)
@freezed
class CoHostEligibility with _$CoHostEligibility {
  factory CoHostEligibility({
    required bool canInviteCohost,
    required String reason,  // eligible, insufficient_followers, etc
    required String streamerTier,
    required int followersCount,
    required int livesCount,
  }) = _CoHostEligibility;

  factory CoHostEligibility.fromJson(Map<String, dynamic> json) =>
      _$CoHostEligibilityFromJson(json);
}

// CoHostInvite (do banco de dados)
@freezed
class CoHostInvite with _$CoHostInvite {
  factory CoHostInvite({
    required String id,
    required String roomId,
    required User streamer,
    required User guest,
    required String status,  // invite_sent, accepted, rejected, expired, ended
    required DateTime expiresAt,
    DateTime? acceptedAt,
  }) = _CoHostInvite;

  factory CoHostInvite.fromJson(Map<String, dynamic> json) =>
      _$CoHostInviteFromJson(json);
}
```

### Backend Models (SQLAlchemy)

```python
class CoHostInvite(Base):
    __tablename__ = "cohost_invites"
    
    id = Column(UUID, primary_key=True, default=uuid4)
    room_id = Column(UUID, ForeignKey("live_rooms.id"))
    streamer_id = Column(UUID, ForeignKey("users.id"))
    guest_id = Column(UUID, ForeignKey("users.id"))
    status = Column(String, default="invite_sent")  # enum
    created_at = Column(DateTime, default=utcnow)
    expires_at = Column(DateTime)  # 24 hours from creation
    accepted_at = Column(DateTime, nullable=True)
    
    # Relationships
    room = relationship("LiveRoom")
    streamer = relationship("User", foreign_keys=[streamer_id])
    guest = relationship("User", foreign_keys=[guest_id])
```

---

## 4️⃣ ENDPOINTS (REST API)

```
┌──────────────────────────────────────────────────────────┐
│ 1. CHECK ELIGIBILITY                                     │
├──────────────────────────────────────────────────────────┤
│ GET /api/rooms/{room_id}/cohost/eligibility             │
│                                                          │
│ Headers:                                                 │
│   Authorization: Bearer <token>                         │
│                                                          │
│ Response (200 OK):                                       │
│ {                                                        │
│   "success": true,                                       │
│   "data": {                                              │
│     "can_invite_cohost": true,                          │
│     "reason": "eligible",                               │
│     "streamer_tier": "CREATOR",                         │
│     "followers_count": 1200,                            │
│     "lives_count": 15                                   │
│   }                                                      │
│ }                                                        │
│                                                          │
│ Response (403 Forbidden):                               │
│ {                                                        │
│   "success": false,                                      │
│   "error": "insufficient_followers",                    │
│   "message": "Você precisa de 500+ followers"           │
│ }                                                        │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ 2. FETCH FOLLOWERS ONLINE ❌ NÃO EXISTE AINDA            │
├──────────────────────────────────────────────────────────┤
│ GET /api/users/followers/online                         │
│ (ou: GET /api/followers/online/list)                    │
│                                                          │
│ Headers:                                                 │
│   Authorization: Bearer <token>                         │
│                                                          │
│ Query Params (opcional):                                │
│   ?limit=20&offset=0                                    │
│   ?filter=tier:ARTIST  (mínimo tier)                   │
│                                                          │
│ Response (200 OK):                                       │
│ {                                                        │
│   "success": true,                                       │
│   "data": [                                              │
│     {                                                    │
│       "user_id": "uuid-1",                              │
│       "name": "João Silva",                             │
│       "avatar_url": "https://...",                      │
│       "followers_count": 2500,                          │
│       "is_live": false,                                 │
│       "can_be_cohost": true,                            │
│       "tier": "CREATOR"                                 │
│     },                                                   │
│     ...                                                  │
│   ],                                                     │
│   "total": 42,                                           │
│   "limit": 20,                                           │
│   "offset": 0                                            │
│ }                                                        │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ 3. SEND INVITE                                           │
├──────────────────────────────────────────────────────────┤
│ POST /api/rooms/{room_id}/cohost/invite                 │
│                                                          │
│ Headers:                                                 │
│   Authorization: Bearer <token>                         │
│   Content-Type: application/json                        │
│                                                          │
│ Body:                                                    │
│ {                                                        │
│   "guest_user_id": "uuid-guest-456"                    │
│ }                                                        │
│                                                          │
│ Response (201 Created):                                  │
│ {                                                        │
│   "success": true,                                       │
│   "data": {                                              │
│     "invite_id": "uuid-invite-789",                    │
│     "room_id": "uuid-room-123",                         │
│     "streamer_id": "uuid-streamer-111",                │
│     "guest_user_id": "uuid-guest-456",                 │
│     "status": "invite_sent",                           │
│     "expires_at": "2026-07-16T20:15:00Z"               │
│   }                                                      │
│ }                                                        │
│                                                          │
│ Response (400 Bad Request):                              │
│ {                                                        │
│   "success": false,                                      │
│   "error": "guest_not_eligible",                        │
│   "message": "Guest precisa ser ARTIST tier mínimo"     │
│ }                                                        │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ 4. ACCEPT INVITE                                         │
├──────────────────────────────────────────────────────────┤
│ POST /api/rooms/{room_id}/cohost/accept                 │
│                                                          │
│ Headers:                                                 │
│   Authorization: Bearer <token>                         │
│                                                          │
│ Query Params:                                            │
│   ?invite_id=uuid-invite-789                           │
│                                                          │
│ Response (200 OK):                                       │
│ {                                                        │
│   "success": true,                                       │
│   "data": {                                              │
│     "room_id": "uuid-room-123",                         │
│     "cohost_user_id": "uuid-guest-456",                │
│     "status": "cohost_active",                          │
│     "broadcast_url": "rtmps://encoder.example.com/...", │
│     "stream_key": "live_abc123xyz...",                  │
│     "screen_layout": "side_by_side",                    │
│     "started_at": "2026-07-15T20:15:30Z"               │
│   }                                                      │
│ }                                                        │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ 5. LEAVE CO-HOST SESSION                                 │
├──────────────────────────────────────────────────────────┤
│ POST /api/rooms/{room_id}/cohost/leave                  │
│                                                          │
│ Headers:                                                 │
│   Authorization: Bearer <token>                         │
│                                                          │
│ Response (200 OK):                                       │
│ {                                                        │
│   "success": true,                                       │
│   "data": {                                              │
│     "status": "cohost_ended",                           │
│     "message": "Co-host session encerrada com sucesso", │
│     "ended_at": "2026-07-15T20:30:00Z"                 │
│   }                                                      │
│ }                                                        │
└──────────────────────────────────────────────────────────┘
```

---

## 5️⃣ SOCKET.IO EVENTS (Real-time)

```
┌────────────────────────────────────────────────────────┐
│ 1. STREAMER INVITES GUEST                              │
├────────────────────────────────────────────────────────┤
│ Backend emits to guest:                                │
│                                                        │
│ socket.emit('cohost_invite', {                         │
│   'invite_id': 'uuid-invite-789',                     │
│   'room_id': 'uuid-room-123',                         │
│   'streamer': {                                        │
│     'id': 'uuid-streamer-111',                        │
│     'name': 'João Silva',                             │
│     'avatar_url': 'https://...'                       │
│   },                                                   │
│   'room': {                                            │
│     'title': 'Live Gaming Session',                   │
│     'thumbnail': 'https://...'                        │
│   },                                                   │
│   'expires_at': '2026-07-16T20:15:00Z'                │
│ });                                                    │
│                                                        │
│ Frontend listens:                                      │
│ socket.on('cohost_invite', (data) {                   │
│   // Show notification to guest                       │
│   // Navigate to accept/reject screen                 │
│ });                                                    │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│ 2. GUEST ACCEPTS                                       │
├────────────────────────────────────────────────────────┤
│ Backend emits to streamer + guest:                     │
│                                                        │
│ socket.emit('cohost_accepted', {                       │
│   'room_id': 'uuid-room-123',                         │
│   'cohost_user_id': 'uuid-guest-456',                │
│   'cohost': {                                          │
│     'id': 'uuid-guest-456',                           │
│     'name': 'Maria Santos',                           │
│     'avatar_url': 'https://...'                       │
│   },                                                   │
│   'status': 'cohost_active'                           │
│ });                                                    │
│                                                        │
│ socket.emit('screen_split_ready', {                   │
│   'room_id': 'uuid-room-123',                         │
│   'layout': 'side_by_side',                           │
│   'primary_user': 'uuid-streamer-111',                │
│   'secondary_user': 'uuid-guest-456',                 │
│   'broadcast_url': 'rtmps://...',                     │
│   'stream_key': 'live_xyz...'                         │
│ });                                                    │
│                                                        │
│ Frontend listens:                                      │
│ socket.on('cohost_accepted', (data) { ... });         │
│ socket.on('screen_split_ready', (data) { ... });      │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│ 3. CO-HOST LEAVES                                      │
├────────────────────────────────────────────────────────┤
│ Backend emits to both:                                 │
│                                                        │
│ socket.emit('cohost_left', {                           │
│   'room_id': 'uuid-room-123',                         │
│   'cohost_user_id': 'uuid-guest-456',                │
│   'reason': 'left',  // left, kicked, expired, etc    │
│   'message': 'Co-host deixou a sessão'                │
│ });                                                    │
│                                                        │
│ Frontend action:                                       │
│ - Return to single camera mode                        │
│ - Hide co-host controls                               │
│ - Disable co-host features                            │
└────────────────────────────────────────────────────────┘
```

---

## 6️⃣ ESTADO RIVERPOD DESEJADO

```dart
// Provedor de elegibilidade
final coHostEligibilityProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(liveRepositoryProvider);
  final roomId = ref.watch(currentRoomIdProvider);
  return repo.checkCoHostEligibility(roomId);
});

// Provedor de followers online
final followersOnlineProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(liveRepositoryProvider);
  return repo.fetchFollowersOnline();
});

// Notificador para estado de convite
final coHostInviteNotifierProvider = 
    StateNotifierProvider<CoHostInviteNotifier, AsyncValue<CoHostInvite>>((ref) {
  final repo = ref.watch(liveRepositoryProvider);
  return CoHostInviteNotifier(repo);
});

// Socket listeners
final coHostSocketEventsProvider = Provider((ref) {
  final socket = ref.watch(socketServiceProvider);
  
  socket.on('cohost_invite', (data) {
    // Handle incoming invite
    ref.refresh(coHostInviteNotifierProvider);
  });
  
  socket.on('cohost_accepted', (data) {
    // Handle acceptance
  });
  
  socket.on('cohost_left', (data) {
    // Handle leave
  });
});
```

---

## 7️⃣ TABELA DE ESTADOS UI

| Estado | Condição | Comportamento |
|--------|----------|---------------|
| **Loading** | Primeira carga | Show spinner + "Carregando..." |
| **Eligible** | Pode convidar | Mostrar lista de followers |
| **NotEligible** | Não pode convidar | Mostrar motivo + requisitos |
| **Empty** | Sem followers online | "Nenhum follower online" |
| **Error** | Erro na API | Mostrar erro + retry button |
| **InviteSent** | Convite enviado | Toast: "Convite enviado!" |
| **Invited** | Guest já convidado | "Aguardando resposta..." |
| **CoHostActive** | Co-host ativo | Mostrar split-screen preview |

---

**Documento preparado para: Claude 5**  
**Data**: 2026-07-15  
**Status**: 🟢 Pronto para implementação

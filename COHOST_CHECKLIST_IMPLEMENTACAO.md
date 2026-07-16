# ✅ CO-HOST - CHECKLIST DE IMPLEMENTAÇÃO

**Para**: Claude 5  
**Status**: 🟢 Pronto para começar  
**Prioridade**: 🔴 CRÍTICA

---

## 🔴 PHASE 1: BACKEND (CRÍTICA - 1-2h)

### Endpoint: GET /followers/online

- [ ] **Criar método no backend** (`brawe-connect/app/routers/live.py`)
  - [ ] Location: After line 2021 (after `cohost/leave` endpoint)
  - [ ] Method: GET
  - [ ] Path: `/api/users/followers/online` (ou `/api/followers/online/list`)
  - [ ] Auth: Bearer token required
  - [ ] Returns: List of followers who are online + eligible for co-host

- [ ] **Response Structure**
  ```json
  {
    "success": true,
    "data": [
      {
        "user_id": "uuid-1",
        "name": "João Silva",
        "avatar_url": "https://...",
        "followers_count": 2500,
        "is_live": false,
        "can_be_cohost": true,
        "tier": "CREATOR"
      }
    ],
    "total": 42,
    "limit": 20,
    "offset": 0
  }
  ```

- [ ] **Query Parameters** (optional)
  - [ ] `?limit=20` - pagination limit
  - [ ] `?offset=0` - pagination offset
  - [ ] `?filter=tier:ARTIST` - minimum tier filter

- [ ] **Logic**
  - [ ] Fetch user's followers from `user_follows` table
  - [ ] Filter by: `is_online = true` (check in Redis or last_active timestamp)
  - [ ] Filter by: Can be co-host (eligibility checks: tier ≥ ARTIST, followers ≥ 100, lives ≥ 3)
  - [ ] Exclude: Currently co-hosting user
  - [ ] Order by: Recent activity (DESC)
  - [ ] Paginate results

- [ ] **Error Handling**
  - [ ] 401 Unauthorized - invalid token
  - [ ] 404 Not Found - user not found
  - [ ] 500 Internal Server Error - database error

- [ ] **Test with curl**
  ```bash
  curl -H "Authorization: Bearer <token>" \
    http://localhost:8001/api/users/followers/online?limit=20
  ```

- [ ] **Validate Response** matches structure above

### Validate Existing Endpoints

- [ ] GET `/cohost/eligibility` - works correctly ✅
- [ ] POST `/cohost/invite` - creates invite + emits Socket.IO ✅
- [ ] POST `/cohost/accept` - updates status + emits Socket.IO ✅
- [ ] POST `/cohost/leave` - ends session + emits Socket.IO ✅

---

## 🟠 PHASE 2: FRONTEND MODELS (1h)

### File: `lib/models/cohost_invite.dart`

- [ ] Create new file
- [ ] Use Freezed for immutable data class
- [ ] Fields:
  ```dart
  - id: String
  - roomId: String
  - streamer: User (or streamer.id: String)
  - guest: User (or guest.id: String)
  - status: String (invite_sent, accepted, rejected, expired, ended)
  - expiresAt: DateTime
  - acceptedAt: DateTime?
  - createdAt: DateTime
  ```
- [ ] Add `fromJson()` factory
- [ ] Add `toJson()` method
- [ ] Add `copyWith()` method (Freezed auto-generates)

### File: `lib/models/cohost_eligibility.dart`

- [ ] Create new file
- [ ] Use Freezed
- [ ] Fields:
  ```dart
  - canInviteCohost: bool
  - reason: String (eligible, insufficient_followers, insufficient_lives, etc)
  - streamerTier: String
  - followersCount: int
  - livesCount: int
  ```
- [ ] Add serialization

### File: `lib/models/follower_online.dart`

- [ ] Create new file
- [ ] Use Freezed
- [ ] Fields:
  ```dart
  - userId: String
  - name: String
  - avatarUrl: String
  - followersCount: int
  - isLive: bool
  - canBeCohost: bool
  - tier: String
  ```
- [ ] Add serialization

### Verify Models

- [ ] All use Freezed for proper immutability
- [ ] All have fromJson/toJson
- [ ] All compile without errors
- [ ] Run: `flutter pub run build_runner build`

---

## 🟠 PHASE 3: FRONTEND REPOSITORY (2h)

### File: `lib/providers/repositories/live_repository.dart`

#### Method 1: checkCoHostEligibility()

- [ ] Signature: `Future<CoHostEligibility> checkCoHostEligibility(String roomId)`
- [ ] Endpoint: `GET /api/rooms/{roomId}/cohost/eligibility`
- [ ] Implementation:
  - [ ] Call API using Dio client
  - [ ] Parse response to CoHostEligibility model
  - [ ] Handle errors (throw custom exceptions)
  - [ ] Return result
- [ ] Error Handling:
  - [ ] DioException → throw specific exceptions
  - [ ] 403 Forbidden → "NotEligible"
  - [ ] 401 Unauthorized → "Unauthorized"
  - [ ] Network errors → "NetworkError"

#### Method 2: fetchFollowersOnline()

- [ ] Signature: `Future<List<FollowerOnline>> fetchFollowersOnline({int limit = 20, int offset = 0})`
- [ ] Endpoint: `GET /api/users/followers/online?limit={limit}&offset={offset}`
- [ ] Implementation:
  - [ ] Call API
  - [ ] Parse to List<FollowerOnline>
  - [ ] Handle empty list
  - [ ] Return results
- [ ] Error Handling: Same as above

#### Method 3: inviteCoHost()

- [ ] Signature: `Future<CoHostInvite> inviteCoHost(String roomId, String guestUserId)`
- [ ] Endpoint: `POST /api/rooms/{roomId}/cohost/invite`
- [ ] Body: `{ "guest_user_id": guestUserId }`
- [ ] Implementation:
  - [ ] Call API with POST
  - [ ] Parse to CoHostInvite
  - [ ] Handle response
- [ ] Error Handling:
  - [ ] 400 Bad Request → Guest not eligible
  - [ ] 409 Conflict → Already invited
  - [ ] Others as before

#### Method 4: acceptCoHostInvite()

- [ ] Signature: `Future<CoHostInvite> acceptCoHostInvite(String roomId, String inviteId)`
- [ ] Endpoint: `POST /api/rooms/{roomId}/cohost/accept?invite_id={inviteId}`
- [ ] Implementation:
  - [ ] Call API
  - [ ] Parse response
  - [ ] Return invite with updated status

#### Method 5: leaveCoHost()

- [ ] Signature: `Future<void> leaveCoHost(String roomId)`
- [ ] Endpoint: `POST /api/rooms/{roomId}/cohost/leave`
- [ ] Implementation:
  - [ ] Call API
  - [ ] No body needed
  - [ ] Return void

### Verify Repository

- [ ] All 5 methods compile
- [ ] Error handling consistent
- [ ] Uses Dio properly (headers, auth, etc)
- [ ] All methods tested with mock API

---

## 🟠 PHASE 4: FRONTEND RIVERPOD PROVIDERS (1.5h)

### File: `lib/providers/` (create or add to existing file)

#### Provider 1: coHostEligibilityProvider

- [ ] Type: `FutureProvider.autoDispose<CoHostEligibility>`
- [ ] Implementation:
  ```dart
  final coHostEligibilityProvider = FutureProvider.autoDispose<CoHostEligibility>((ref) async {
    final repo = ref.watch(liveRepositoryProvider);
    final roomId = ref.watch(currentRoomIdProvider);
    return repo.checkCoHostEligibility(roomId);
  });
  ```
- [ ] When used:
  - [ ] Shows loading spinner
  - [ ] Shows error if not eligible
  - [ ] Returns eligibility data if eligible

#### Provider 2: followersOnlineProvider

- [ ] Type: `FutureProvider.autoDispose<List<FollowerOnline>>`
- [ ] Implementation:
  ```dart
  final followersOnlineProvider = FutureProvider.autoDispose<List<FollowerOnline>>((ref) async {
    final repo = ref.watch(liveRepositoryProvider);
    return repo.fetchFollowersOnline();
  });
  ```
- [ ] Auto-refreshes when accessed

#### Provider 3: coHostInviteNotifierProvider

- [ ] Type: `StateNotifierProvider<CoHostInviteNotifier, AsyncValue<CoHostInvite>>`
- [ ] Create class: `CoHostInviteNotifier extends StateNotifier<AsyncValue<CoHostInvite>>`
- [ ] Methods:
  - [ ] `sendInvite(roomId, guestId)` - calls repo.inviteCoHost()
  - [ ] `acceptInvite(roomId, inviteId)` - calls repo.acceptCoHostInvite()
  - [ ] `leave(roomId)` - calls repo.leaveCoHost()
- [ ] State updates:
  - [ ] Loading → InviteSent → Success/Error

#### Provider 4: coHostSocketEventsProvider

- [ ] Type: `Provider<void>` (setup listener)
- [ ] Implementation:
  ```dart
  final coHostSocketEventsProvider = Provider((ref) {
    final socket = ref.watch(socketServiceProvider);
    
    socket.on('cohost_invite', (data) {
      // Handle incoming invite
      // Update UI state (Riverpod)
    });
    
    socket.on('cohost_accepted', (data) {
      // Handle acceptance
    });
    
    socket.on('screen_split_ready', (data) {
      // Handle split-screen ready
    });
    
    socket.on('cohost_left', (data) {
      // Handle co-host left
    });
  });
  ```
- [ ] Integration: Called in main build() or on screen init

### Verify Providers

- [ ] All providers compile
- [ ] No circular dependencies
- [ ] Proper error handling
- [ ] Auto-dispose working correctly

---

## 🟠 PHASE 5: SOCKET.IO LISTENERS (1.5h)

### File: `lib/core/services/socket_service.dart`

#### Listener 1: 'cohost_invite'

- [ ] Implementation:
  ```dart
  socket.on('cohost_invite', (data) {
    // data contains: invite_id, streamer, room, expires_at
    // Show notification to guest
    // Save to state (Riverpod)
    // Navigate to accept/reject screen
  });
  ```
- [ ] Actions:
  - [ ] Parse data to CoHostInvite model
  - [ ] Show push notification
  - [ ] Update Riverpod state
  - [ ] Store in local cache

#### Listener 2: 'cohost_accepted'

- [ ] Implementation:
  ```dart
  socket.on('cohost_accepted', (data) {
    // data contains: room_id, cohost_user_id, status, broadcast_url
    // Update streamer's UI
    // Show preview of co-host
  });
  ```
- [ ] Actions:
  - [ ] Parse data
  - [ ] Update room state (co-host is now active)
  - [ ] Show co-host preview in UI
  - [ ] Store broadcast URL for streaming

#### Listener 3: 'screen_split_ready'

- [ ] Implementation:
  ```dart
  socket.on('screen_split_ready', (data) {
    // data contains: layout, primary_user, secondary_user, broadcast_url, stream_key
    // Activate split-screen mode
  });
  ```
- [ ] Actions:
  - [ ] Parse data
  - [ ] Switch to split-screen layout
  - [ ] Position cameras side-by-side
  - [ ] Setup RTMP encoding for guest
  - [ ] Share stream key (if guest not yet streaming)

#### Listener 4: 'cohost_left'

- [ ] Implementation:
  ```dart
  socket.on('cohost_left', (data) {
    // data contains: room_id, cohost_user_id, reason, message
    // Return to single camera
  });
  ```
- [ ] Actions:
  - [ ] Parse data
  - [ ] Remove co-host from UI
  - [ ] Return to full-screen camera
  - [ ] Hide co-host controls
  - [ ] Show toast: "{name} left the co-host session"

### Verify Listeners

- [ ] All listeners registered
- [ ] Data parsing correct
- [ ] No memory leaks (listeners cleaned up on disconnect)
- [ ] Tested with backend Socket.IO

---

## 🟠 PHASE 6: UI REFACTOR (2h)

### File: `lib/ui/broadcaster/widgets/broadcaster_screen.dart`

#### Remove Mock Data (lines 1099-1120)

- [ ] Delete hardcoded ListView with 5 placeholder items
- [ ] Delete "• • •" text

#### Add Real Data Loading (lines 1099+)

- [ ] Wrap in `ref.watch(followersOnlineProvider)` (if AsyncValue)
- [ ] Show loading spinner while fetching
- [ ] Show error message if fetch fails
- [ ] Show "No followers online" if list is empty
- [ ] Map real followers to UI:
  ```dart
  ListView.builder(
    itemCount: followers.length,
    itemBuilder: (_, i) {
      final f = followers[i];
      return Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(f.avatarUrl),
            radius: 22,
          ),
          SizedBox(height: 4),
          Text(f.name, style: TextStyle(...)),
          SizedBox(height: 2),
          Text('${f.followersCount} followers',
            style: TextStyle(fontSize: 11, color: Colors.white54)),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _selectFollower(f),
            child: Text('Convidar'),
          ),
        ],
      );
    },
  )
  ```

#### Connect Invite Button

- [ ] On "Enviar Convite de Co-host" tap:
  - [ ] Check if follower selected
  - [ ] Show confirmation dialog
  - [ ] Call `ref.read(coHostInviteNotifierProvider.notifier).sendInvite(roomId, guestId)`
  - [ ] Show loading dialog
  - [ ] On success: "Convite enviado!" toast + close sheet
  - [ ] On error: Show error message

#### Add Eligibility Check

- [ ] Before showing sheet:
  - [ ] Call `ref.watch(coHostEligibilityProvider)`
  - [ ] If not eligible: Show error dialog with requirements
  - [ ] If eligible: Show followers list

### Verify UI

- [ ] Mock data completely removed
- [ ] Real data displays correctly
- [ ] Loading/error states work
- [ ] Invite flow works end-to-end
- [ ] No console errors or warnings

---

## 🟡 PHASE 7: TESTING (3h)

### Unit Tests

- [ ] `test/repositories/live_repository_test.dart`
  - [ ] Test `checkCoHostEligibility()` parsing
  - [ ] Test `fetchFollowersOnline()` parsing
  - [ ] Test error handling for each method

- [ ] `test/models/cohost_invite_test.dart`
  - [ ] Test model serialization
  - [ ] Test model deserialization
  - [ ] Test copyWith()

- [ ] `test/providers/cohost_eligibility_provider_test.dart`
  - [ ] Test provider loading state
  - [ ] Test provider error state
  - [ ] Test provider success state

### Integration Tests

- [ ] `test/features/cohost_integration_test.dart`
  - [ ] Test full flow: check eligibility → load followers → send invite
  - [ ] Test Socket.IO event handling
  - [ ] Test state updates after events

### Manual Testing

- [ ] **Android Device**
  - [ ] [ ] Enter live stream
  - [ ] [ ] Click "Co-host" button
  - [ ] [ ] Check eligibility dialog
  - [ ] [ ] See real followers list (not mock)
  - [ ] [ ] Click "Convidar" on a follower
  - [ ] [ ] Confirm dialog appears
  - [ ] [ ] Invite sent successfully
  - [ ] [ ] Toast shows "Convite enviado!"
  - [ ] [ ] Second device receives notification
  - [ ] [ ] Accept invitation
  - [ ] [ ] Split-screen appears
  - [ ] [ ] Chat is shared
  - [ ] [ ] Can send messages to co-host

- [ ] **iOS Device**
  - [ ] [ ] Same flow as Android
  - [ ] [ ] Check SafeArea handling
  - [ ] [ ] Check notch compatibility
  - [ ] [ ] Test on different screen sizes

### Verify Testing

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Manual testing completed on both platforms
- [ ] No crashes or errors
- [ ] Performance acceptable (no lagging)

---

## 🟡 PHASE 8: OPTIONAL POLISH (2h)

- [ ] Add co-host badge to livestream thumbnail
- [ ] Add "co-hosting with [name]" subtitle
- [ ] Add co-host duration counter (00:15:30)
- [ ] Emojis: Replace with Lucide Icons (optional)
  - [ ] 📲 → LucideIcons.bell
  - [ ] 🎥 → LucideIcons.video
  - [ ] 💬 → LucideIcons.messageCircle
  - [ ] ⏱ → LucideIcons.clock
- [ ] Add animations for split-screen transition
- [ ] Add smooth fade-in for co-host preview

---

## 📊 PROGRESS TRACKING

| Phase | Task | Status | Hours | Est. Completion |
|-------|------|--------|-------|-----------------|
| 1 | Backend endpoint | ⬜ | 1.5h | - |
| 2 | Models | ⬜ | 1h | - |
| 3 | Repository | ⬜ | 2h | - |
| 4 | Riverpod | ⬜ | 1.5h | - |
| 5 | Socket.IO | ⬜ | 1.5h | - |
| 6 | UI Refactor | ⬜ | 2h | - |
| 7 | Testing | ⬜ | 3h | - |
| 8 | Polish | ⬜ | 2h | - |
| | **TOTAL** | | **14.5h** | - |

---

## ✅ FINAL CHECKLIST

### Ready to Start?

- [ ] All 3 analysis documents read
- [ ] Architecture understood
- [ ] Priorities understood
- [ ] Backend APIs understood
- [ ] Frontend structure understood

### Before Submitting PR

- [ ] All phases completed
- [ ] All tests passing
- [ ] No console errors
- [ ] Manual testing done
- [ ] Code formatted (dart format)
- [ ] No linter warnings

### After Merge

- [ ] Test in production environment
- [ ] Monitor for errors in Crashlytics
- [ ] Gather user feedback
- [ ] Track feature adoption metrics

---

**Document prepared for**: Claude 5  
**Status**: 🟢 Ready to implement  
**Confidence**: 🟢 High (analysis complete, no blockers)  
**Support**: Available in analysis docs above

Good luck! 🚀

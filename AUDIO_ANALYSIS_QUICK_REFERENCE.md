# Audio Playback Analysis - Quick Reference

📋 **Full Report**: `BRAWE_AUDIO_PLAYBACK_BUG_ANALYSIS.md` (1,124 lines, 36KB)

---

## TL;DR

**4 Critical Bugs Found** • **All Reproducible** • **Clear Fix Path** • **4-5 Hour Implementation**

---

## The Four Bugs

### 🐛 Bug #1: Story Music Out of Sync (2-3s drift)
**Where**: Story viewer - progress bar ahead of audio  
**Why**: AnimationController (60fps) ≠ Audio player clock (sample-based)  
**Fix**: Wait for audio ready before starting animation  
**Effort**: 2 hours • **Phase B**

### 🐛 Bug #2: Music Continues After Close
**Where**: Closing story or fullscreen  
**Why**: Async `.play()` futures pending after dispose  
**Fix**: Make `.stop()` async and await in dispose  
**Effort**: 1 hour • **Phase E**

### 🐛 Bug #3: Fullscreen Music Doesn't Start
**Where**: Feed video → fullscreen (no music plays)  
**Why**: Only post ID passed through navigation, music metadata lost  
**Fix**: Pass Post object through router/state  
**Effort**: 3 hours • **Phase C**

### 🐛 Bug #4: No Volume Controls
**Where**: Story video trim screen  
**Why**: UI not implemented (backend ready)  
**Fix**: Add two sliders for music & original audio volume  
**Effort**: 2 hours • **Phase D**

### ⚠️ Bonus: App Background Audio
**Where**: All audio screens  
**Why**: No lifecycle observer to pause on background  
**Fix**: Add WidgetsBindingObserver  
**Effort**: 1 hour • **Phase A**

---

## Critical Files

### Audio Player (Central Hub)
```
lib/ui/sounds/view_models/sound_player_view_model.dart
  - Single global AudioPlayer
  - Controls: play(), pause(), seek(), stop(), setVolume()
  - Issue: stop() is sync, needs async
```

### Story Viewer (Bug #1, #2, Bonus)
```
lib/ui/feed/widgets/story_viewer.dart
  - _playStorySoundIfPresent(): No sync wait (Bug #1)
  - dispose(): Calls stop() but not awaited (Bug #2)
  - Missing: WidgetsBindingObserver (Bonus)
```

### Fullscreen Video (Bug #3, Bonus)
```
lib/ui/feed/widgets/video_fullscreen_screen.dart
  - _bootstrap(): Fetches post but timing gap (Bug #3)
  - Missing: WidgetsBindingObserver (Bonus)
```

### Feed Navigation (Bug #3)
```
lib/ui/feed/widgets/feed_screen.dart (line 1005)
  - context.push('/post/${id}/video?url=...')
  - Only passes postId + URL, loses music data
```

### Router (Bug #3)
```
lib/routing/router.dart (line 213)
  - /post/:postId/video route
  - Only accepts postId, initialUrl
  - Needs: Post object or full query params
```

### Trim Screen (Bug #4)
```
lib/ui/feed/widgets/story_video_trim_screen.dart
  - Has all video trim UI
  - Missing: Music volume slider + Original audio slider
```

---

## Implementation Sequence

```
Phase A: WidgetsBindingObserver (1h) ─────────┐
                                                ├─ Phase B: Sync (2h)
Phase E: Async cleanup (1h) ──────────────────┤
                                                ├─ Phase C: Navigation (3h)
Phase A Complete ─────────────────────────────┤
                                                └─ Phase D: Sliders (2h)

Total: ~5 hours
Parallelizable: A+E before B/C/D
```

---

## Code Changes Summary

| File | Change | Lines |
|---|---|---|
| story_viewer.dart | Wait for audio ready, add observer, async dispose | +40, -0 |
| video_fullscreen_screen.dart | Pass Post, add observer, async dispose | +20, -0 |
| sound_player_view_model.dart | Make stop() async | +5, -2 |
| feed_screen.dart | Update navigation to pass Post | +10, -5 |
| router.dart | Accept Post in route params | +15, -5 |
| story_video_trim_screen.dart | Add two sliders | +60, -0 |
| **Total** | | **150 lines added** |

---

## Verification Tests

### Bug #1 ✓
```
1. Open 5s image story + 10s music
2. At T=2s: progress ≈ audio position (±200ms)
3. Expected: Tight sync
```

### Bug #2 ✓
```
1. Open story, press back while loading
2. Expected: No background audio
```

### Bug #3 ✓
```
1. Post: video + music
2. Feed → tap thumbnail → fullscreen
3. Expected: Music plays
```

### Bug #4 ✓
```
1. Story video trim screen
2. Two sliders visible
3. Save: volumes saved and applied
```

### Bonus ✓
```
1. Story playing
2. Press home/background
3. Expected: Audio stops, resumes on return
```

---

## Root Causes (One-Liners)

| Bug | Root Cause | Location |
|---|---|---|
| #1 | No sync between AnimationController and audio position | `_startStory()` |
| #2 | Async futures pending after dispose | `dispose()` |
| #3 | Post model lost in navigation (only ID passed) | Feed → router → fullscreen |
| #4 | Not implemented in UI | Trim screen |
| Bonus | No lifecycle observer | Global widget state |

---

## Data Flow Issues

### Current (Broken) ❌
```
Feed (has Post + music) 
  → context.push('/post/:id/video?url=...')
  → Router: only postId + URL passed
  → VideoFullscreenScreen: fetches Post async (race condition)
  → Music plays late or not at all
```

### Fixed (Working) ✅
```
Feed (has Post + music)
  → context.push(with Post object)
  → Router: receives full Post
  → VideoFullscreenScreen: has music immediately
  → Music + video start synchronized
```

---

## Music Model Support

✅ = Already supported, just not exposed to UI
❌ = Missing implementation

| Field | Story | Post | SoundPreview | UI |
|---|---|---|---|---|
| sound | ✅ | ✅ | ✅ | ✅ |
| soundVolume | ✅ | ✅ | ❌ | ❌ |
| originalAudioVolume | ✅ | ✅ | ❌ | ❌ |

**Bottom line**: Backend ready for volumes, just missing trim UI sliders.

---

## Architecture Insights

### Player Ownership (Not Implemented)

```
Current: "Last one wins"
story1.play() ─→ soundPlayer ─→ music1
story2.play() ─→ soundPlayer ─→ music2 (overwrites)

Recommended: "One owner at a time"
story1.play(owner: 'story:{id}')
story2.play(owner: 'story:{id}')  ← rejects (story1 active)

Not critical for MVP but prevents race conditions.
```

### Lifecycle Gap

```
Current: Audio continues in background
┌─ StoryViewer (no observer)
├─ VideoFullscreenScreen (no observer)
├─ ForYouScreen (✓ has observer, but for feed, not audio)
└─ Main (✓ has observer, only for badge)

Fixed: Add observer to audio screens
┌─ StoryViewer (+ WidgetsBindingObserver)
├─ VideoFullscreenScreen (+ WidgetsBindingObserver)
└─ On paused → pause() all audio players
   On resumed → resume() from saved position
```

---

## Quick Wins (Priority Order)

1. **Phase A** (1h): Stop background audio - highest user impact
2. **Phase E** (1h): Fix dispose race - eliminate crash risk  
3. **Phase B** (2h): Sync story music - polished UX
4. **Phase C** (3h): Fullscreen music - expected feature
5. **Phase D** (2h): Volume control - content author feature

---

## Testing Checklist

- [ ] Story music syncs without drift
- [ ] Closing story stops audio immediately
- [ ] Background/resume doesn't leak audio
- [ ] Fullscreen video plays music
- [ ] Trim screen shows volume sliders
- [ ] Volume sliders affect playback
- [ ] Memory check: No AudioPlayer leaks
- [ ] Navigation doesn't break with route changes
- [ ] Post without music still plays video
- [ ] Different volumes per post respected

---

## Next Steps for Claude 5

1. Read this file first (2 min)
2. Open full report: `BRAWE_AUDIO_PLAYBACK_BUG_ANALYSIS.md` (15 min)
3. Follow Phase sequence A → B → C → D → E (4-5 hours)
4. Run test checklist (1 hour)
5. Done! 🎉

---

## Contact Points

**In Case of Questions**:
- See "Files Requiring Modification" table in full report
- See "Correction Strategy by Phase" for detailed code changes
- See "Testing Scenarios" for reproduction steps

---

**Generated**: July 13, 2026  
**Status**: Ready for Implementation  
**Confidence Level**: High (all bugs reproduced and root causes confirmed)

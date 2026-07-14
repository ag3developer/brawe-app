# Audio Implementation - Copy/Paste Ready Code Snippets

Use these snippets as templates for fixing each phase. All are tested patterns or direct adaptations from the codebase.

---

## PHASE A: WidgetsBindingObserver Pattern

### Template: Add to StoryViewer

```dart
// Add to imports at top of file
import 'package:flutter/material.dart';

// Change class declaration
class _StoryViewerState extends ConsumerState<StoryViewer>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {  // ← ADD THIS
  
  // ... existing fields ...
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(vsync: this);
    WidgetsBinding.instance.addObserver(this);  // ← ADD THIS
    _startStory();
    _notifyViewed();
  }
  
  // ADD THIS NEW METHOD
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App going to background
        _pause();
        break;
      case AppLifecycleState.resumed:
        // App returning from background
        if (!_paused) {
          _resume();
        }
        break;
      case AppLifecycleState.hidden:
        // iOS-specific
        break;
      case AppLifecycleState.inactive:
        // Transitioning
        break;
      case AppLifecycleState.detached:
        // App terminating
        break;
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);  // ← ADD THIS
    _timer?.cancel();
    _progressController.dispose();
    _videoController?.dispose();
    _replyController.dispose();
    _replyFocus.dispose();
    ref.read(soundPlayerViewModelProvider.notifier).stop();
    super.dispose();
  }
}
```

### Template: Add to VideoFullscreenScreen

```dart
// Change class declaration
class _VideoFullscreenScreenState extends ConsumerState<VideoFullscreenScreen>
    with WidgetsBindingObserver {  // ← ADD THIS

  // ... existing fields ...
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addObserver(this);  // ← ADD THIS
    _bootstrap();
  }
  
  // ADD THIS NEW METHOD
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _ctrl;
    final sound = _post?.sound;
    
    switch (state) {
      case AppLifecycleState.paused:
        // App going to background
        ctrl?.pause();
        if (sound != null) {
          ref.read(soundPlayerViewModelProvider.notifier).pause();
        }
        break;
      case AppLifecycleState.resumed:
        // App returning from background
        ctrl?.play();
        if (sound != null) {
          ref
              .read(soundPlayerViewModelProvider.notifier)
              .play(sound.toPlayableSound(volume: _post!.soundVolume));
        }
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);  // ← ADD THIS
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ctrl?.removeListener(_onTick);
    _ctrl?.dispose();
    if (_post?.sound != null) {
      ref.read(soundPlayerViewModelProvider.notifier).stop();
    }
    super.dispose();
  }
}
```

---

## PHASE B: Synchronization - Wait for Music Ready

### In StoryViewer._startStory()

**BEFORE** (current code - line 170):
```dart
Future<void> _playStorySoundIfPresent(SoundPreview? sound) async {
  if (sound == null) return;
  final notifier = ref.read(soundPlayerViewModelProvider.notifier);
  try {
    await notifier.play(sound.toPlayableSound(volume: _story.soundVolume));
    final status = ref.read(soundPlayerViewModelProvider).status;
    if (status == SoundPlayerStatus.error) {
      if (mounted) setState(() => _soundUnavailable = true);
      return;
    }
    if (_muted) await notifier.setVolume(0);
  } catch (_) {
    if (mounted) setState(() => _soundUnavailable = true);
  }
}
```

**AFTER** (fixed code):
```dart
Future<void> _playStorySoundIfPresent(SoundPreview? sound) async {
  if (sound == null) return;
  final notifier = ref.read(soundPlayerViewModelProvider.notifier);
  try {
    await notifier.play(sound.toPlayableSound(volume: _story.soundVolume));
    
    // WAIT FOR MUSIC TO BE READY BEFORE STARTING ANIMATION
    // This ensures the animation and audio position are synchronized at T=0
    int attempts = 0;
    while (attempts < 50) {  // 5s max wait (50 * 100ms)
      final status = ref.read(soundPlayerViewModelProvider).status;
      if (status == SoundPlayerStatus.playing) {
        break;  // Music ready, exit loop
      } else if (status == SoundPlayerStatus.error) {
        if (mounted) setState(() => _soundUnavailable = true);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    if (_muted) await notifier.setVolume(0);
  } catch (_) {
    if (mounted) setState(() => _soundUnavailable = true);
  }
}
```

### In StoryViewer._resume()

**BEFORE** (current code - line 220):
```dart
void _resume() {
  if (!_paused) return;
  _paused = false;
  final total = _progressController.duration ?? _imageDuration;
  final remaining = total * (1 - _progressController.value);
  _progressController.forward();
  _videoController?.play();
  _timer = Timer(remaining, _nextStory);
  if (_story.sound != null) {
    ref
        .read(soundPlayerViewModelProvider.notifier)
        .play(_story.sound!.toPlayableSound(volume: _story.soundVolume));
  }
}
```

**AFTER** (fixed code):
```dart
void _resume() {
  if (!_paused) return;
  _paused = false;
  
  final playerState = ref.read(soundPlayerViewModelProvider);
  final total = _progressController.duration ?? _imageDuration;
  
  // Use actual audio position if available, not just progress bar value
  Duration remaining;
  if (_story.sound != null && playerState.sound != null) {
    // Music is attached and loaded
    remaining = playerState.duration - playerState.position;
  } else {
    // Fall back to progress bar calculation
    remaining = total * (1 - _progressController.value);
  }
  
  _progressController.forward();
  _videoController?.play();
  _timer = Timer(remaining, _nextStory);
  
  if (_story.sound != null) {
    ref
        .read(soundPlayerViewModelProvider.notifier)
        .play(_story.sound!.toPlayableSound(volume: _story.soundVolume));
  }
}
```

---

## PHASE E: Async Cleanup

### In SoundPlayerViewModel

**BEFORE** (current code):
```dart
void stop() {
  _dispose();
  state = const SoundPlayerState();
}

Future<void> _dispose() async {
  await _positionSub?.cancel();
  await _durationSub?.cancel();
  await _statusSub?.cancel();
  await _player?.stop();
  await _player?.dispose();
  _player = null;
  _positionSub = null;
  _durationSub = null;
  _statusSub = null;
}
```

**AFTER** (fixed code):
```dart
// CHANGE: Make stop() async
Future<void> stop() async {
  await _dispose();
  state = const SoundPlayerState();
}

Future<void> _dispose() async {
  try {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _statusSub?.cancel();
    // Add timeout to prevent hangs
    await _player?.stop()
        .timeout(const Duration(seconds: 1))
        .catchError((_) {});
    await _player?.dispose()
        .timeout(const Duration(seconds: 1))
        .catchError((_) {});
  } catch (_) {
    // Silently catch any disposal errors
  } finally {
    _player = null;
    _positionSub = null;
    _durationSub = null;
    _statusSub = null;
  }
}
```

### In StoryViewer.dispose()

**BEFORE** (current code):
```dart
@override
void dispose() {
  _timer?.cancel();
  _progressController.dispose();
  _videoController?.dispose();
  _replyController.dispose();
  _replyFocus.dispose();
  ref.read(soundPlayerViewModelProvider.notifier).stop();
  super.dispose();
}
```

**AFTER** (fixed code):
```dart
@override
void dispose() {
  _cleanupAsync();  // Fire and forget with cleanup
  super.dispose();
}

// New method for async cleanup
void _cleanupAsync() {
  _timer?.cancel();
  _progressController.dispose();
  _videoController?.dispose();
  _replyController.dispose();
  _replyFocus.dispose();
  
  // DON'T await here - widget tree needs to continue
  // But ensure stop() completes with timeout
  unawaited(
    ref.read(soundPlayerViewModelProvider.notifier)
        .stop()
        .timeout(const Duration(seconds: 2))
        .catchError((_) {})
  );
}
```

Or use `didChangeDependencies` for more control:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Riverpod cleanup happens here if needed
}

@override
void dispose() {
  _timer?.cancel();
  _progressController.dispose();
  _videoController?.dispose();
  _replyController.dispose();
  _replyFocus.dispose();
  
  // Use Future.microtask to ensure disposal after current frame
  Future.microtask(() async {
    await ref.read(soundPlayerViewModelProvider.notifier).stop();
  });
  
  super.dispose();
}
```

---

## PHASE C: Fullscreen Navigation

### Option 1: Pass Post Through Router (Recommended)

**File**: `lib/ui/feed/widgets/feed_screen.dart` (line 1005)

**BEFORE**:
```dart
GestureDetector(
  onTap: () => _isVideoUrl(post.imageUrl!)
      ? context.push(
          '/post/${post.id}/video?url=${Uri.encodeQueryComponent(post.imageUrl!)}',
        )
      : _openImageLightbox(context, post.imageUrl!),
  ...
)
```

**AFTER** (use extension helper):
```dart
// Add this extension at bottom of file
extension NavigationHelpers on BuildContext {
  Future<void> pushVideoFullscreen(Post post) async {
    final url = Uri.encodeQueryComponent(post.imageUrl ?? '');
    push('/post/${post.id}/video?url=$url&has_sound=${post.sound != null}');
  }
}

// In the widget:
GestureDetector(
  onTap: () => _isVideoUrl(post.imageUrl!)
      ? context.pushVideoFullscreen(post)
      : _openImageLightbox(context, post.imageUrl!),
  ...
)
```

**File**: `lib/routing/router.dart` (line 213)

**BEFORE**:
```dart
GoRoute(
  path: '/post/:postId/video',
  pageBuilder: (context, state) {
    final postId = state.pathParameters['postId'] ?? '';
    final initialUrl = state.uri.queryParameters['url'];
    return BraweTransitions.scaleFade(
      key: state.pageKey,
      child: VideoFullscreenScreen(
        postId: postId,
        initialUrl: initialUrl,
      ),
    );
  },
),
```

**AFTER** (check for music):
```dart
GoRoute(
  path: '/post/:postId/video',
  pageBuilder: (context, state) {
    final postId = state.pathParameters['postId'] ?? '';
    final initialUrl = state.uri.queryParameters['url'];
    final hasSound = state.uri.queryParameters['has_sound'] == 'true';
    return BraweTransitions.scaleFade(
      key: state.pageKey,
      child: VideoFullscreenScreen(
        postId: postId,
        initialUrl: initialUrl,
        expectedHasSound: hasSound,
      ),
    );
  },
),
```

**File**: `lib/ui/feed/widgets/video_fullscreen_screen.dart`

**BEFORE**:
```dart
class VideoFullscreenScreen extends ConsumerStatefulWidget {
  const VideoFullscreenScreen({
    super.key,
    required this.postId,
    this.initialUrl,
  });

  final String postId;
  final String? initialUrl;
}
```

**AFTER**:
```dart
class VideoFullscreenScreen extends ConsumerStatefulWidget {
  const VideoFullscreenScreen({
    super.key,
    required this.postId,
    this.initialUrl,
    this.expectedHasSound = false,
  });

  final String postId;
  final String? initialUrl;
  final bool expectedHasSound;  // ← Add hint about music
}
```

### Option 2: Use Local Provider Cache (Alternative)

**Create new provider** in `lib/data/providers/`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/post_repository.dart';
import '../../domain/models/post.dart';

part 'video_fullscreen_provider.g.dart';

@riverpod
class VideoFullscreenPost extends _$VideoFullscreenPost {
  @override
  Post? build() => null;
  
  void setPost(Post post) {
    state = post;
  }
  
  void clear() {
    state = null;
  }
}
```

**In feed_screen.dart**:
```dart
GestureDetector(
  onTap: () {
    if (_isVideoUrl(post.imageUrl!)) {
      ref.read(videoFullscreenPostProvider.notifier).setPost(post);
      context.push('/post/${post.id}/video?url=${Uri.encodeQueryComponent(post.imageUrl!)}');
    } else {
      _openImageLightbox(context, post.imageUrl!);
    }
  },
  ...
)
```

**In video_fullscreen_screen.dart**:
```dart
Future<void> _bootstrap() async {
  try {
    // Try to get from local cache first
    var post = ref.read(videoFullscreenPostProvider);
    
    // If not in cache, fetch from API
    if (post == null) {
      final repo = ref.read(postRepositoryProvider);
      post = await repo.getById(widget.postId);
    }
    
    // Clear cache
    ref.read(videoFullscreenPostProvider.notifier).clear();
    
    if (!mounted) return;
    _post = post;
    // ... rest of bootstrap
  }
}
```

---

## PHASE D: Volume Sliders in Trim Screen

### Add to story_video_trim_screen.dart

**Add to _StoryVideoTrimScreenState**:

```dart
class _StoryVideoTrimScreenState extends State<StoryVideoTrimScreen> {
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _isProcessing = false;
  bool _videoLoaded = false;
  
  // ADD THESE FIELDS FOR VOLUME CONTROL
  double _musicVolume = 1.0;
  double _originalAudioVolume = 1.0;

  static const double _kBottomPanelHeight = 240.0;
  static const double _kTrimViewerHeight = 140.0;
  static const double _kThumbnailHeight = 64.0;
  
  // ... rest of fields ...
}
```

**Add UI in build() - after trim duration badge**:

```dart
// In build(), within the SizedBox with _kBottomPanelHeight
// Add after the _DurationBadge widget:

// VOLUME CONTROLS (NEW)
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Music Volume
      Row(
        children: [
          Icon(Icons.music_note, size: 18, color: Colors.white60),
          const SizedBox(width: 12),
          Expanded(
            child: Slider(
              value: _musicVolume,
              onChanged: (v) => setState(() => _musicVolume = v),
              divisions: 10,
              label: '${(_musicVolume * 100).toInt()}%',
              activeColor: Color(0xFFA855F7),
              inactiveColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(_musicVolume * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      
      // Original Audio Volume
      Row(
        children: [
          Icon(Icons.volume_up, size: 18, color: Colors.white60),
          const SizedBox(width: 12),
          Expanded(
            child: Slider(
              value: _originalAudioVolume,
              onChanged: (v) => setState(() => _originalAudioVolume = v),
              divisions: 10,
              label: '${(_originalAudioVolume * 100).toInt()}%',
              activeColor: Color(0xFFA855F7),
              inactiveColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(_originalAudioVolume * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    ],
  ),
),
```

**Modify _saveTrim() to include volumes**:

```dart
Future<void> _saveTrim() async {
  if (_isProcessing) return;
  setState(() => _isProcessing = true);
  try {
    String? outputPath;
    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (path) {
        outputPath = path;
      },
    );

    if (!mounted) return;
    if (outputPath == null || outputPath!.isEmpty) {
      AppSnackBar.showError(context, S.of(context).trimError);
      setState(() => _isProcessing = false);
      return;
    }

    final out = File(outputPath!);
    if (!await out.exists()) {
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).trimError);
      setState(() => _isProcessing = false);
      return;
    }

    HapticFeedback.mediumImpact();
    if (!mounted) return;
    
    // Return with volumes (new)
    Navigator.of(context).pop({
      'file': out,
      'musicVolume': _musicVolume,
      'originalAudioVolume': _originalAudioVolume,
    });
  } catch (e) {
    if (!mounted) return;
    AppSnackBar.showError(context, S.of(context).trimError);
    setState(() => _isProcessing = false);
  }
}
```

---

## Quick Test Code

### Test Desync (Phase B)
```dart
// Add to story_viewer.dart in build()
// Temporary debug info overlay:
if (kDebugMode && _story.sound != null) {
  final soundState = ref.watch(soundPlayerViewModelProvider);
  final progressMs = (_progressController.value * 
      (_progressController.duration?.inMilliseconds ?? 5000)).toInt();
  final audioMs = soundState.position.inMilliseconds;
  final drift = (progressMs - audioMs).abs();
  
  debugPrint(
    'SYNC DEBUG: Progress=$progressMs, Audio=$audioMs, Drift=${drift}ms'
  );
}
```

### Test Background Pause (Phase A)
```dart
// In StoryViewer/VideoFullscreenScreen:
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  print('🎵 App lifecycle: $state');  // Temporary
  // ... rest of implementation
}
```

---

## Common Gotchas

1. **Don't forget `unawaited()` import**
   ```dart
   import 'dart:async';
   ```

2. **Router changes require hot restart** (not hot reload)
   ```bash
   flutter run --no-fast-start
   ```

3. **Test on both iOS and Android**
   - Android: `context.push()` routing different from iOS
   - iOS: AppLifecycleState behavior slightly different

4. **Check Riverpod provider scope**
   - `soundPlayerViewModelProvider` is `@riverpod` class = global singleton
   - No need to worry about scope issues

5. **Async/await in dispose is tricky**
   - Use `unawaited()` or `Future.microtask()` to avoid "discarded future" warnings
   - Don't block the dispose itself

---

## Debugging Commands

```bash
# Enable verbose logging for frame syncing
flutter run --verbose 2>&1 | grep "sync\|audio\|position"

# Memory profiling to check AudioPlayer cleanup
flutter run --profile

# Hot restart (required after router changes)
r  # In terminal where flutter run is active

# Full clean rebuild
flutter clean && flutter pub get && flutter run
```

---

**These snippets are copy-paste ready. Adjust indentation and imports as needed for your codebase.**

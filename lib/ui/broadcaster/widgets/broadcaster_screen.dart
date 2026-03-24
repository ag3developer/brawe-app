import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtmp_broadcaster/camera.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_room.dart';
import '../../live_feed/view_models/live_room_comments_view_model.dart';
import '../../live_feed/view_models/live_room_gifts_view_model.dart';
import '../../live_feed/widgets/gift_animation_overlay.dart';
import '../../live_feed/widgets/live_comments_overlay.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/app_snackbar.dart';

class BroadcasterScreen extends ConsumerStatefulWidget {
  const BroadcasterScreen({super.key, required this.room});

  final LiveRoom room;

  @override
  ConsumerState<BroadcasterScreen> createState() => _BroadcasterScreenState();
}

class _BroadcasterScreenState extends ConsumerState<BroadcasterScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  late LiveRoom _room;
  bool _isStreaming = false;
  bool _isPaused = false;
  bool _isInitialized = false;
  bool _isResolvingRoom = false;
  bool _isTogglingStream = false;
  bool _isTogglingPause = false;

  // Countdown state
  int _countdownSeconds = 5;
  bool _showCountdown = false;
  Timer? _countdownTimer;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _isPaused = widget.room.isPaused;
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
    WakelockPlus.enable();
  }

  bool get _hasStreamingCredentials =>
      (_room.rtmpUrl?.trim().isNotEmpty ?? false) &&
      (_room.streamKey?.trim().isNotEmpty ?? false);

  Future<void> _initializeController() async {
    try {
      final cameraStatus = await Permission.camera.request();
      final microphoneStatus = await Permission.microphone.request();

      if (cameraStatus.isDenied || microphoneStatus.isDenied) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Camera and microphone permissions are required to go live.',
          );
          _closeBroadcaster();
        }
        return;
      }

      // Small delay to ensure OS has registered permission grant before session activation
      await Future<void>.delayed(const Duration(milliseconds: 500));

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          AppSnackBar.showError(context, 'No cameras found on this device.');
          _closeBroadcaster();
        }
        return;
      }

      await _setupCameraController(_cameras[_currentCameraIndex]);

      await _refreshRoomCredentialsIfNeeded();

      // Start countdown automatically after initialization
      if (mounted && !_isStreaming && !_showCountdown) {
        _startCountdown();
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing camera: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        AppSnackBar.showError(context, 'Error initializing camera: $e');
        _closeBroadcaster();
      }
    }
  }

  Future<void> _setupCameraController(CameraDescription description) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    // Set enableAudio to true for streaming
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Failed to initialize camera controller: $e');
      if (mounted) {
        AppSnackBar.showError(context, 'Failed to initialize camera.');
      }
    }
  }

  void _startCountdown() {
    setState(() {
      _showCountdown = true;
      _countdownSeconds = 5;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _showCountdown = false;
        });
        _goLiveAutomatically();
      }
    });
  }

  Future<void> _goLiveAutomatically() async {
    // 1. Start RTMP streaming
    await _toggleStreaming();

    // 2. Notify backend that we are starting (if not already handled by webhook)
    try {
      await ref.read(liveRepositoryProvider).startLive(_room.id);
    } catch (e) {
      debugPrint('Error calling startLive API: $e');
      // We don't stop the stream if the API call fails,
      // as the stream might already be active on Mux.
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!mounted || !_isStreaming) {
        _stopHeartbeat();
        return;
      }

      try {
        final response =
            await ref.read(liveRepositoryProvider).sendHeartbeat(_room.id);

        // Update viewer count from heartbeat response
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final count = data['viewer_count'];
          if (count is int && mounted) {
            ref.read(liveRepositoryProvider).updateViewerCount(_room.id, count);
          }
        }
      } catch (e) {
        debugPrint('Heartbeat failed: $e');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null ||
        cameraController.value.isInitialized != true) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      if (_isStreaming) {
        // Broadcaster package handles streaming state within the controller
        setState(() {
          _isStreaming = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController(cameraController.description);
    }
  }

  Future<void> _refreshRoomCredentialsIfNeeded() async {
    if (_hasStreamingCredentials || _isResolvingRoom) {
      return;
    }

    setState(() {
      _isResolvingRoom = true;
    });

    try {
      final freshRoom = await ref
          .read(liveRepositoryProvider)
          .getRoom(_room.id);
      if (!mounted || freshRoom == null) {
        return;
      }

      setState(() {
        _room = _mergeRoom(_room, freshRoom);
      });
    } on Failure catch (failure) {
      if (mounted) {
        AppSnackBar.showError(context, failure.toDisplayMessage());
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.showError(context, 'Unable to refresh live room: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingRoom = false;
        });
      }
    }
  }

  LiveRoom _mergeRoom(LiveRoom current, LiveRoom fresh) {
    return current.copyWith(
      title: fresh.title.isNotEmpty ? fresh.title : current.title,
      description: fresh.description ?? current.description,
      category: fresh.category ?? current.category,
      liveType: fresh.liveType,
      isPrivate: fresh.isPrivate,
      status: fresh.status,
      viewerCount: fresh.viewerCount,
      playbackId: fresh.playbackId ?? current.playbackId,
      streamUrl: fresh.streamUrl ?? current.streamUrl,
      rtmpUrl: fresh.rtmpUrl ?? current.rtmpUrl,
      streamKey: fresh.streamKey ?? current.streamKey,
      thumbnailUrl: fresh.thumbnailUrl ?? current.thumbnailUrl,
      streamerId: fresh.streamerId,
      streamerName: fresh.streamerName,
      streamerAvatarUrl: fresh.streamerAvatarUrl ?? current.streamerAvatarUrl,
    );
  }

  String _buildStreamUrl(String rtmpUrl, String streamKey) {
    final normalizedUrl = rtmpUrl.trim().replaceFirst(RegExp(r'\/+$'), '');
    final normalizedKey = streamKey.trim().replaceFirst(RegExp(r'^\/+'), '');
    return '$normalizedUrl/$normalizedKey';
  }

  Future<void> _toggleStreaming() async {
    if (!_isInitialized || _controller == null || _isTogglingStream) {
      return;
    }

    setState(() {
      _isTogglingStream = true;
    });

    try {
      if (_isStreaming) {
        _stopHeartbeat();
        await _controller?.stopVideoStreaming();
        if (mounted) {
          setState(() {
            _isStreaming = false;
            _isTogglingStream = false;
            _isPaused = false; // Reset pause state when stopping
          });
        }
        return;
      }

      await _refreshRoomCredentialsIfNeeded();
      if (!mounted) {
        return;
      }

      final rtmpUrl = _room.rtmpUrl?.trim();
      final streamKey = _room.streamKey?.trim();

      if (rtmpUrl == null ||
          rtmpUrl.isEmpty ||
          streamKey == null ||
          streamKey.isEmpty) {
        setState(() {
          _isTogglingStream = false;
        });
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Unable to start live because the RTMP URL or stream key is missing.',
          );
        }
        return;
      }

      final fullUrl = _buildStreamUrl(rtmpUrl, streamKey);

      // Start RTMP Streaming
      await _controller?.startVideoStreaming(fullUrl);

      if (mounted) {
        setState(() {
          _isStreaming = true;
          _isTogglingStream = false;
        });
        _startHeartbeat();
        AppSnackBar.showSuccess(context, 'Connected to RTMP. You are live.');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _isTogglingStream = false;
        });
        AppSnackBar.showError(context, 'Error starting stream: $error');
      }
    }
  }

  Future<void> _togglePause() async {
    if (!_isStreaming || _isTogglingPause) {
      return;
    }

    setState(() {
      _isTogglingPause = true;
    });

    try {
      if (_isPaused) {
        await ref.read(liveRepositoryProvider).resumeLive(_room.id);
        if (mounted) {
          setState(() {
            _isPaused = false;
          });
          AppSnackBar.showSuccess(context, 'Live resumed.');
        }
      } else {
        await ref.read(liveRepositoryProvider).pauseLive(_room.id);
        if (mounted) {
          setState(() {
            _isPaused = true;
          });
          AppSnackBar.showSuccess(context, 'Live paused (BRB).');
        }
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.showError(context, 'Error toggling pause: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingPause = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _controller == null || !_isInitialized) return;

    // Increment index and wrap around
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

    // Stop streaming if active before switching (rtmp_broadcaster limitation)
    final wasStreaming = _isStreaming;
    if (_isStreaming) {
      _stopHeartbeat();
      await _controller?.stopVideoStreaming();
      setState(() {
        _isStreaming = false;
      });
    }

    await _setupCameraController(_cameras[_currentCameraIndex]);

    // Restart stream if it was active
    if (wasStreaming && mounted) {
      await _toggleStreaming();
    }
  }

  Future<void> _closeBroadcaster() async {
    _stopHeartbeat();
    if (_isStreaming) {
      try {
        await _controller?.stopVideoStreaming();
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }

    context.go('/home');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _stopHeartbeat();
    if (_isStreaming) {
      _controller?.stopVideoStreaming();
    }
    _controller?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(
      liveRoomCommentsViewModelProvider(widget.room.id),
    );

    // Watch gifts for animation overlay
    ref.watch(liveRoomGiftsViewModelProvider(widget.room.id));

    ref.listen<LiveRoomCommentsState>(
      liveRoomCommentsViewModelProvider(widget.room.id),
      (previous, next) {
        final errorMessage = next.errorMessage;
        if (errorMessage == null || errorMessage == previous?.errorMessage) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
        ref
            .read(liveRoomCommentsViewModelProvider(widget.room.id).notifier)
            .clearError();
      },
    );

    if (!_isInitialized ||
        _controller == null ||
        _controller!.value.isInitialized != true) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Scale and Crop logic to ensure full screen
    final size = MediaQuery.of(context).size;
    final screenRatio = size.aspectRatio;
    final cameraRatio = _controller!.value.aspectRatio;

    // We want the preview to COVER the screen, so we scale it up.
    // If the device is narrower than the camera frame (typical portrait),
    // we need to scale based on height so width overflows.
    double scale = 1.0;
    if (screenRatio < cameraRatio) {
      scale = cameraRatio / screenRatio;
    } else {
      scale = screenRatio / cameraRatio;
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview: Immersive Scale & Crop
            Center(
              child: Transform.scale(
                scale: scale,
                child: AspectRatio(
                  aspectRatio: cameraRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black87],
                  stops: [0.0, 0.35, 1.0],
                ),
              ),
            ),
            if (_showCountdown)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Text(
                    '$_countdownSeconds',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            GiftAnimationOverlay(roomId: widget.room.id),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _closeBroadcaster,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        Row(
                          children: [
                            if (!_showCountdown) ...[
                              if (_isStreaming)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _PauseButton(
                                    isPaused: _isPaused,
                                    isLoading: _isTogglingPause,
                                    onPressed: _togglePause,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _BroadcasterControlButton(
                                  isStreaming: _isStreaming,
                                  isToggling: _isTogglingStream,
                                  onPressed: _toggleStreaming,
                                ),
                              ),
                            ],
                            if (_isStreaming) ...[
                              if (!_isPaused)
                                Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PAUSED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text(
                                  '${commentsState.viewerCount} watching',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            if (_cameras.length > 1)
                              IconButton(
                                onPressed: _switchCamera,
                                icon: const Icon(
                                  Icons.flip_camera_ios,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isStreaming || commentsState.comments.isNotEmpty)
                            LiveCommentsOverlay(
                              comments: commentsState.comments,
                              isSending: commentsState.isSending,
                              onSendComment: (message) => ref
                                  .read(
                                    liveRoomCommentsViewModelProvider(
                                      widget.room.id,
                                    ).notifier,
                                  )
                                  .sendComment(message),
                            ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({
    required this.isPaused,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isPaused;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(4),
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                isPaused ? 'RESUME' : 'PAUSE',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}

class _BroadcasterControlButton extends StatelessWidget {
  const _BroadcasterControlButton({
    required this.isStreaming,
    required this.isToggling,
    required this.onPressed,
  });

  final bool isStreaming;
  final bool isToggling;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isToggling ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isStreaming ? Colors.red : AppColors.electricPurple,
          borderRadius: BorderRadius.circular(4),
        ),
        child: isToggling
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                isStreaming ? 'END' : 'GO LIVE',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}

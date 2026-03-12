import 'dart:async';

import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_room.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/app_snackbar.dart';

class BroadcasterScreen extends ConsumerStatefulWidget {
  const BroadcasterScreen({super.key, required this.room});

  final LiveRoom room;

  @override
  ConsumerState<BroadcasterScreen> createState() => _BroadcasterScreenState();
}

class _BroadcasterScreenState extends ConsumerState<BroadcasterScreen>
    with WidgetsBindingObserver {
  ApiVideoLiveStreamController? _controller;
  late LiveRoom _room;
  bool _isStreaming = false;
  bool _isInitialized = false;
  bool _isResolvingRoom = false;
  bool _isTogglingStream = false;
  String? _streamDebugMessage;

  // Countdown state
  int _countdownSeconds = 5;
  bool _showCountdown = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
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

      final controller = ApiVideoLiveStreamController(
        initialVideoConfig: VideoConfig(
          resolution: Resolution.RESOLUTION_480,
          fps: AppConstants.videoFps,
          bitrate: AppConstants.videoBitrate,
        ),
        initialAudioConfig: AudioConfig(
          bitrate: AppConstants.audioBitrate,
        ),
        onConnectionSuccess: () {
          debugPrint('Connection Success');
          if (mounted) {
            setState(() {
              _isStreaming = true;
              _isTogglingStream = false;
            });
            AppSnackBar.showSuccess(context, 'Connected to RTMP. You are live.');
          }
        },
        onConnectionFailed: (error) {
          debugPrint('Connection Failed: $error');
          if (mounted) {
            setState(() {
              _isStreaming = false;
              _isTogglingStream = false;
              _streamDebugMessage = error;
            });
            AppSnackBar.showError(context, 'Connection Failed: $error');
          }
        },
        onDisconnection: () {
          debugPrint('Disconnected');
          if (mounted) {
            setState(() {
              _isStreaming = false;
              _isTogglingStream = false;
            });
          }
        },
      );

      await controller.initialize();
      controller.setIsMuted(false);
      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive && _isStreaming) {
      await _controller?.stopStreaming();
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
        await _controller?.stopStreaming();
        // UI updated in callbacks
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

      await _controller?.startStreaming(url: rtmpUrl, streamKey: streamKey);
      // callbacks handle success/fail
    } catch (error) {
      if (mounted) {
        setState(() {
          _isTogglingStream = false;
          _streamDebugMessage = '$error';
        });
        AppSnackBar.showError(context, 'Error starting stream: $error');
      }
    }
  }

  void _copyStreamUrl() {
    final rtmpUrl = _room.rtmpUrl;
    final streamKey = _room.streamKey;
    if (rtmpUrl == null || streamKey == null) {
      return;
    }

    Clipboard.setData(ClipboardData(text: _buildStreamUrl(rtmpUrl, streamKey)));
    AppSnackBar.showSuccess(context, 'RTMP URL copied.');
  }

  Future<void> _switchCamera() async {
    if (_controller == null || !_isInitialized) return;
    try {
      await _controller?.switchCamera();
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Failed to switch camera: $e');
      }
    }
  }

  Future<void> _closeBroadcaster() async {
    if (_isStreaming) {
      try {
        await _controller?.stopStreaming();
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
    if (_isStreaming) {
      _controller?.stopStreaming();
    }
    _controller?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ApiVideoCameraPreview(controller: _controller!),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                          if (_isStreaming)
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
                            ),
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
                  // Minimalist Control Button
                  if (!_showCountdown)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _BroadcasterControlButton(
                          isStreaming: _isStreaming,
                          isToggling: _isTogglingStream,
                          onPressed: _toggleStreaming,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
    return SizedBox(
      width: 72,
      height: 72,
      child: IconButton(
        onPressed: isToggling ? null : onPressed,
        padding: EdgeInsets.zero,
        icon: Container(
          decoration: BoxDecoration(
            color: isStreaming ? Colors.red : AppColors.electricPurple,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isStreaming ? Colors.red : AppColors.electricPurple)
                    .withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: isToggling
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isStreaming ? Icons.stop_rounded : Icons.sensors_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
        ),
      ),
    );
  }
}



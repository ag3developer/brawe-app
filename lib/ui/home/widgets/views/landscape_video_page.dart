import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

/// Vídeo horizontal (gravação de tela, 16:9…) em tela cheia, girado para
/// paisagem. Usa o MESMO controller do feed: continua do mesmo ponto e, ao
/// sair, o feed segue de onde parou. O app volta a ficar só em retrato.
class LandscapeVideoPage extends StatefulWidget {
  const LandscapeVideoPage({super.key, required this.controller});

  final VideoPlayerController controller;

  static Future<void> open(BuildContext context, VideoPlayerController controller) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => LandscapeVideoPage(controller: controller),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<LandscapeVideoPage> createState() => _LandscapeVideoPageState();
}

class _LandscapeVideoPageState extends State<LandscapeVideoPage> {
  bool _controls = true;
  Timer? _hideTimer;

  VideoPlayerController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!_c.value.isPlaying) _c.play();
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _c.value.isPlaying) setState(() => _controls = false);
    });
  }

  void _onTap() {
    setState(() => _controls = !_controls);
    if (_controls) _scheduleHide();
  }

  void _togglePlay() {
    setState(() => _c.value.isPlaying ? _c.pause() : _c.play());
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _c.value.aspectRatio == 0 ? 16 / 9 : _c.value.aspectRatio,
                child: VideoPlayer(_c),
              ),
            ),
            AnimatedOpacity(
              opacity: _controls ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_controls,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black45, Colors.transparent, Colors.transparent, Colors.black54],
                          stops: [0, 0.25, 0.7, 1],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(LucideIcons.minimize, color: Colors.white),
                        ),
                      ),
                    ),
                    Center(
                      child: ValueListenableBuilder<VideoPlayerValue>(
                        valueListenable: _c,
                        builder: (_, v, _) => IconButton(
                          iconSize: 56,
                          onPressed: _togglePlay,
                          icon: Icon(
                            v.isPlaying ? LucideIcons.pause : LucideIcons.play,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: VideoProgressIndicator(
                            _c,
                            allowScrubbing: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            colors: VideoProgressColors(
                              playedColor: Colors.white,
                              bufferedColor: Colors.white.withValues(alpha: 0.35),
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
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

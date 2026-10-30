import 'package:flutter/material.dart';

import '../../../../../domain/models/live_viewer_event.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../core/themes/app_colors.dart';

/// Animated toast shown to the streamer when a viewer joins the room.
class ViewerJoinedToast extends StatelessWidget {
  const ViewerJoinedToast({
    super.key,
    required this.event,
    required this.controller,
  });

  final LiveViewerEvent event;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    final fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: fade,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.braweBlue.withValues(alpha: 0.85),
                  AppColors.braweBlue.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.braweBlue.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.white24,
                  backgroundImage: (event.viewerAvatar != null && event.viewerAvatar!.isNotEmpty)
                      ? NetworkImage(event.viewerAvatar!)
                      : null,
                  child: (event.viewerAvatar == null || event.viewerAvatar!.isEmpty)
                      ? Text(
                          event.viewerName.isEmpty ? '?' : event.viewerName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).broadcasterViewerJoined(event.viewerName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('👋', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

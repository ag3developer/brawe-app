import 'package:flutter/material.dart';

/// Circular action button used inside the streamer's [LiveActionBar].
///
/// Supports loading state, glow effect, flat (translucent) variant and an
/// optional small badge anchored on the top-right.
class ActionBtn extends StatelessWidget {
  const ActionBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.loading = false,
    this.glow = false,
    this.flat = false,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;
  final bool glow;
  final bool flat;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: loading || disabled ? null : onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: flat ? Colors.black.withValues(alpha: 0.4) : color.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: flat ? Border.all(color: Colors.white24) : null,
                    boxShadow: glow && !disabled
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: loading
                      ? const Center(
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        )
                      : Icon(icon, color: Colors.white, size: 22),
                ),
                if (badge != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(badge!, style: const TextStyle(fontSize: 8)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: disabled ? 0.4 : 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

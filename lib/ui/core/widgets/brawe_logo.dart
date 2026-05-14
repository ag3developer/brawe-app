import 'package:flutter/material.dart';

/// Reusable Brawe brand mark: "B" icon + "Live your way" tagline,
/// matching the web app header (frontend/components: ConnectLayoutClient).
class BraweLogo extends StatelessWidget {
  final double iconSize;
  final bool showTagline;
  final Color? taglineColor;
  final MainAxisAlignment alignment;

  const BraweLogo({
    super.key,
    this.iconSize = 36,
    this.showTagline = true,
    this.taglineColor,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tagColor = taglineColor ??
        (isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey.shade600);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        Image.asset(
          'assets/images/brawe-icon.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),
        if (showTagline) ...[
          const SizedBox(width: 10),
          Text(
            'Live your way',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: tagColor,
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Forces the dark theme for immersive media screens (lives, stories,
/// broadcasting) regardless of the user's preferred theme mode.
///
/// This is the same pattern used by Instagram, TikTok and X — content
/// pages that are dominated by media remain dark for contrast and
/// "cinema" feel, while chrome (home, settings, lists) respects the
/// user's theme preference.
class ForceDarkTheme extends StatelessWidget {
  const ForceDarkTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark(),
      child: child,
    );
  }
}

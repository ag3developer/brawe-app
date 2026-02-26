import 'package:flutter/material.dart';

import 'ui/core/themes/app_theme.dart';
import 'ui/feed/widgets/feed_screen.dart';

void main() {
  runApp(const BraweApp());
}

class BraweApp extends StatelessWidget {
  const BraweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brawe',
      theme: AppTheme.dark(),
      home: const FeedScreen(),
    );
  }
}

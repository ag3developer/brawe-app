import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/core/themes/app_theme.dart';
import 'ui/auth/widgets/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: BraweApp()));
}

class BraweApp extends StatelessWidget {
  const BraweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brawe',
      theme: AppTheme.dark(),
      home: const LoginScreen(),
    );
  }
}

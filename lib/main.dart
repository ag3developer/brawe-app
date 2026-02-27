import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routing/router.dart';
import 'ui/core/themes/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: BraweApp()));
}

class BraweApp extends ConsumerWidget {
  const BraweApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Brawe',
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}

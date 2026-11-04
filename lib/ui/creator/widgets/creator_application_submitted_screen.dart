import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

class CreatorApplicationSubmittedScreen extends ConsumerWidget {
  const CreatorApplicationSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF10B981)],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.45),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.check,
                    size: 64, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                s.creatorSubmittedTitle,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                s.creatorSubmittedBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(LucideIcons.route),
                label: Text(s.creatorSubmittedTrack),
                onPressed: () => context.go('/creator/status'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: context.colors.accentPrimary,
                  foregroundColor: context.colors.textOnAccent,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(s.creatorSubmittedHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

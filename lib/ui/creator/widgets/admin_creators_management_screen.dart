import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_l10n.dart';
import '../widgets/creator_tier_badge.dart';

/// Tela placeholder do "Gerenciar Creators" — usa o mesmo backend (lista
/// admin de applications APPROVED) e os controllers existentes.
/// Implementação inicial: lista filtrada por status=approved + atalho de
/// "mover de tier".
class AdminCreatorsManagementScreen extends ConsumerWidget {
  const AdminCreatorsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.adminCreatorsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.adminCreatorsFilterAll,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              )),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in kCreatorTiersOrder)
                CreatorTierBadge(tier: t, size: 22, showLabel: true),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.adminCreatorsActionEdit,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 6),
                Text(
                  'Use a lista de inscrições aprovadas para editar tiers, '
                  'badges e destaque por enquanto. UI dedicada vem em '
                  'próxima iteração.',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

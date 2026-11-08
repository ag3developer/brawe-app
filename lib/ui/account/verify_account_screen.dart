// "Verificar minha conta": situação da identidade (selo azul) e da empresa (CNPJ), com o próximo passo.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repositories/kyc_repository.dart';
import '../../gen/l10n/app_localizations.dart';
import '../core/themes/brawe_colors.dart';
import '../core/ui/grouped_list.dart';
import '../core/ui/verified_badge.dart';

/// Texto e cor da situação (none · pending · approved · rejected).
(String, Color) kycStateLabel(BuildContext context, String state) {
  final s = S.of(context);
  final c = context.colors;
  return switch (state) {
    'approved' => (s.kycApproved, c.success),
    'pending' => (s.kycInReview, c.warning),
    'rejected' => (s.kycRejected, c.danger),
    _ => (s.kycNotStarted, c.textSecondary),
  };
}

class VerifyAccountScreen extends ConsumerWidget {
  const VerifyAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final colors = context.colors;
    final async = ref.watch(kycStatusProvider);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.kycTitle),
        centerTitle: true,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e.toString().isEmpty ? s.kycLoadError : e.toString(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(kycStatusProvider),
                child: Text(s.boostRetry),
              ),
            ],
          ),
        ),
        data: (k) {
          final (idLabel, idColor) = kycStateLabel(context, k.identity);
          final (bizLabel, bizColor) = kycStateLabel(context, k.business);
          final canStartId = k.identity == 'none' || k.identity == 'rejected';
          final canStartBiz =
              k.verified && (k.business == 'none' || k.business == 'rejected');
          return RefreshIndicator.adaptive(
            onRefresh: () async => ref.invalidate(kycStatusProvider),
            child: GroupedBody(
              children: [
                // cabeçalho
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 26),
                  child: Column(
                    children: [
                      k.verified
                          ? const VerifiedBadge(size: 56)
                          : Icon(
                              LucideIcons.badgeCheck,
                              size: 56,
                              color: colors.accentPrimary,
                            ),
                      const SizedBox(height: 14),
                      Text(
                        k.verified ? s.kycHeaderDone : s.kycHeaderTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.kycHeaderBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                GroupedSection(
                  caption: s.kycIdentityCaption,
                  footer: k.identity == 'rejected' && k.identityReason != null
                      ? s.kycRejectedReason(k.identityReason!)
                      : s.kycIdentityFooter,
                  children: [
                    GroupedRow(
                      icon: LucideIcons.scanFace,
                      title: s.kycIdentityRow,
                      subtitle: s.kycIdentityRowHint,
                      value: idLabel,
                      valueColor: idColor,
                      onTap: canStartId
                          ? () => context.push('/account/verify/identity')
                          : null,
                    ),
                  ],
                ),
                GroupedSection(
                  caption: s.kycBusinessCaption,
                  footer: k.business == 'rejected' && k.businessReason != null
                      ? s.kycRejectedReason(k.businessReason!)
                      : (k.verified
                            ? s.kycBusinessFooter
                            : s.kycBusinessLocked),
                  children: [
                    GroupedRow(
                      icon: LucideIcons.building2,
                      title: s.kycBusinessRow,
                      subtitle: k.businessName ?? s.kycBusinessRowHint,
                      value: bizLabel,
                      valueColor: bizColor,
                      onTap: canStartBiz
                          ? () => context.push('/account/verify/business')
                          : null,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.lock,
                        size: 14,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.kycPrivacy,
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// BRAWE LIVE — Go-Live Gate Sheet
// ----------------------------------------------------------------------------
// Bottom sheet que aparece quando o usuário tenta abrir uma live. Faz a
// checagem em `liveEligibilityProvider` e:
//   • can_go_live=true  → navega direto para /live/start
//   • missing=[avatar]  → CTA "Adicionar foto" → /edit-profile
//   • missing=[creator] → CTA "Inscrever-se" → /creator/intro
//   • erro              → mensagem amigável + retry
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/live_eligibility.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/live_eligibility_view_model.dart';

/// Mostra o bottom-sheet de gate. Após resolvido, se elegível, navega
/// automaticamente para /live/start.
Future<void> showLiveGateSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => const _LiveGateSheet(),
  );
}

class _LiveGateSheet extends ConsumerWidget {
  const _LiveGateSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(liveEligibilityProvider);
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 12, 20, MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44, height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          async.when(
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Column(
                children: [
                  CircularProgressIndicator(color: colors.accentPrimary),
                  const SizedBox(height: 14),
                  Text(
                    'Verificando permissões…',
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            error: (e, _) => _ErrorBlock(
              onRetry: () => ref.invalidate(liveEligibilityProvider),
              onClose: () => Navigator.of(context).pop(),
            ),
            data: (elig) {
              if (elig.canGoLive) {
                // Pop + navega para /live/start no próximo frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    context.push('/live/start');
                  }
                });
                return const SizedBox(height: 60, child: Center(
                  child: CircularProgressIndicator(),
                ));
              }
              return _BlockedBody(elig: elig);
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onClose;
  const _ErrorBlock({required this.onRetry, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Icon(Icons.cloud_off_rounded, color: colors.danger, size: 48),
        const SizedBox(height: 12),
        Text(
          'Não foi possível verificar agora',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Verifique sua conexão e tente novamente.',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, fontSize: 13.5),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onClose,
                child: const Text('Fechar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accentPrimary,
                  foregroundColor: colors.textOnAccent,
                ),
                child: const Text('Tentar novamente'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BlockedBody extends StatelessWidget {
  final LiveEligibility elig;
  const _BlockedBody({required this.elig});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Prioridade: avatar primeiro (perfil incompleto bloqueia tudo)
    final missingAvatar = elig.needsAvatar;
    final missingCreator = elig.needsCreator;

    final IconData icon;
    final String title;
    final String subtitle;
    final String ctaLabel;
    final String ctaRoute;
    final List<Color> gradient;

    if (missingAvatar) {
      icon = Icons.account_circle_outlined;
      title = 'Adicione uma foto de perfil';
      subtitle =
          'Para garantir a qualidade da plataforma, lives só podem ser '
          'iniciadas por usuários com foto de perfil.';
      ctaLabel = 'Adicionar foto agora';
      ctaRoute = '/edit-profile';
      gradient = const [Color(0xFF3B82F6), Color(0xFF8B5CF6)];
    } else if (missingCreator) {
      icon = Icons.workspace_premium_rounded;
      title = 'Live é exclusivo do Brawe Creator Network';
      subtitle =
          'Para garantir audiência real e proteger os criadores, transmissões '
          'ao vivo são liberadas após aprovação no programa. É grátis e leva '
          'poucos minutos.';
      ctaLabel = 'Inscrever-se no programa';
      ctaRoute = '/creator/intro';
      gradient = const [Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFFF59E0B)];
    } else {
      // fallback genérico (não deveria cair aqui)
      icon = Icons.lock_outline_rounded;
      title = 'Live indisponível';
      subtitle = elig.message;
      ctaLabel = 'Fechar';
      ctaRoute = '';
      gradient = const [Color(0xFF94A3B8), Color(0xFF64748B)];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 88, width: 88,
          margin: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.45),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 22),
        if (missingAvatar || missingCreator) ...[
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              if (ctaRoute.isNotEmpty) context.push(ctaRoute);
            },
            icon: Icon(
              missingAvatar
                  ? Icons.camera_alt_rounded
                  : Icons.rocket_launch_rounded,
            ),
            label: Text(ctaLabel),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: colors.accentPrimary,
              foregroundColor: colors.textOnAccent,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Agora não',
              style: TextStyle(color: colors.textTertiary, fontSize: 13.5),
            ),
          ),
        ] else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
      ],
    );
  }
}

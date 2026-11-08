// Tipo de conta: Pessoal · Criador · Artista (troca livre, com confirmação) · Empresa (exige verificação).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repositories/kyc_repository.dart';
import '../../domain/models/profile.dart';
import '../../gen/l10n/app_localizations.dart';
import '../core/themes/brawe_colors.dart';
import '../core/ui/grouped_list.dart';
import '../edit_profile/view_models/edit_profile_view_model.dart';

/// Nome e descrição de cada tipo (usado também no Editar perfil).
(String, String, IconData) accountTypeInfo(S s, AccountType t) => switch (t) {
  AccountType.consumer => (
    s.acctPersonal,
    s.acctPersonalHint,
    LucideIcons.userRound,
  ),
  AccountType.creator => (
    s.acctCreator,
    s.acctCreatorHint,
    LucideIcons.sparkles,
  ),
  AccountType.musician => (s.acctArtist, s.acctArtistHint, LucideIcons.mic),
  AccountType.business => (
    s.acctBusiness,
    s.acctBusinessHint,
    LucideIcons.building2,
  ),
};

class AccountTypeScreen extends ConsumerStatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  ConsumerState<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends ConsumerState<AccountTypeScreen> {
  AccountType? _busy;

  Future<void> _choose(
    AccountType current,
    AccountType next,
    KycStatus? kyc,
  ) async {
    if (next == current || _busy != null) return;
    final s = S.of(context);
    HapticFeedback.selectionClick();

    // Empresa: precisa de identidade verificada + CNPJ aprovado
    if (next == AccountType.business &&
        !(kyc?.verified == true && kyc?.business == 'approved')) {
      await _businessSteps(kyc);
      return;
    }

    final (name, _, _) = accountTypeInfo(s, next);
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(s.acctConfirmTitle(name)),
        content: Text(s.acctConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.acctConfirmAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = next);
    try {
      await ref.read(kycRepositoryProvider).changeAccountType(_wire(next));
      ref.invalidate(editProfileViewModelProvider);
      ref.invalidate(kycStatusProvider);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.acctChanged(name)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // artista: já leva para completar a identidade artística
      if (next == AccountType.musician) {
        context.pushReplacement('/artist-profile');
      } else {
        context.pop();
      }
    } on KycFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message.isNotEmpty ? e.message : s.acctChangeFailed,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  String _wire(AccountType t) => switch (t) {
    AccountType.consumer => 'consumer',
    AccountType.creator => 'creator',
    AccountType.musician => 'musician',
    AccountType.business => 'business',
  };

  /// Explica o que falta para virar Empresa e leva direto ao passo certo.
  Future<void> _businessSteps(KycStatus? kyc) async {
    final s = S.of(context);
    final colors = context.colors;
    final idOk = kyc?.verified == true;
    final bizState = kyc?.business ?? 'none';
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useRootNavigator: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.acctBusinessStepsTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.acctBusinessStepsBody,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              _Step(
                n: 1,
                title: s.acctStepIdentity,
                done: idOk,
                pending: kyc?.identity == 'pending',
              ),
              const SizedBox(height: 10),
              _Step(
                n: 2,
                title: s.acctStepBusiness,
                done: bizState == 'approved',
                pending: bizState == 'pending',
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push(
                      idOk ? '/account/verify/business' : '/account/verify',
                    );
                  },
                  child: Text(
                    idOk ? s.acctStepBusinessAction : s.acctStepIdentityAction,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final current =
        ref.watch(editProfileViewModelProvider).value?.profile?.accountType ??
        AccountType.consumer;
    final kyc = ref.watch(kycStatusProvider).value;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.acctTitle),
        centerTitle: true,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: GroupedBody(
        children: [
          GroupedSection(
            footer: s.acctFooter,
            children: [
              for (final t in AccountType.values)
                Builder(
                  builder: (_) {
                    final (name, hint, icon) = accountTypeInfo(s, t);
                    final selected = t == current;
                    return GroupedRow(
                      icon: icon,
                      title: name,
                      subtitle: hint,
                      onTap: () => _choose(current, t, kyc),
                      trailing: _busy == t
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : selected
                          ? Icon(
                              LucideIcons.check,
                              size: 20,
                              color: colors.accentPrimary,
                            )
                          : (t == AccountType.business &&
                                !(kyc?.business == 'approved'))
                          ? Icon(
                              LucideIcons.lock,
                              size: 16,
                              color: colors.textTertiary,
                            )
                          : const SizedBox(width: 20),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.n,
    required this.title,
    required this.done,
    required this.pending,
  });
  final int n;
  final String title;
  final bool done;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? colors.success : colors.surfaceHighest,
          ),
          child: done
              ? Icon(LucideIcons.check, size: 16, color: colors.textOnAccent)
              : Text(
                  '$n',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (pending)
          Text(
            s.kycInReview,
            style: TextStyle(
              color: colors.warning,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

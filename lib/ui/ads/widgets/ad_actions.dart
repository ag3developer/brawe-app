// Brawe Ads — ações comuns dos anúncios: botão de ação (CTA), visita ao perfil e menu ⋯
// (por que estou vendo isto · ocultar · ver menos do anunciante · denunciar).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/ads_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../domain/models/ad_models.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/view_models/follow_view_model.dart';

/// Anúncios ocultados nesta sessão (por campanha ou por anunciante) — somem de todos os feeds na hora.
final hiddenAdsProvider = NotifierProvider<HiddenAds, Set<String>>(
  HiddenAds.new,
);

class HiddenAds extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void hide(FeedAd ad, {bool owner = false}) {
    state = {
      ...state,
      owner && ad.advertiser != null ? 'owner:${ad.advertiser!.id}' : ad.adId,
    };
  }

  bool isHidden(FeedAd ad) =>
      state.contains(ad.adId) ||
      (ad.advertiser != null && state.contains('owner:${ad.advertiser!.id}'));
}

/// O que o botão do anúncio faz — segue o objetivo de quem impulsionou, para quem vê ir ao lugar certo:
/// seguidores → Seguir (segue na hora) · visualizações → Assistir vídeo / Ver publicação (abre o post) ·
/// visitas ao perfil → Ver perfil · mensagens → chat ou WhatsApp · live → Assistir à live.
/// Anúncio da marca: o botão que a marca escolheu (link, loja, perfil, chat, WhatsApp).
enum AdAction {
  follow,
  watch,
  openPost,
  profile,
  live,
  dm,
  whatsapp,
  store,
  link,
}

AdAction adActionFor(FeedAd ad) {
  if (ad.isLive) return AdAction.live;
  if (ad.ctaType == 'dm') return AdAction.dm;
  if (ad.ctaType == 'whatsapp' && ad.ctaUrl != null) return AdAction.whatsapp;
  if (ad.isBoost) {
    final hasPost = ad.contentType == 'post' && (ad.contentId ?? '').isNotEmpty;
    return switch (ad.objective) {
      'followers' => AdAction.follow,
      'views' when hasPost => ad.isVideo ? AdAction.watch : AdAction.openPost,
      _ => AdAction.profile,
    };
  }
  if (ad.ctaType == 'store') return AdAction.store;
  if (ad.ctaType == 'link' && ad.ctaUrl != null) return AdAction.link;
  return AdAction.profile;
}

/// Já segue o anunciante? (mesmo estado do botão Seguir do perfil)
bool adFollowing(WidgetRef ref, FeedAd ad) {
  final id = ad.advertiser?.id;
  if (id == null || adActionFor(ad) != AdAction.follow) return false;
  return ref.watch(followViewModelProvider(id)).value ?? false;
}

/// Texto do botão. [playing]: o vídeo já está tocando em tela cheia (Para você) — então "Ver publicação".
String adCtaLabel(
  BuildContext context,
  WidgetRef ref,
  FeedAd ad, {
  bool playing = false,
}) {
  final s = S.of(context);
  final custom = ad.ctaLabel.trim();
  return switch (adActionFor(ad)) {
    AdAction.follow => adFollowing(ref, ad) ? s.adsFollowingNow : s.adsFollow,
    AdAction.watch => playing ? s.adsSeePost : s.adsWatchVideo,
    AdAction.openPost => s.adsSeePost,
    AdAction.live => s.adsWatchLive,
    AdAction.dm => ad.isBoost || custom.isEmpty ? s.adsCtaMessage : custom,
    AdAction.whatsapp =>
      ad.isBoost || custom.isEmpty ? s.adsCtaWhatsapp : custom,
    AdAction.profile => ad.isBoost || custom.isEmpty ? s.adsSeeProfile : custom,
    AdAction.store || AdAction.link => custom.isEmpty ? s.adsLearnMore : custom,
  };
}

/// Toque no botão de ação: registra o evento certo e leva ao destino certo.
Future<void> openAdCta(BuildContext context, WidgetRef ref, FeedAd ad) async {
  final repo = ref.read(adsRepositoryProvider);
  final router = GoRouter.of(context);
  final adv = ad.advertiser;
  switch (adActionFor(ad)) {
    case AdAction.follow:
      if (adv == null) return;
      if (adFollowing(ref, ad)) {
        // já segue: o botão leva ao perfil
        repo.track(ad.token, 'profile_visit');
        router.push('/profile/${adv.id}');
        return;
      }
      HapticFeedback.mediumImpact();
      repo.track(ad.token, 'follow');
      await ref.read(followViewModelProvider(adv.id).notifier).toggleFollow();
    case AdAction.watch || AdAction.openPost:
      repo.track(ad.token, 'click');
      router.push('/post/${ad.contentId}');
    case AdAction.live:
      repo.track(ad.token, 'click');
      router.push('/live/${ad.contentId}');
    case AdAction.profile:
      if (adv == null) return;
      repo.track(ad.token, 'profile_visit');
      router.push('/profile/${adv.id}');
    case AdAction.store:
      if (adv == null) return;
      repo.track(ad.token, 'click');
      router.push('/profile/${adv.id}?section=shop');
    case AdAction.whatsapp:
      repo.track(ad.token, 'contact_whatsapp');
      await launchUrl(
        Uri.parse(ad.ctaUrl!),
        mode: LaunchMode.externalApplication,
      );
    case AdAction.dm:
      if (adv == null) return;
      repo.track(ad.token, 'contact_dm');
      try {
        final conv = await ref
            .read(chatRepositoryProvider)
            .startConversation(participantId: adv.id);
        router.push(
          '/chat/$conv',
          extra: {
            'participantName': adv.displayName,
            'participantAvatarUrl': adv.avatarUrl,
            'participantId': adv.id,
          },
        );
      } catch (_) {}
    case AdAction.link:
      repo.track(ad.token, 'click');
      await launchUrl(
        Uri.parse(ad.ctaUrl!),
        mode: LaunchMode.externalApplication,
      );
  }
}

/// Toque na foto/vídeo do anúncio (não no botão): nunca segue sem querer — abre o post, senão o botão.
Future<void> openAdMedia(BuildContext context, WidgetRef ref, FeedAd ad) async {
  if (adActionFor(ad) != AdAction.follow) return openAdCta(context, ref, ad);
  ref.read(adsRepositoryProvider).track(ad.token, 'click');
  final router = GoRouter.of(context);
  if (ad.contentType == 'post' && (ad.contentId ?? '').isNotEmpty) {
    router.push('/post/${ad.contentId}');
  } else if (ad.advertiser != null) {
    router.push('/profile/${ad.advertiser!.id}');
  }
}

void openAdvertiserProfile(BuildContext context, WidgetRef ref, FeedAd ad) {
  if (ad.advertiser == null) return;
  ref.read(adsRepositoryProvider).track(ad.token, 'profile_visit');
  GoRouter.of(context).push('/profile/${ad.advertiser!.id}');
}

/// Menu ⋯ do anúncio. [onHidden] tira o anúncio da tela (ex.: passa para o próximo item).
Future<void> showAdMenu(
  BuildContext context,
  WidgetRef ref,
  FeedAd ad, {
  VoidCallback? onHidden,
  bool dark = false,
}) async {
  final s = S.of(context);
  final repo = ref.read(adsRepositoryProvider);
  final choice = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuTile(
            icon: LucideIcons.info,
            label: s.adsWhy,
            onTap: () => Navigator.pop(ctx, 'why'),
          ),
          _MenuTile(
            icon: LucideIcons.eyeOff,
            label: s.adsHide,
            onTap: () => Navigator.pop(ctx, 'hide'),
          ),
          if (ad.advertiser != null)
            _MenuTile(
              icon: LucideIcons.ban,
              label: s.adsLessFrom(ad.advertiser!.displayName),
              onTap: () => Navigator.pop(ctx, 'less'),
            ),
          _MenuTile(
            icon: LucideIcons.flag,
            label: s.adsReport,
            danger: true,
            onTap: () => Navigator.pop(ctx, 'report'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (!context.mounted || choice == null) return;
  switch (choice) {
    case 'why':
      await _showWhy(context, ref, ad);
    case 'hide':
      repo.track(ad.token, 'hide', scope: 'campaign');
      ref.read(hiddenAdsProvider.notifier).hide(ad);
      onHidden?.call();
      _toast(context, s.adsHidden);
    case 'less':
      repo.track(ad.token, 'hide', scope: 'owner');
      ref.read(hiddenAdsProvider.notifier).hide(ad, owner: true);
      onHidden?.call();
      _toast(context, s.adsHidden);
    case 'report':
      final reason = await _pickReason(context);
      if (reason == null || !context.mounted) return;
      repo.track(ad.token, 'report', reason: reason);
      ref.read(hiddenAdsProvider.notifier).hide(ad);
      onHidden?.call();
      _toast(context, s.adsReportThanks);
  }
}

void _toast(BuildContext context, String msg) =>
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );

Future<void> _showWhy(BuildContext context, WidgetRef ref, FeedAd ad) async {
  final s = S.of(context);
  final reasons = ValueNotifier<List<String>>(ad.why);
  ref
      .read(adsRepositoryProvider)
      .why(ad.token)
      .then((r) => reasons.value = r)
      .catchError((_) => ad.why);
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ValueListenableBuilder<List<String>>(
          valueListenable: reasons,
          builder: (_, list, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.adsWhy,
                style: Theme.of(
                  ctx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (ad.advertiser != null)
                Text(
                  s.adsWhyAdvertiser(ad.advertiser!.displayName),
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
              const SizedBox(height: 8),
              ...list.map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(LucideIcons.check, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(r)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                s.adsWhyFooter,
                style: Theme.of(
                  ctx,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(ctx).hintColor),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<String?> _pickReason(BuildContext context) {
  final s = S.of(context);
  final reasons = {
    'misleading': s.adsReasonMisleading,
    'offensive': s.adsReasonOffensive,
    'adult': s.adsReasonAdult,
    'prohibited': s.adsReasonProhibited,
    'repetitive': s.adsReasonRepetitive,
    'other': s.adsReasonOther,
  };
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              s.adsReport,
              style: Theme.of(
                ctx,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...reasons.entries.map(
            (e) => ListTile(
              title: Text(e.value),
              onTap: () => Navigator.pop(ctx, e.key),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, size: 20, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}

/// Selo "Patrocinado" discreto (texto, sem balão colorido), com tempo restante opcional.
class SponsoredLabel extends StatelessWidget {
  const SponsoredLabel({
    super.key,
    this.remaining,
    this.color = Colors.white70,
    this.size = 12.5,
  });
  final Duration? remaining;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final r = remaining;
    final time = r == null
        ? ''
        : ' · ${r.inMinutes}:${(r.inSeconds % 60).toString().padLeft(2, '0')}';
    return Text(
      '${S.of(context).adsSponsored}$time',
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

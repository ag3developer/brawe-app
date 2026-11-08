// Brawe Ads — "Impulsionar" nativo: Objetivo (com prévia) → Público → Orçamento → Revisar e pagar (em Coins).
// - Objetivo: visualizações, seguidores, visitas ao perfil ou mensagens (chat da Brawe ou WhatsApp).
// - Um conteúdo só tem um impulsionamento aberto (feito no app ou no site): se já existe, mostra a campanha.
// Sem Coins suficientes abre a recarga da loja (Apple/Google) — nunca o site.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/media/media_utils.dart';
import '../../../data/repositories/ads_repository.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/ad_models.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../wallet/widgets/top_up_coins_sheet.dart';
import 'boost_audience.dart';
import 'boost_preview.dart';

String brl(BuildContext context, num v) => NumberFormat.currency(
  locale: Localizations.localeOf(context).toString(),
  symbol: 'R\$',
  decimalDigits: v % 1 == 0 ? 0 : 2,
).format(v);

String coinsFmt(BuildContext context, num v) => NumberFormat.decimalPattern(
  Localizations.localeOf(context).toString(),
).format(v);

/// Resumo de uma linha do público (revisão e "Meus anúncios").
String audienceSummary(BuildContext context, BoostAudience a) {
  final s = S.of(context);
  if (a.auto) return '${s.boostAuto} · ${s.boostAllBrazil}';
  final where = switch (a.mode) {
    'radius' => '${s.boostKm('${a.radiusKm}')} · ${a.center?.label ?? ''}',
    'places' =>
      a.places.length <= 2
          ? a.places.map((p) => p.label).join(', ')
          : '${a.places.first.label} +${a.places.length - 1}',
    _ => s.boostAllBrazil,
  };
  final age = s.boostAgeRange(
    '${a.ageMin}',
    a.ageMax >= 65 ? '65+' : '${a.ageMax}',
  );
  return [
    where,
    age,
    if (a.interests.isNotEmpty) a.interests.take(3).join(', '),
  ].join(' · ');
}

class BoostFlowScreen extends ConsumerStatefulWidget {
  const BoostFlowScreen({
    super.key,
    required this.contentType,
    required this.contentId,
    this.preview,
  });
  final String contentType;
  final String contentId;

  /// dados do post para a prévia (vem do card; sem eles, o post é buscado)
  final BoostPreviewData? preview;

  @override
  ConsumerState<BoostFlowScreen> createState() => _BoostFlowScreenState();
}

class _BoostFlowScreenState extends ConsumerState<BoostFlowScreen> {
  AdsPublicConfig? _cfg;
  Object? _loadError;
  int _step = 0;
  final _audience = BoostAudience();
  double _daily = 20;
  int _days = 7;
  AdEstimate? _estimate;
  ({int coins, double coinBrl})? _quote;
  double? _balance;
  bool _paying = false;
  bool _done = false;
  Timer? _debounce;

  // objetivo e contato
  String _objective = 'views';
  String _via = 'dm';
  final _phone = TextEditingController();
  final _waMessage = TextEditingController();
  BoostPreviewData? _preview;

  /// impulsionamento já aberto para este conteúdo (feito no app ou no site)
  AdCampaign? _existing;

  static const _dailyPresets = [10.0, 20.0, 50.0, 100.0];
  static const _dayPresets = [3, 7, 14, 30];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // mensagem pronta do WhatsApp já vem preenchida (no idioma do app)
    if (_waMessage.text.isEmpty) {
      _waMessage.text = S.of(context).boostWhatsappMessageDefault;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _phone.dispose();
    _waMessage.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    if (widget.preview != null) {
      setState(() => _preview = widget.preview);
      return;
    }
    final me = ref.read(authStateProvider).value;
    var data = BoostPreviewData(name: me?.name ?? '', avatarUrl: me?.avatarUrl);
    if (widget.contentType == 'post') {
      try {
        final p = await ref
            .read(postRepositoryProvider)
            .getById(widget.contentId);
        final video = p.mediaType == 'video' || isVideoUrl(p.imageUrl);
        data = BoostPreviewData(
          name: p.author.name,
          avatarUrl: p.author.avatarUrl,
          imageUrl: video ? (p.coverUrl ?? p.imageUrl) : p.imageUrl,
          text: p.content,
          isVideo: video,
        );
      } catch (_) {}
    }
    if (mounted) setState(() => _preview = data);
  }

  /// Contato pronto? (WhatsApp exige número com DDD e a mensagem pronta)
  bool get _contactValid {
    if (_objective != 'contacts' || _via == 'dm') return true;
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 &&
        digits.length <= 13 &&
        _waMessage.text.trim().length >= 3;
  }

  /// Texto do botão que aparece no anúncio (prévia).
  String _ctaLabel(S s) {
    if (_objective == 'contacts') {
      return _via == 'dm' ? s.adsCtaMessage : s.adsCtaWhatsapp;
    }
    return widget.contentType == 'live' ? s.adsWatchLive : s.adsSeeProfile;
  }

  /// Botão enviado ao servidor (o rótulo segue a lista fixa do servidor).
  Map<String, dynamic>? get _ctaBody {
    if (_objective != 'contacts') return null;
    if (_via == 'dm') return {'type': 'dm', 'label': 'Enviar mensagem'};
    return {
      'type': 'whatsapp',
      'label': 'Chamar no WhatsApp',
      'phone': _phone.text.replaceAll(RegExp(r'\D'), ''),
      'message': _waMessage.text.trim(),
    };
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    try {
      final repo = ref.read(adsRepositoryProvider);
      _loadPreview();
      final results = await Future.wait([repo.config(), repo.campaigns()]);
      final cfg = results[0] as AdsPublicConfig;
      final open = (results[1] as List<AdCampaign>).where(
        (c) =>
            c.kind == 'boost' &&
            c.isOpen &&
            c.contentType == widget.contentType &&
            c.contentId == widget.contentId,
      );
      if (!mounted) return;
      if (open.isNotEmpty) {
        setState(() {
          _cfg = cfg;
          _existing = open.first;
        });
        return;
      }
      final dailies = _dailyPresets
          .where((d) => d >= cfg.boostMinDaily && d <= cfg.boostMaxDaily)
          .toList();
      final days = _dayPresets
          .where((d) => d >= cfg.boostMinDays && d <= cfg.boostMaxDays)
          .toList();
      setState(() {
        _cfg = cfg;
        if (!dailies.contains(_daily)) {
          _daily = dailies.isNotEmpty ? dailies.first : cfg.boostMinDaily;
        }
        if (!days.contains(_days)) {
          _days = days.isNotEmpty ? days.first : cfg.boostMinDays;
        }
      });
      _refreshNumbers();
      repo.coinBalance().then(
        (b) => mounted ? setState(() => _balance = b) : null,
      );
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  double get _total => _daily * _days;

  /// Público estimado + Coins do total (com espera curta para não chamar a cada toque).
  void _refreshNumbers() {
    final cfg = _cfg;
    if (cfg == null || !_audience.isValid) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final repo = ref.read(adsRepositoryProvider);
      final total = _total;
      final est = await repo.estimate({
        'kind': 'boost',
        'targeting': _audience.toTargeting(cfg),
        'daily_budget_brl': _daily,
        'billing': 'cpm',
        'bid_brl': cfg.boostCpm,
      });
      ({int coins, double coinBrl})? q;
      try {
        q = await repo.quote(total);
      } catch (_) {}
      if (!mounted || total != _total) return;
      setState(() {
        _estimate = est;
        _quote = q;
      });
    });
  }

  bool get _enough =>
      _quote != null && _balance != null && _balance! >= _quote!.coins;

  Future<void> _topUp() async {
    await TopUpCoinsSheet.show(context, reason: 'general');
    final b = await ref.read(adsRepositoryProvider).coinBalance();
    if (mounted) setState(() => _balance = b);
  }

  Future<void> _pay() async {
    final cfg = _cfg!;
    final s = S.of(context);
    setState(() => _paying = true);
    HapticFeedback.mediumImpact();
    try {
      await ref.read(adsRepositoryProvider).createAndSubmit({
        'kind': 'boost',
        'name':
            '${s.boostTitle} · ${DateFormat('dd/MM HH:mm').format(DateTime.now())}',
        'objective': _objective,
        'category': 'creators',
        if (_ctaBody != null) 'cta': _ctaBody,
        'content_type': widget.contentType,
        'content_id': widget.contentId,
        'daily_budget_brl': _daily.toStringAsFixed(2),
        'days': _days,
        'start_at': DateTime.now().toUtc().toIso8601String(),
        'targeting': _audience.toTargeting(cfg),
      });
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() => _done = true);
    } on AdsFailure catch (e) {
      if (!mounted) return;
      if (e.code == 'insufficient_coins') {
        await _topUp();
      } else if (e.code == 'already_boosted') {
        // feito no site enquanto esta tela estava aberta: mostra a campanha que já existe
        final id = (e.field ?? '').replaceFirst('campaign:', '');
        try {
          final c = await ref.read(adsRepositoryProvider).campaign(id);
          if (mounted) setState(() => _existing = c);
        } catch (_) {
          _snack(e.message);
        }
      } else {
        _snack(e.message.isNotEmpty ? e.message : s.boostError);
      }
    } catch (_) {
      if (mounted) _snack(s.boostError);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
  );

  void _back() {
    if (_step > 0 && !_done) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final steps = [
      s.boostStepGoal,
      s.boostStepAudience,
      s.boostStepBudget,
      s.boostStepReview,
    ];
    return PopScope(
      canPop: _step == 0 || _done,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              _step == 0 || _done ? LucideIcons.x : LucideIcons.arrowLeft,
            ),
            onPressed: _back,
          ),
          title: Text(
            _done ? '' : s.boostTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          bottom: _done || _cfg == null || _existing != null
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(34),
                  child: _StepBar(step: _step, labels: steps),
                ),
        ),
        body: _body(context),
        bottomNavigationBar: _done || _cfg == null || _existing != null
            ? null
            : _bottomBar(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final s = S.of(context);
    if (_loadError != null) {
      return _Centered(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _loadError is AdsFailure
                  ? (_loadError as AdsFailure).message
                  : s.boostError,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: _load, child: Text(s.boostRetry)),
          ],
        ),
      );
    }
    if (_cfg == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_done) {
      return _DoneView(
        onSeeAds: () => context.pushReplacement('/ads/campaigns'),
        onClose: () => context.pop(),
      );
    }
    if (_existing != null) {
      return _AlreadyBoostedView(
        campaign: _existing!,
        onOpen: () =>
            context.pushReplacement('/ads/campaigns/${_existing!.id}'),
      );
    }

    final child = switch (_step) {
      0 => _goalStep(context),
      1 => _audienceStep(context),
      2 => _budgetStep(context),
      _ => _reviewStep(context),
    };
    return _Centered(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (c, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(a),
              child: c,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(_step), child: child),
        ),
      ),
    );
  }

  Widget _audienceStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BoostAudienceEditor(
          audience: _audience,
          config: _cfg!,
          onChanged: () {
            setState(() {});
            _refreshNumbers();
          },
        ),
        const SizedBox(height: 20),
        _EstimateCard(estimate: _estimate),
      ],
    );
  }

  Widget _budgetStep(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final cfg = _cfg!;
    final dailies = _dailyPresets
        .where((d) => d >= cfg.boostMinDaily && d <= cfg.boostMaxDaily)
        .toList();
    final days = _dayPresets
        .where((d) => d >= cfg.boostMinDays && d <= cfg.boostMaxDays)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(s.boostPerDay),
        const SizedBox(height: 10),
        _ChipRow(
          items: [for (final d in dailies) (d, brl(context, d))],
          value: _daily,
          onChanged: (v) {
            setState(() => _daily = v);
            _refreshNumbers();
          },
        ),
        const SizedBox(height: 26),
        _SectionTitle(s.boostDuration),
        const SizedBox(height: 10),
        _ChipRow(
          items: [for (final d in days) (d, s.boostDaysN('$d'))],
          value: _days,
          onChanged: (v) {
            setState(() => _days = v);
            _refreshNumbers();
          },
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.boostTotal,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    brl(context, _total),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        _quote == null
                            ? '…'
                            : s.boostCoins(coinsFmt(context, _quote!.coins)),
                        key: ValueKey(_quote?.coins),
                        style: TextStyle(
                          color: colors.accentPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_estimate?.buysLabel != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      LucideIcons.eye,
                      size: 15,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _estimate!.buysLabel!,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Divider(height: 1, color: colors.divider),
              const SizedBox(height: 12),
              _BalanceRow(
                balance: _balance,
                needed: _quote?.coins,
                onTopUp: _topUp,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewStep(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              _ReviewRow(
                icon: LucideIcons.target,
                label: s.boostStepGoal,
                value: _objective == 'contacts'
                    ? '${_goalLabel(s, _objective)} · ${_via == 'dm' ? s.boostContactChat : s.boostContactWhatsapp}'
                    : _goalLabel(s, _objective),
                onEdit: () => setState(() => _step = 0),
              ),
              Divider(height: 1, color: colors.divider, indent: 56),
              _ReviewRow(
                icon: LucideIcons.users,
                label: s.boostStepAudience,
                value: audienceSummary(context, _audience),
                onEdit: () => setState(() => _step = 1),
              ),
              Divider(height: 1, color: colors.divider, indent: 56),
              _ReviewRow(
                icon: LucideIcons.wallet,
                label: s.boostStepBudget,
                value:
                    '${brl(context, _daily)} ${s.boostPerDayShort} · ${s.boostDaysN('$_days')}',
                onEdit: () => setState(() => _step = 2),
              ),
              Divider(height: 1, color: colors.divider, indent: 56),
              _ReviewRow(
                icon: LucideIcons.eye,
                label: s.boostEstimate,
                value: _estimate?.display ?? '…',
              ),
              Divider(height: 1, color: colors.divider, indent: 56),
              _ReviewRow(
                icon: LucideIcons.coins,
                label: s.boostTotal,
                value:
                    '${brl(context, _total)} · ${_quote == null ? '…' : s.boostCoins(coinsFmt(context, _quote!.coins))}',
                strong: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _BalanceRow(balance: _balance, needed: _quote?.coins, onTopUp: _topUp),
        const SizedBox(height: 26),
        if (_preview != null) ...[
          _PreviewSection(
            data: _preview!,
            cta: _ctaLabel(s),
            placements: _cfg!.boostPlacements,
          ),
          const SizedBox(height: 22),
        ],
        Text(
          s.boostTerms,
          style: TextStyle(
            color: colors.textTertiary,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _goalStep(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final goals = <(String, IconData, String)>[
      ('views', LucideIcons.eye, s.boostGoalViewsHint),
      ('followers', LucideIcons.userPlus, s.boostGoalFollowersHint),
      ('profile_visits', LucideIcons.circleUser, s.boostGoalProfileHint),
      ('contacts', LucideIcons.messageCircle, s.boostGoalContactsHint),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.boostGoalTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        for (final (key, icon, hint) in goals) ...[
          _GoalCard(
            selected: _objective == key,
            icon: icon,
            title: _goalLabel(s, key),
            subtitle: hint,
            onTap: () => setState(() => _objective = key),
          ),
          const SizedBox(height: 10),
        ],
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _objective != 'contacts'
              ? const SizedBox(width: double.infinity)
              : _contactBox(context),
        ),
        const SizedBox(height: 22),
        if (_preview != null)
          _PreviewSection(
            data: _preview!,
            cta: _ctaLabel(s),
            placements: _cfg!.boostPlacements,
          ),
      ],
    );
  }

  Widget _contactBox(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    InputDecoration deco(String label, {String? hint}) => InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: colors.surfaceHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.boostContactVia,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ViaOption(
                  selected: _via == 'dm',
                  icon: LucideIcons.messagesSquare,
                  title: s.boostContactChat,
                  onTap: () => setState(() => _via = 'dm'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ViaOption(
                  selected: _via == 'whatsapp',
                  icon: LucideIcons.phone,
                  title: s.boostContactWhatsapp,
                  onTap: () => setState(() => _via = 'whatsapp'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.info, size: 14, color: colors.textTertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _via == 'dm'
                      ? s.boostContactChatHint
                      : s.boostContactWhatsappHint,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (_via == 'whatsapp') ...[
            const SizedBox(height: 14),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              onChanged: (_) => setState(() {}),
              decoration: deco(s.boostWhatsappPhone, hint: '(11) 91234-5678'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _waMessage,
              maxLength: 300,
              minLines: 2,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: deco(s.boostWhatsappMessage),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    final s = S.of(context);
    final valid = switch (_step) {
      0 => _contactValid,
      1 => _audience.isValid,
      _ => true,
    };
    final last = _step == 3;
    final String label;
    VoidCallback? action;
    if (!last) {
      label = s.boostNext;
      action = valid ? () => setState(() => _step++) : null;
    } else if (_quote != null && _balance != null && !_enough) {
      label = s.boostTopUp;
      action = _topUp;
    } else {
      label = s.boostPay(
        _quote == null ? '…' : coinsFmt(context, _quote!.coins),
      );
      action = _quote == null || _paying ? null : _pay;
    }
    return SafeArea(
      top: false,
      child: _Centered(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: action,
              child: _paying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── peças ───────────────────────────────────────────────────────────────

/// Conteúdo centralizado com largura máxima (tablets e telas largas).
class _Centered extends StatelessWidget {
  const _Centered({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: child,
    ),
  );
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step, required this.labels});
  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Centered(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 3,
                      decoration: BoxDecoration(
                        color: i <= step
                            ? colors.accentPrimary
                            : colors.surfaceHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: i == step
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: i <= step
                            ? colors.textPrimary
                            : colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: context.colors.textPrimary,
      fontSize: 15.5,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _ChipRow<T> extends StatelessWidget {
  const _ChipRow({
    required this.items,
    required this.value,
    required this.onChanged,
  });
  final List<(T, String)> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(items[i].$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: items[i].$1 == value
                      ? colors.accentPrimary
                      : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: items[i].$1 == value
                        ? colors.accentPrimary
                        : colors.border,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      items[i].$2,
                      style: TextStyle(
                        color: items[i].$1 == value
                            ? colors.textOnAccent
                            : colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.estimate});
  final AdEstimate? estimate;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.users, size: 20, color: colors.accentPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.boostEstimate,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    estimate?.display ?? '…',
                    key: ValueKey(estimate?.display),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.balance,
    required this.needed,
    required this.onTopUp,
  });
  final double? balance;
  final int? needed;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final short = balance != null && needed != null && balance! < needed!;
    return Row(
      children: [
        Icon(
          short ? LucideIcons.circleAlert : LucideIcons.wallet,
          size: 17,
          color: short ? colors.warning : colors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            short
                ? s.boostInsufficient
                : s.boostBalance(
                    balance == null ? '…' : coinsFmt(context, balance!.floor()),
                  ),
            style: TextStyle(
              color: short ? colors.warning : colors.textSecondary,
              fontSize: 13.5,
              fontWeight: short ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
        if (short) TextButton(onPressed: onTopUp, child: Text(s.boostTopUp)),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onEdit,
    this.strong = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onEdit;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.textSecondary),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: strong ? 16 : 14.5,
                      fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              Icon(LucideIcons.pencil, size: 16, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.onSeeAds, required this.onClose});
  final VoidCallback onSeeAds;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return SafeArea(
      child: _Centered(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 520),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colors.accentPrimary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.rocket,
                    size: 40,
                    color: colors.accentPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                s.boostDoneTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                s.boostDoneHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onSeeAds,
                  child: Text(
                    s.boostSeeCampaigns,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: onClose, child: Text(s.boostFinish)),
            ],
          ),
        ),
      ),
    );
  }
}

String _goalLabel(S s, String key) => switch (key) {
  'followers' => s.boostGoalFollowers,
  'profile_visits' => s.boostGoalProfile,
  'contacts' => s.boostGoalContacts,
  _ => s.boostGoalViews,
};

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected
          ? colors.accentPrimary.withValues(alpha: 0.08)
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? colors.accentPrimary : colors.border,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? colors.accentPrimary : colors.textSecondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? colors.accentPrimary : Colors.transparent,
                  border: Border.all(
                    color: selected ? colors.accentPrimary : colors.border,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Icon(
                        LucideIcons.check,
                        size: 13,
                        color: colors.textOnAccent,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViaOption extends StatelessWidget {
  const _ViaOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? colors.accentPrimary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colors.accentPrimary : colors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? colors.accentPrimary : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.data,
    required this.cta,
    required this.placements,
  });
  final BoostPreviewData data;
  final String cta;
  final List<String> placements;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.boostPreview,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          s.boostPreviewHint,
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 14),
        BoostPlacementPreview(
          data: data,
          ctaLabel: cta,
          placements: placements,
        ),
      ],
    );
  }
}

class _AlreadyBoostedView extends StatelessWidget {
  const _AlreadyBoostedView({required this.campaign, required this.onOpen});
  final AdCampaign campaign;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return SafeArea(
      child: _Centered(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.accentPrimary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.rocket,
                  size: 36,
                  color: colors.accentPrimary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                s.boostAlreadyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                s.boostAlreadyHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${brl(context, campaign.spent)} ${s.myAdsOf(brl(context, campaign.totalBudget))}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onOpen,
                  child: Text(
                    s.boostSeeCampaign,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
}

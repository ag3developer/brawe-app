import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../data/repositories/live_repository.dart';
import '../../../../../core/utils/gift_tier_names.dart';
import '../../../../../domain/models/gift.dart';
import '../../../../../domain/models/live_goal.dart';
import '../../../../../domain/models/live_room_event.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../core/themes/brawe_colors.dart';
import '../../../../core/widgets/gift_icon.dart';
import '../../../../live_feed/view_models/gift_catalog_view_model.dart';
import '../../../../live_feed/view_models/live_room_comments_view_model.dart';
import '../competition/medal_colors.dart';
import '../overlays/gifts_overlay.dart';

const _gold = Color(0xFFFFC53D);
const _pink = Color(0xFFFF3D7F);

/// Texto curto da meta: "10 Rosas" / "5.000 curtidas".
String _goalLabel(S s, LiveGoal g) =>
    g.isLikes ? s.goalLikesLabel(fmtGap(g.target)) : '${fmtGap(g.target)} ${g.giftName ?? ''}'.trim();

/// Ícone da meta: o próprio presente, ou coração (curtidas).
class _GoalIcon extends StatelessWidget {
  const _GoalIcon({required this.goal, this.size = 20});

  final LiveGoal goal;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (goal.isLikes) return Icon(LucideIcons.heart, size: size * 0.85, color: _pink);
    // Mesmo componente da sacola: imagem do app → do servidor → genérico.
    return GiftIcon(
      slug: goal.giftSlug ?? '',
      tier: goal.giftTier ?? 'basic',
      iconUrl: goal.giftIconUrl,
      size: size,
    );
  }
}

// ─── Botão de metas na tela da live (espectador e criador) ─────────────────

/// Pílula compacta abaixo do topo: [alvo] [ícone do presente] 7/10 (+1).
/// Some sem metas. Espectador: um toque abre a sacola já no presente da
/// meta (se só houver uma de presente) ou a lista de metas. Criador: abre
/// o editor. Ao bater uma meta, brilha e todos veem a linha no chat.
class LiveGoalsPill extends ConsumerStatefulWidget {
  const LiveGoalsPill({
    super.key,
    required this.roomId,
    required this.streamerId,
    this.initialGoals = const [],
    this.isCreator = false,
    this.onEdit,
  });

  final String roomId;
  final String streamerId;
  final List<LiveGoal> initialGoals;
  final bool isCreator;
  final VoidCallback? onEdit;

  @override
  ConsumerState<LiveGoalsPill> createState() => LiveGoalsPillState();
}

class LiveGoalsPillState extends ConsumerState<LiveGoalsPill> {
  List<LiveGoal> _goals = const [];
  StreamSubscription<LiveRoomEvent>? _sub;
  bool _glow = false;
  Timer? _glowTimer;

  @override
  void initState() {
    super.initState();
    _goals = widget.initialGoals;
    _sub = ref.read(liveRepositoryProvider).watchRoomEvents(widget.roomId).listen((e) {
      if (e.type == LiveRoomEvent.goalsUpdate) apply(LiveGoal.listFrom(e.data['goals']));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _glowTimer?.cancel();
    super.dispose();
  }

  /// Novo estado das metas (socket ou o criador acabou de salvar).
  void apply(List<LiveGoal> goals) {
    if (!mounted) return;
    final before = {for (final g in _goals) g.id: g.reached};
    final justReached = goals.where((g) => g.reached && before[g.id] == false).toList();
    setState(() => _goals = goals);
    if (justReached.isEmpty) return;
    HapticFeedback.mediumImpact();
    final s = S.of(context);
    for (final g in justReached) {
      ref
          .read(liveRoomCommentsViewModelProvider(widget.roomId).notifier)
          .addSystemMessage(s.goalReachedChat(_goalLabel(s, g)));
    }
    _glowTimer?.cancel();
    setState(() => _glow = true);
    _glowTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _glow = false);
    });
  }

  void _onTap() {
    if (widget.isCreator) {
      widget.onEdit?.call();
      return;
    }
    final open = _goals.where((g) => !g.reached).toList();
    final gifts = open.where((g) => g.isGift).toList();
    if (open.length == 1 && gifts.length == 1) {
      // Link direto: sacola já no presente da meta.
      GiftsOverlay.show(context, widget.roomId, widget.streamerId, preselectGiftSlug: gifts.first.giftSlug);
      return;
    }
    LiveGoalsSheet.show(context, roomId: widget.roomId, streamerId: widget.streamerId, goals: _goals);
  }

  @override
  Widget build(BuildContext context) {
    if (_goals.isEmpty) return const SizedBox.shrink();
    final featured = _goals.firstWhere((g) => !g.reached, orElse: () => _goals.last);
    final allDone = _goals.every((g) => g.reached);
    final accent = allDone || _glow ? _gold : (featured.isLikes ? _pink : _gold);
    final more = _goals.length - 1;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedScale(
        scale: _glow ? 1.06 : 1,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: _glow ? 0.95 : 0.45)),
            boxShadow: _glow ? [BoxShadow(color: _gold.withValues(alpha: 0.55), blurRadius: 14)] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(allDone ? LucideIcons.circleCheck : LucideIcons.target, size: 14, color: accent),
              const SizedBox(width: 6),
              _GoalIcon(goal: featured, size: 18),
              const SizedBox(width: 6),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${fmtGap(featured.progress)}/${fmtGap(featured.target)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      width: 54,
                      height: 3,
                      child: LinearProgressIndicator(
                        value: featured.ratio,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                  ),
                ],
              ),
              if (more > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '+$more',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gaveta do espectador: o que o criador precisa ─────────────────────────

class LiveGoalsSheet extends StatelessWidget {
  const LiveGoalsSheet._({required this.roomId, required this.streamerId, required this.goals});

  final String roomId;
  final String streamerId;
  final List<LiveGoal> goals;

  static Future<void> show(
    BuildContext context, {
    required String roomId,
    required String streamerId,
    required List<LiveGoal> goals,
  }) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    return showModalBottomSheet<void>(
      context: rootContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LiveGoalsSheet._(roomId: roomId, streamerId: streamerId, goals: goals),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    return _SheetFrame(
      title: s.goalsTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final g in goals)
            _GoalRow(
              goal: g,
              action: g.reached ? null : (g.isGift ? s.goalSendGift : s.goalLike),
              onAction: () {
                final root = Navigator.of(context, rootNavigator: true).context;
                Navigator.of(context).pop();
                if (g.isGift) {
                  GiftsOverlay.show(root, roomId, streamerId, preselectGiftSlug: g.giftSlug);
                }
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Text(s.goalsViewerHint, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal, this.action, this.onAction, this.onRemove});

  final LiveGoal goal;
  final String? action;
  final VoidCallback? onAction;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final accent = goal.isLikes ? _pink : _gold;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colors.surfaceHighest, borderRadius: BorderRadius.circular(12)),
            child: _GoalIcon(goal: goal, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _goalLabel(s, goal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (goal.reached) ...[
                      const SizedBox(width: 6),
                      const Icon(LucideIcons.circleCheck, size: 15, color: _gold),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: goal.ratio,
                    minHeight: 5,
                    backgroundColor: colors.surfaceHighest,
                    valueColor: AlwaysStoppedAnimation(goal.reached ? _gold : accent),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goal.reached ? s.goalReached : s.goalProgress(fmtGap(goal.progress), fmtGap(goal.target)),
                  style: TextStyle(color: colors.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
            ),
          ],
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: Icon(LucideIcons.x, size: 18, color: colors.textSecondary),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.86),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2)),
              ),
              SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                    Positioned(
                      right: 4,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                        iconSize: 22,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Editor do criador ─────────────────────────────────────────────────────

/// O criador monta até 3 metas: escolhe o presente e a quantidade (ou uma
/// meta de curtidas) com toques, sem digitar — o celular está no tripé.
class LiveGoalsEditorSheet extends ConsumerStatefulWidget {
  const LiveGoalsEditorSheet._({required this.roomId, required this.current});

  final String roomId;
  final List<LiveGoal> current;

  /// Devolve as metas salvas (ou null se fechou sem salvar).
  static Future<List<LiveGoal>?> show(BuildContext context, {required String roomId, required List<LiveGoal> current}) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    return showModalBottomSheet<List<LiveGoal>>(
      context: rootContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LiveGoalsEditorSheet._(roomId: roomId, current: current),
    );
  }

  @override
  ConsumerState<LiveGoalsEditorSheet> createState() => _LiveGoalsEditorSheetState();
}

class _Draft {
  _Draft({required this.type, required this.target, this.gift, this.existing});

  final String type;
  final int target;
  final Gift? gift;
  final LiveGoal? existing; // meta já no ar (mantém o progresso visível)

  LiveGoal get preview =>
      existing ??
      LiveGoal(
        id: 'draft',
        type: type,
        target: target,
        giftSlug: gift?.slug,
        giftName: gift?.name,
        giftIconUrl: gift?.iconUrl,
        giftTier: gift?.tier,
      );

  LiveGoalDraft get request => type == LiveGoal.typeLikes
      ? LiveGoalDraft.likes(target: target, id: existing?.id)
      : LiveGoalDraft.gift(slug: gift?.slug ?? existing!.giftSlug!, target: target, id: existing?.id);
}

class _LiveGoalsEditorSheetState extends ConsumerState<LiveGoalsEditorSheet> {
  static const _max = 3;
  static const _giftAmounts = [1, 5, 10, 20, 50, 100];
  static const _likeAmounts = [1000, 5000, 10000, 50000];

  late final List<_Draft> _drafts = [
    for (final g in widget.current) _Draft(type: g.type, target: g.target, existing: g),
  ];
  bool _likesMode = false;
  int _category = 0;

  @override
  void initState() {
    super.initState();
    // Catálogo atualizado ao abrir: presente/categoria recém-criado no
    // painel já aparece aqui.
    Future.microtask(() => ref.read(giftCatalogViewModelProvider.notifier).refresh());
  }
  Gift? _gift;
  int _amount = 10;
  bool _saving = false;
  bool _dirty = false;

  void _add() {
    if (_drafts.length >= _max) return;
    if (!_likesMode && _gift == null) return;
    setState(() {
      _drafts.add(
        _likesMode
            ? _Draft(type: LiveGoal.typeLikes, target: _amount)
            : _Draft(type: LiveGoal.typeGift, target: _amount, gift: _gift),
      );
      _dirty = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(liveRepositoryProvider)
          .setLiveGoals(widget.roomId, _drafts.map((d) => d.request).toList());
      if (mounted) Navigator.of(context).pop(saved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(S.of(context).goalsSaveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final full = _drafts.length >= _max;
    final amounts = _likesMode ? _likeAmounts : _giftAmounts;
    if (!amounts.contains(_amount)) _amount = amounts[_likesMode ? 1 : 2];

    return _SheetFrame(
      title: s.goalsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_drafts.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(s.goalsEmptyCreator, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
            ),
          for (var i = 0; i < _drafts.length; i++)
            _GoalRow(
              goal: _drafts[i].preview,
              onRemove: () => setState(() {
                _drafts.removeAt(i);
                _dirty = true;
              }),
            ),
          if (!full) ...[
            Divider(height: 20, color: colors.divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _ModeChip(
                    icon: LucideIcons.gift,
                    label: s.goalTypeGift,
                    selected: !_likesMode,
                    onTap: () => setState(() => _likesMode = false),
                  ),
                  const SizedBox(width: 8),
                  _ModeChip(
                    icon: LucideIcons.heart,
                    label: s.goalTypeLikes,
                    selected: _likesMode,
                    onTap: () => setState(() => _likesMode = true),
                  ),
                ],
              ),
            ),
            if (!_likesMode) _giftPicker(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in amounts)
                    _AmountChip(label: fmtGap(a), selected: _amount == a, onTap: () => setState(() => _amount = a)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: OutlinedButton.icon(
                onPressed: (!_likesMode && _gift == null) ? null : _add,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: Text(
                  _likesMode
                      ? s.goalAddLikes(fmtGap(_amount))
                      : (_gift == null ? s.goalPickGift : s.goalAddGift(fmtGap(_amount), _gift!.name)),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: FilledButton(
              onPressed: _saving || !_dirty ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accentPrimary,
                foregroundColor: colors.textOnAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_drafts.isEmpty ? s.goalsRemoveAll : s.goalsSave, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  /// Categorias do catálogo (as mesmas abas da sacola, inclusive as
  /// temáticas criadas no painel) e os presentes da categoria escolhida.
  Widget _giftPicker(BuildContext context) {
    final colors = context.colors;
    final catalog = ref.watch(giftCatalogViewModelProvider);
    final tiers = catalog.maybeWhen(
      data: (t) => t.where((x) => x.gifts.isNotEmpty).toList(),
      orElse: () => const <GiftTier>[],
    );
    if (tiers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final cat = _category.clamp(0, tiers.length - 1);
    final gifts = tiers[cat].gifts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            itemCount: tiers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final selected = i == cat;
              return GestureDetector(
                onTap: () => setState(() => _category = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? colors.textPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? colors.textPrimary : colors.border),
                  ),
                  child: Text(
                    GiftTierNames.label(context, tiers[i].name, tiers[i].names),
                    style: TextStyle(
                      color: selected ? colors.surfaceElevated : colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            itemCount: gifts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final g = gifts[i];
              final selected = _gift?.id == g.id;
              return GestureDetector(
                onTap: () => setState(() => _gift = g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 66,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: selected ? colors.accentPrimary.withValues(alpha: 0.14) : colors.surfaceHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? colors.accentPrimary : Colors.transparent, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: GiftIcon(slug: g.slug, tier: g.tier, iconUrl: g.iconUrl, size: 40),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        g.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.accentPrimary.withValues(alpha: 0.14) : colors.surfaceHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? colors.accentPrimary : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? colors.accentPrimary : colors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? colors.accentPrimary : colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.accentPrimary : colors.surfaceHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.textOnAccent : colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

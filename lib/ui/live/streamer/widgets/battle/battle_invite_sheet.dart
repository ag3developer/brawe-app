import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/themes/brawe_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/services/battle_service.dart';
import '../../../../../domain/models/battle_candidate.dart';
import '../../../../../domain/models/battle_config.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../live_feed/battle/battle_errors.dart';
import '../../../../core/themes/app_colors.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Bottom sheet to pick a live creator and invite them for a battle.
///
/// Lista vem de `GET /live/battle/candidates` — só criadores ao vivo que
/// podem batalhar AGORA (sem o próprio usuário, sem quem já está em
/// batalha/convite pendente, sem lives privadas). Quem você segue aparece
/// primeiro. Busca com debounce, paginação infinita e pull-to-refresh.
///
/// [onInvite] faz o request e devolve `null` em sucesso (o sheet fecha) ou
/// a mensagem de erro (o sheet continua aberto mostrando o motivo, para o
/// streamer escolher outra pessoa).
class BattleInviteSheet extends ConsumerStatefulWidget {
  const BattleInviteSheet({
    super.key,
    required this.myRoomId,
    required this.onInvite,
    this.loader,
    this.linkMode = false,
  });

  final String myRoomId;
  final Future<String?> Function(BattleCandidate candidate, int durationSeconds)
  onInvite;

  /// Fonte alternativa de candidatos (conexão: `/live/link/candidates`).
  final Future<(List<BattleCandidate>, String?)> Function(
    String query,
    String? cursor,
  )?
  loader;

  /// Convite de CONEXÃO (sem duração, textos de conexão).
  final bool linkMode;

  @override
  ConsumerState<BattleInviteSheet> createState() => _BattleInviteSheetState();
}

class _BattleInviteSheetState extends ConsumerState<BattleInviteSheet> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<BattleCandidate> _items = [];
  String? _nextCursor;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  /// Query efetivamente carregada — evita recarregar quando o listener do
  /// controller dispara por mudança de cursor/seleção (não de texto).
  String _query = '';

  /// Token da requisição atual: respostas de buscas antigas que chegam
  /// depois são descartadas (antes resultados velhos sobrescreviam novos).
  int _requestId = 0;

  BattleCandidate? _selected;
  int _durationSeconds = 300;
  bool _sending = false;
  String? _inviteError;

  /// Durações permitidas (do servidor; se falhar, as de sempre).
  BattleConfig _config = BattleConfig.fallback;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _load(reset: true);
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final raw = await ref.read(battleServiceProvider).getBattleConfig();
      final cfg = BattleConfig.tryParse(raw);
      if (!mounted || cfg == null) return;
      setState(() {
        _config = cfg;
        _durationSeconds = cfg.defaultDurationS;
      });
    } catch (_) {
      // Sem configuração: mantém as opções e o padrão atuais.
    }
  }

  String _durationLabel(S s, int seconds) => seconds % 60 == 0
      ? s.battleDurationMinutes(seconds ~/ 60)
      : s.battleDurationSeconds(seconds);

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim();
    if (q == _query) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _query = q;
      _load(reset: true);
    });
  }

  Future<void> _load({required bool reset}) async {
    if (!reset && (_loadingMore || _nextCursor == null)) return;
    final requestId = ++_requestId;
    setState(() {
      if (reset) {
        _loading = true;
        _error = null;
      } else {
        _loadingMore = true;
      }
    });
    try {
      final cursor = reset ? null : _nextCursor;
      final (items, next) = widget.loader != null
          ? await widget.loader!(_query, cursor)
          : await ref
                .read(battleServiceProvider)
                .getCandidates(query: _query, cursor: cursor);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        final merged = reset ? items : [..._items, ...items];
        // Defesa extra: nunca listar a própria sala nem duplicados.
        final seen = <String>{};
        _items = merged
            .where((c) => c.roomId != widget.myRoomId && seen.add(c.roomId))
            .toList();
        _nextCursor = next;
        _loading = false;
        _loadingMore = false;
        // Selecionado saiu da lista (entrou em batalha, encerrou a live).
        if (_selected != null &&
            !_items.any((c) => c.roomId == _selected!.roomId)) {
          _selected = null;
        }
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (reset) {
          _error = battleErrorText(
            S.of(context),
            e,
            fallback: S.of(context).battleLoadCandidatesFailed,
          );
        }
      });
    }
  }

  Future<void> _invite() async {
    final target = _selected;
    if (target == null || _sending) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _sending = true;
      _inviteError = null;
    });
    final error = await widget.onInvite(target, _durationSeconds);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _sending = false;
      _inviteError = error;
    });
    // O motivo mais comum é o oponente ter ficado ocupado — atualiza a lista.
    unawaited(_load(reset: true));
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
      _load(reset: false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // ⌨️ O sheet sobe com o teclado da busca — o botão "Convidar" nunca
    // fica escondido.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollCtrl) {
          return Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSearchField(),
                const SizedBox(height: 12),
                if (!widget.linkMode) _buildDurationPicker(),
                const SizedBox(height: 4),
                Divider(color: context.colors.divider, height: 20),
                Expanded(child: _buildList(scrollCtrl)),
                _buildInviteButton(keyboardOpen: keyboard > 0),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.accentPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.swords,
              color: context.colors.accentPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.linkMode
                    ? S.of(context).linkStartTitle
                    : S.of(context).battleStartTitle,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                S.of(context).battleSheetSubtitle,
                style: TextStyle(
                  color: context.colors.textPrimary.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchCtrl,
        builder: (_, value, _) => TextField(
          controller: _searchCtrl,
          style: TextStyle(color: context.colors.textPrimary),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: S.of(context).battleSearchHint,
            hintStyle: TextStyle(
              color: context.colors.textPrimary.withValues(alpha: 0.35),
            ),
            prefixIcon: Icon(
              LucideIcons.search,
              color: context.colors.textSecondary,
            ),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      LucideIcons.x,
                      color: context.colors.textTertiary,
                      size: 18,
                    ),
                    onPressed: _searchCtrl.clear,
                  )
                : null,
            filled: true,
            fillColor: context.colors.textPrimary.withValues(alpha: 0.07),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colors.accentPrimary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              '${S.of(context).battleDurationLabel}:',
              style: TextStyle(
                color: context.colors.textPrimary.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 10),
            ...[
              for (final d in _config.durationsS)
                (_durationLabel(S.of(context), d), d),
            ].map((opt) {
              final selected = _durationSeconds == opt.$2;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _durationSeconds = opt.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? context.colors.accentPrimary.withValues(alpha: 0.25)
                          : context.colors.textPrimary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? context.colors.accentPrimary.withValues(
                                alpha: 0.7,
                              )
                            : context.colors.textPrimary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      opt.$1,
                      style: TextStyle(
                        color: selected
                            ? context.colors.accentPrimary
                            : context.colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ScrollController scrollCtrl) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.accentPrimary),
      );
    }
    if (_error != null) {
      return _CenteredMessage(
        icon: LucideIcons.wifiOff,
        message: _error!,
        actionLabel: S.of(context).battleRetry,
        onAction: () => _load(reset: true),
      );
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        color: context.colors.accentPrimary,
        onRefresh: () => _load(reset: true),
        // ListView para o pull-to-refresh funcionar com a lista vazia.
        child: ListView(
          controller: scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 40),
            _CenteredMessage(
              icon: LucideIcons.tv,
              message: _query.isNotEmpty
                  ? S.of(context).battleNoCreatorQuery(_query)
                  : S.of(context).battleNoCreator,
            ),
          ],
        ),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: RefreshIndicator(
        color: context.colors.accentPrimary,
        onRefresh: () => _load(reset: true),
        child: ListView.builder(
          controller: scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemCount: _items.length + (_loadingMore ? 1 : 0),
          itemBuilder: (_, i) {
            if (i >= _items.length) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.accentPrimary,
                    ),
                  ),
                ),
              );
            }
            final c = _items[i];
            final isSelected = _selected?.roomId == c.roomId;
            return _CandidateTile(
              candidate: c,
              selected: isSelected,
              onTap: _sending
                  ? null
                  : () => setState(() {
                      _selected = isSelected ? null : c;
                      _inviteError = null;
                    }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInviteButton({required bool keyboardOpen}) {
    final enabled = _selected != null && !_sending;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        (keyboardOpen ? 0 : MediaQuery.paddingOf(context).bottom) + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_inviteError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    color: context.colors.danger,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _inviteError!,
                      style: TextStyle(
                        color: context.colors.danger,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: enabled
                    ? LinearGradient(
                        colors: [
                          context.colors.accentPrimary,
                          context.colors.accentSecondary,
                        ],
                      )
                    : null,
                color: enabled
                    ? null
                    : context.colors.textPrimary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: enabled ? _invite : null,
                  child: Center(
                    child: _sending
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: context.colors.textPrimary,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.send,
                                color: enabled
                                    ? context.colors.textPrimary
                                    : context.colors.textTertiary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _selected != null
                                      ? (widget.linkMode
                                            ? S
                                                  .of(context)
                                                  .linkInviteCreator(
                                                    _selected!.displayName,
                                                  )
                                            : S
                                                  .of(context)
                                                  .battleInviteCreator(
                                                    _selected!.displayName,
                                                  ))
                                      : S.of(context).battleSelectCreator,
                                  style: TextStyle(
                                    color: enabled
                                        ? context.colors.textPrimary
                                        : context.colors.textTertiary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.candidate,
    required this.selected,
    required this.onTap,
  });

  final BattleCandidate candidate;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = candidate;
    final avatar = c.avatarUrl;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? context.colors.accentPrimary.withValues(alpha: 0.15)
              : context.colors.textPrimary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? context.colors.accentPrimary.withValues(alpha: 0.5)
                : context.colors.textPrimary.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: context.colors.accentPrimary.withValues(
                    alpha: 0.3,
                  ),
                  backgroundImage: avatar != null
                      ? ResizeImage(
                          NetworkImage(avatar),
                          width: context.decodePx(48),
                        )
                      : null,
                  child: avatar == null
                      ? Text(
                          c.displayName.replaceFirst('@', '').isNotEmpty
                              ? c.displayName
                                    .replaceFirst('@', '')[0]
                                    .toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.liveRed,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: context.colors.surface,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        S.of(context).battleLiveBadge,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                          c.displayName,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (c.isFollowing) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            S.of(context).battleFollowing,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (c.title.isNotEmpty)
                    Text(
                      c.title,
                      style: TextStyle(
                        color: context.colors.textPrimary.withValues(
                          alpha: 0.45,
                        ),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.eye,
                      color: context.colors.textTertiary,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${c.viewerCount}',
                      style: TextStyle(
                        color: context.colors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (selected)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      LucideIcons.circleCheck,
                      color: context.colors.accentPrimary,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: context.colors.border, size: 40),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 13,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: TextStyle(color: context.colors.accentPrimary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

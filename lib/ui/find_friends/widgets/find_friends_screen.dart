import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/social_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';

/// Provider com a lista completa de sugestões (usada na tela Encontrar amigos
/// e aberta pelo "Ver todos" do feed). Mais itens que o carrossel do feed.
final allSuggestionsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      return ref.watch(socialServiceProvider).getSuggestions(limit: 50);
    });

/// Página "Encontrar amigos" — estilo TikTok/Instagram: campo de busca por
/// nome/@usuário em destaque no topo, atalhos compactos para o QR do próprio
/// perfil e para escanear o código de outra pessoa, e a lista de sugestões.
///
/// Acessada a partir do ícone (usuário+) no perfil e pelo "Ver todos" do
/// carrossel de sugestões no feed.
class FindFriendsScreen extends ConsumerStatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  ConsumerState<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends ConsumerState<FindFriendsScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _searching = false;
  bool _error = false;
  List<Map<String, dynamic>> _results = const [];
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final q = value.trim().replaceFirst(RegExp(r'^@+'), '');
    if (q.isEmpty) {
      _requestId++;
      setState(() {
        _query = '';
        _searching = false;
        _error = false;
        _results = const [];
      });
      return;
    }
    setState(() {
      _query = q;
      _searching = true;
      _error = false;
    });
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  Future<void> _search() async {
    final q = _query;
    if (q.isEmpty) return;
    final id = ++_requestId;
    setState(() {
      _searching = true;
      _error = false;
    });
    try {
      final res = await ref.read(socialServiceProvider).searchUsers(q);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = res;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = true;
        _searching = false;
      });
    }
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  void _showMyQr(String profileUrl, String? avatarUrl, String? name) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: _MyQrCard(
              profileUrl: profileUrl,
              avatarUrl: avatarUrl,
              name: name,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final currentUser = ref.watch(authStateProvider).value;
    final profileUrl = currentUser != null
        ? AppConstants.profileUrl(currentUser.id)
        : null;
    final searching = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.findFriendsTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _SearchField(
              controller: _controller,
              onChanged: _onChanged,
              onClear: _clear,
            ),
            const SizedBox(height: 14),
            if (!searching) ...[
              Row(
                children: [
                  if (profileUrl != null) ...[
                    Expanded(
                      child: _ShortcutButton(
                        icon: LucideIcons.qrCode,
                        label: s.findFriendsMyQrCode,
                        onTap: () => _showMyQr(
                          profileUrl,
                          currentUser?.avatarUrl,
                          currentUser?.name,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: _ShortcutButton(
                      icon: LucideIcons.scanLine,
                      label: s.findFriendsScanButton,
                      onTap: () => context.push('/scan-qr'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                s.findFriendsSuggestionsTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const _SuggestionsList(),
            ] else
              _buildResults(s, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(S s, BraweColors colors) {
    if (_searching && _results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error) {
      return _MessageState(
        icon: LucideIcons.wifiOff,
        text: s.findFriendsSearchError,
        actionLabel: s.findFriendsRetry,
        onAction: _search,
      );
    }
    if (_results.isEmpty) {
      return _MessageState(
        icon: LucideIcons.searchX,
        text: s.findFriendsSearchNoResults(_query),
      );
    }
    return Opacity(
      opacity: _searching ? 0.6 : 1,
      child: Column(
        children: _results
            .map(
              (u) => _UserTile(
                key: ValueKey(u['user_id']),
                user: u,
                initialFollowing: u['is_following'] as bool? ?? false,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

/// Campo de busca arredondado, com ícone de lupa e botão de limpar.
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      style: TextStyle(color: colors.textPrimary, fontSize: 15),
      cursorColor: colors.accentPrimary,
      decoration: InputDecoration(
        hintText: S.of(context).findFriendsSearchHint,
        hintStyle: TextStyle(color: colors.textSecondary, fontSize: 15),
        prefixIcon: Icon(
          LucideIcons.search,
          size: 18,
          color: colors.textSecondary,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, v, __) => v.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(
                    Icons.cancel,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  onPressed: onClear,
                ),
        ),
        filled: true,
        fillColor: colors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.accentPrimary, width: 1.2),
        ),
      ),
    );
  }
}

/// Estado vazio/erro com ícone, texto e ação opcional.
class _MessageState extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 36, color: colors.textSecondary),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Botão compacto de atalho (Meu QR / Escanear).
class _ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: colors.accentPrimary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
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

/// Card com o QR code do próprio perfil + botão de compartilhar.
class _MyQrCard extends StatelessWidget {
  final String profileUrl;
  final String? avatarUrl;
  final String? name;

  const _MyQrCard({required this.profileUrl, this.avatarUrl, this.name});

  Future<void> _share(BuildContext context) async {
    HapticFeedback.lightImpact();
    try {
      // ignore: deprecated_member_use
      await Share.share(profileUrl, subject: name);
    } catch (_) {
      // Falha silenciosa — não é uma ação crítica.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Text(
            s.findFriendsMyQrCode,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                QrImageView(
                  data: profileUrl,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.circle,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: Colors.black,
                  ),
                ),
                // Avatar central sobre o QR, como no TikTok — o nível de
                // correção de erro padrão do QR (M) tolera esse overlay.
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                        memCacheWidth: context.decodePx(44),
                          imageUrl: avatarUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.person, color: Colors.black26),
                        )
                      : const Icon(Icons.person, color: Colors.black26),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            s.findFriendsQrHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _share(context),
              icon: Icon(
                LucideIcons.send,
                size: 16,
                color: colors.textPrimary,
              ),
              label: Text(
                S.of(context).actionShare,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.border),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de sugestões de amigos — reaproveita o mesmo provider/serviço
/// (`suggestedUsersProvider`/`getSuggestions`) usado no feed, mas em
/// layout de lista vertical (em vez do carrossel horizontal) e sem o
/// "story ring", já que aqui o contexto é puramente "seguir pessoas".
class _SuggestionsList extends ConsumerWidget {
  const _SuggestionsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allSuggestionsProvider);
    final colors = context.colors;
    final s = S.of(context);

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _MessageState(
        icon: LucideIcons.wifiOff,
        text: s.findFriendsSuggestionsError,
        actionLabel: s.findFriendsRetry,
        onAction: () => ref.invalidate(allSuggestionsProvider),
      ),
      data: (users) {
        if (users.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                s.findFriendsSuggestionsEmpty,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
          );
        }
        return Column(
          children: users
              .map((u) => _UserTile(key: ValueKey(u['user_id']), user: u))
              .toList(growable: false),
        );
      },
    );
  }
}

/// Linha de usuário (sugestão ou resultado de busca) com botão Seguir.
class _UserTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> user;
  final bool initialFollowing;
  const _UserTile({super.key, required this.user, this.initialFollowing = false});

  @override
  ConsumerState<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends ConsumerState<_UserTile> {
  late bool _following = widget.initialFollowing;
  bool _loading = false;

  Future<void> _toggleFollow(String userId) async {
    setState(() => _loading = true);
    try {
      if (_following) {
        await ref.read(socialServiceProvider).unfollowUser(userId);
      } else {
        await ref.read(socialServiceProvider).followUser(userId);
      }
      if (mounted) setState(() => _following = !_following);
    } catch (_) {
      // Falha silenciosa — otimista, sem bloquear a UI.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final user = widget.user;
    final userId = user['user_id'] as String? ?? '';
    final name = (user['display_name'] as String?)?.trim().isNotEmpty == true
        ? user['display_name'] as String
        : user['username'] as String? ?? 'User';
    final username = user['username'] as String?;
    final avatarUrl = user['avatar_url'] as String?;
    final isVerified = user['is_verified'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => context.push('/profile/$userId'),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.surfaceHighest,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(avatarUrl, maxWidth: context.decodePx(48))
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? Icon(Icons.person, color: colors.textSecondary)
                  : null,
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
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isVerified) const VerifiedBadge(size: 14, gap: 4),
                    ],
                  ),
                  if (username != null && username.isNotEmpty)
                    Text(
                      '@$username',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 32,
              child: OutlinedButton(
                onPressed: _loading ? null : () => _toggleFollow(userId),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _following
                      ? colors.surfaceHighest
                      : colors.accentPrimary,
                  side: BorderSide(
                    color: _following ? colors.border : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _loading
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _following ? colors.textPrimary : Colors.white,
                        ),
                      )
                    : Text(
                        _following
                            ? s.findFriendsFollowingButton
                            : s.findFriendsFollowButton,
                        style: TextStyle(
                          color: _following ? colors.textPrimary : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
import '../../feed/widgets/suggested_users_rail.dart';

/// Página "Encontrar amigos" — estilo TikTok: mostra o QR code do próprio
/// perfil (para outras pessoas escanearem e seguir/ver o perfil), um botão
/// para escanear o código de outra pessoa (ou um QR de login de outro
/// dispositivo), e uma lista de sugestões de pessoas para seguir.
///
/// Acessada a partir do ícone (usuário+) que substituiu o "@username" no
/// AppBar do próprio perfil (ver `profile_screen.dart`).
class FindFriendsScreen extends ConsumerWidget {
  const FindFriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final colors = context.colors;
    final currentUser = ref.watch(authStateProvider).value;
    final profileUrl = currentUser != null
        ? AppConstants.profileUrl(currentUser.id)
        : null;

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (profileUrl != null)
            _MyQrCard(
              profileUrl: profileUrl,
              avatarUrl: currentUser?.avatarUrl,
              name: currentUser?.name,
            ),
          const SizedBox(height: 14),
          _ScanButton(onTap: () => context.push('/scan-qr')),
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
        ],
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
                LucideIcons.share2,
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

/// Botão minimalista "Escanear código" — abre a câmera para ler o QR de
/// outra pessoa (perfil) ou um QR de login exibido em outro dispositivo.
class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.accentPrimary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.scanLine,
                  size: 18,
                  color: colors.accentPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  S.of(context).findFriendsScanButton,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textSecondary, size: 20),
            ],
          ),
        ),
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
    final async = ref.watch(suggestedUsersProvider);
    final colors = context.colors;
    final s = S.of(context);

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
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
              .map((u) => _SuggestionTile(user: u))
              .toList(growable: false),
        );
      },
    );
  }
}

class _SuggestionTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> user;
  const _SuggestionTile({required this.user});

  @override
  ConsumerState<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends ConsumerState<_SuggestionTile> {
  bool _following = false;
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
                  ? CachedNetworkImageProvider(avatarUrl)
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
                      if (isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: colors.accentPrimary,
                        ),
                      ],
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

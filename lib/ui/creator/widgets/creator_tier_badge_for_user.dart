import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/creator_network_repository.dart';
import '../../../domain/models/creator_network.dart';
import 'creator_tier_badge.dart';

part 'creator_tier_badge_for_user.g.dart';

/// Cache simples: userId → CreatorProfile? (in-memory por sessão).
///
/// O backend ainda não expõe `GET /creator/{user_id}` público, então por
/// enquanto este provider só sabe responder pelo **próprio usuário logado**
/// via `getMyCreator()`. Quando o endpoint público for adicionado, basta
/// trocar a implementação aqui — todas as integrações se beneficiam.
@riverpod
Future<CreatorProfile?> creatorProfileForUser(Ref ref, String userId) async {
  final repo = ref.watch(creatorNetworkRepositoryProvider);
  final mine = await repo.getMyCreator();
  if (mine != null && mine.userId == userId) return mine;
  return null;
}

/// Widget plug-and-play: dado um `userId`, exibe o badge do tier se ele for
/// creator aprovado. Caso contrário, ocupa zero espaço.
///
/// Use em qualquer lista/avatar/header onde queira reconhecer creators.
class CreatorTierBadgeForUser extends ConsumerWidget {
  const CreatorTierBadgeForUser({
    super.key,
    required this.userId,
    this.size = 16,
    this.showLabel = false,
  });

  final String userId;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(creatorProfileForUserProvider(userId));
    final profile = async.asData?.value;
    if (profile == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: CreatorTierBadge(
        tier: profile.tier,
        size: size,
        showLabel: showLabel,
      ),
    );
  }
}

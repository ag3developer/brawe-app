// Dados da conta logada usados na inscrição da Creator Network.
// A pessoa já está logada: nome, @, e-mail e foto vêm da conta e nunca são
// pedidos de novo no formulário.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/profile_repository.dart';

class CreatorApplicant {
  final String name;
  final String? username;
  final String? avatarUrl;
  final String email;
  const CreatorApplicant({
    required this.name,
    this.username,
    this.avatarUrl,
    this.email = '',
  });
}

final creatorApplicantProvider =
    FutureProvider.autoDispose<CreatorApplicant>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  var name = (user?.name ?? '').trim();
  String? username;
  String? avatar = user?.avatarUrl;
  try {
    final p = await ref.read(profileRepositoryProvider).getMyProfile();
    username = p.username;
    if ((p.displayName ?? '').trim().isNotEmpty) name = p.displayName!.trim();
    avatar ??= p.avatarUrl;
  } catch (_) {
    // Sem perfil carregado: o servidor completa os dados pela conta.
  }
  return CreatorApplicant(
    name: name,
    username: username,
    avatarUrl: avatar,
    email: user?.email ?? '',
  );
});

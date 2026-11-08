import 'package:flutter/foundation.dart';

/// O que ainda falta no perfil para a pessoa usar o app.
@immutable
class OnboardingNeeds {
  const OnboardingNeeds({
    required this.birthDate,
    required this.username,
    required this.avatar,
    required this.bio,
    required this.followingCount,
    this.interests = false,
    this.gender = false,
    this.location = false,
  });

  /// Sem gênero (feminino, masculino, outro ou "prefiro não dizer").
  final bool gender;

  /// Sem país ou cidade.
  final bool location;

  final bool birthDate;
  final bool username;
  final bool avatar;

  /// Bio vazia — passo opcional, só oferecido junto do cadastro inicial.
  final bool bio;
  final int followingCount;

  /// Sem interesses escolhidos (mínimo 3) — obrigatório para todos (alimenta o feed e os anúncios).
  final bool interests;

  /// Falta algo obrigatório → o app leva para /onboarding.
  bool get blocking =>
      birthDate || username || avatar || gender || location || interests;

  /// Conta nova (sem foto) também recebe os passos opcionais (bio e seguir).
  bool get isNewAccount => avatar;

  factory OnboardingNeeds.fromProfile(Map<String, dynamic> p) {
    String s(String k) => (p[k]?.toString() ?? '').trim();
    final username = s('username');
    return OnboardingNeeds(
      birthDate: s('birth_date').isEmpty,
      username: username.length < 2,
      avatar: s('avatar_url').isEmpty,
      bio: s('bio').isEmpty,
      followingCount: (p['following_count'] as num?)?.toInt() ?? 0,
      interests: ((p['interests'] as List?)?.length ?? 0) < 3,
      gender: s('gender').isEmpty,
      location: s('country').isEmpty || s('city').isEmpty,
    );
  }
}

/// Estado global do onboarding, lido pelo redirect do router (que é
/// síncrono). Carrega o perfil uma vez por usuário e avisa o router quando
/// muda — mesmo padrão de `AccountSuspension`.
class OnboardingGate extends ValueNotifier<OnboardingNeeds?> {
  OnboardingGate._() : super(null);
  static final OnboardingGate instance = OnboardingGate._();

  String? _userId;
  bool _loading = false;

  /// Garante que o estado do usuário [userId] foi (ou está sendo) carregado.
  void ensureFor(
    String userId,
    Future<Map<String, dynamic>> Function() loadProfile,
  ) {
    if (_userId == userId && (value != null || _loading)) return;
    if (_userId != userId) value = null;
    _userId = userId;
    _loading = true;
    loadProfile()
        .then((p) {
          if (_userId != userId) return;
          value = OnboardingNeeds.fromProfile(p);
        })
        .catchError((Object e) {
          // Sem perfil (offline/erro): não trava o app — só a regra do avatar
          // (que vem da sessão) continua valendo.
          debugPrint('[ONBOARDING] perfil indisponível: $e');
        })
        .whenComplete(() => _loading = false);
  }

  /// Onboarding concluído: libera o app sem esperar recarregar o perfil.
  void markDone() {
    final v = value;
    value = OnboardingNeeds(
      birthDate: false,
      username: false,
      avatar: false,
      bio: v?.bio ?? false,
      followingCount: v?.followingCount ?? 0,
    );
  }

  /// Logout / troca de conta.
  void reset() {
    _userId = null;
    _loading = false;
    value = null;
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_tier_badge_for_user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cache simples: userId → CreatorProfile? (in-memory por sessão).
///
/// O backend ainda não expõe `GET /creator/{user_id}` público, então por
/// enquanto este provider só sabe responder pelo **próprio usuário logado**
/// via `getMyCreator()`. Quando o endpoint público for adicionado, basta
/// trocar a implementação aqui — todas as integrações se beneficiam.

@ProviderFor(creatorProfileForUser)
final creatorProfileForUserProvider = CreatorProfileForUserFamily._();

/// Cache simples: userId → CreatorProfile? (in-memory por sessão).
///
/// O backend ainda não expõe `GET /creator/{user_id}` público, então por
/// enquanto este provider só sabe responder pelo **próprio usuário logado**
/// via `getMyCreator()`. Quando o endpoint público for adicionado, basta
/// trocar a implementação aqui — todas as integrações se beneficiam.

final class CreatorProfileForUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreatorProfile?>,
          CreatorProfile?,
          FutureOr<CreatorProfile?>
        >
    with $FutureModifier<CreatorProfile?>, $FutureProvider<CreatorProfile?> {
  /// Cache simples: userId → CreatorProfile? (in-memory por sessão).
  ///
  /// O backend ainda não expõe `GET /creator/{user_id}` público, então por
  /// enquanto este provider só sabe responder pelo **próprio usuário logado**
  /// via `getMyCreator()`. Quando o endpoint público for adicionado, basta
  /// trocar a implementação aqui — todas as integrações se beneficiam.
  CreatorProfileForUserProvider._({
    required CreatorProfileForUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'creatorProfileForUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creatorProfileForUserHash();

  @override
  String toString() {
    return r'creatorProfileForUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CreatorProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreatorProfile?> create(Ref ref) {
    final argument = this.argument as String;
    return creatorProfileForUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreatorProfileForUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creatorProfileForUserHash() =>
    r'af3bcd1d4ee6abf45554521ab09ccb54639da922';

/// Cache simples: userId → CreatorProfile? (in-memory por sessão).
///
/// O backend ainda não expõe `GET /creator/{user_id}` público, então por
/// enquanto este provider só sabe responder pelo **próprio usuário logado**
/// via `getMyCreator()`. Quando o endpoint público for adicionado, basta
/// trocar a implementação aqui — todas as integrações se beneficiam.

final class CreatorProfileForUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CreatorProfile?>, String> {
  CreatorProfileForUserFamily._()
    : super(
        retry: null,
        name: r'creatorProfileForUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cache simples: userId → CreatorProfile? (in-memory por sessão).
  ///
  /// O backend ainda não expõe `GET /creator/{user_id}` público, então por
  /// enquanto este provider só sabe responder pelo **próprio usuário logado**
  /// via `getMyCreator()`. Quando o endpoint público for adicionado, basta
  /// trocar a implementação aqui — todas as integrações se beneficiam.

  CreatorProfileForUserProvider call(String userId) =>
      CreatorProfileForUserProvider._(argument: userId, from: this);

  @override
  String toString() => r'creatorProfileForUserProvider';
}

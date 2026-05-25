// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifter_level_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 🎖️ ViewModel do nível do gifter (espectador) logado.
///
/// Consome `GET /live/gifts/me/level` do brawe-connect. Usado no header
/// da sacola de presentes e em futuros badges no chat.
///
/// O nível é atualizado pelo backend automaticamente quando o usuário:
/// - Envia gift (+50 XP)
/// - Entra em live (+10 XP)
/// - Manda mensagem no chat (+2 XP)
/// - Assiste live (+1 XP/min, cap 3h/sessão)
///
/// Após enviar um gift, chame `refresh()` para atualizar a UI.

@ProviderFor(GifterLevelViewModel)
final gifterLevelViewModelProvider = GifterLevelViewModelProvider._();

/// 🎖️ ViewModel do nível do gifter (espectador) logado.
///
/// Consome `GET /live/gifts/me/level` do brawe-connect. Usado no header
/// da sacola de presentes e em futuros badges no chat.
///
/// O nível é atualizado pelo backend automaticamente quando o usuário:
/// - Envia gift (+50 XP)
/// - Entra em live (+10 XP)
/// - Manda mensagem no chat (+2 XP)
/// - Assiste live (+1 XP/min, cap 3h/sessão)
///
/// Após enviar um gift, chame `refresh()` para atualizar a UI.
final class GifterLevelViewModelProvider
    extends $AsyncNotifierProvider<GifterLevelViewModel, GifterLevel> {
  /// 🎖️ ViewModel do nível do gifter (espectador) logado.
  ///
  /// Consome `GET /live/gifts/me/level` do brawe-connect. Usado no header
  /// da sacola de presentes e em futuros badges no chat.
  ///
  /// O nível é atualizado pelo backend automaticamente quando o usuário:
  /// - Envia gift (+50 XP)
  /// - Entra em live (+10 XP)
  /// - Manda mensagem no chat (+2 XP)
  /// - Assiste live (+1 XP/min, cap 3h/sessão)
  ///
  /// Após enviar um gift, chame `refresh()` para atualizar a UI.
  GifterLevelViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gifterLevelViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gifterLevelViewModelHash();

  @$internal
  @override
  GifterLevelViewModel create() => GifterLevelViewModel();
}

String _$gifterLevelViewModelHash() =>
    r'23fe48b6b718d83e85d495cef2cf3d3e2befef24';

/// 🎖️ ViewModel do nível do gifter (espectador) logado.
///
/// Consome `GET /live/gifts/me/level` do brawe-connect. Usado no header
/// da sacola de presentes e em futuros badges no chat.
///
/// O nível é atualizado pelo backend automaticamente quando o usuário:
/// - Envia gift (+50 XP)
/// - Entra em live (+10 XP)
/// - Manda mensagem no chat (+2 XP)
/// - Assiste live (+1 XP/min, cap 3h/sessão)
///
/// Após enviar um gift, chame `refresh()` para atualizar a UI.

abstract class _$GifterLevelViewModel extends $AsyncNotifier<GifterLevel> {
  FutureOr<GifterLevel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GifterLevel>, GifterLevel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GifterLevel>, GifterLevel>,
              AsyncValue<GifterLevel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

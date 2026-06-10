// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_badge_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mantém o badge do ícone do app sincronizado com as fontes de "não lidos"
/// que **já existem** no projeto — sem criar contadores paralelos:
///
///  • [notificationsUnreadCountProvider] → notificações (likes, follows, …)
///  • [unreadCountProvider]              → mensagens diretas (DMs)
///
/// Sempre que qualquer um dos dois muda, o total é recalculado e empurrado para
/// o badge do SO via [AppBadgeService]. Como é `keepAlive`, basta instanciá-lo
/// uma vez no boot (ver `main.dart`) e ele permanece reativo durante todo o
/// ciclo de vida do app.
///
/// Segue o mesmo padrão de Notifier do [UnreadCount] (chat) para consistência.

@ProviderFor(AppBadgeController)
final appBadgeControllerProvider = AppBadgeControllerProvider._();

/// Mantém o badge do ícone do app sincronizado com as fontes de "não lidos"
/// que **já existem** no projeto — sem criar contadores paralelos:
///
///  • [notificationsUnreadCountProvider] → notificações (likes, follows, …)
///  • [unreadCountProvider]              → mensagens diretas (DMs)
///
/// Sempre que qualquer um dos dois muda, o total é recalculado e empurrado para
/// o badge do SO via [AppBadgeService]. Como é `keepAlive`, basta instanciá-lo
/// uma vez no boot (ver `main.dart`) e ele permanece reativo durante todo o
/// ciclo de vida do app.
///
/// Segue o mesmo padrão de Notifier do [UnreadCount] (chat) para consistência.
final class AppBadgeControllerProvider
    extends $NotifierProvider<AppBadgeController, int> {
  /// Mantém o badge do ícone do app sincronizado com as fontes de "não lidos"
  /// que **já existem** no projeto — sem criar contadores paralelos:
  ///
  ///  • [notificationsUnreadCountProvider] → notificações (likes, follows, …)
  ///  • [unreadCountProvider]              → mensagens diretas (DMs)
  ///
  /// Sempre que qualquer um dos dois muda, o total é recalculado e empurrado para
  /// o badge do SO via [AppBadgeService]. Como é `keepAlive`, basta instanciá-lo
  /// uma vez no boot (ver `main.dart`) e ele permanece reativo durante todo o
  /// ciclo de vida do app.
  ///
  /// Segue o mesmo padrão de Notifier do [UnreadCount] (chat) para consistência.
  AppBadgeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appBadgeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appBadgeControllerHash();

  @$internal
  @override
  AppBadgeController create() => AppBadgeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$appBadgeControllerHash() =>
    r'43befec3ac5da87456d7a8563ed131775e1a8ff2';

/// Mantém o badge do ícone do app sincronizado com as fontes de "não lidos"
/// que **já existem** no projeto — sem criar contadores paralelos:
///
///  • [notificationsUnreadCountProvider] → notificações (likes, follows, …)
///  • [unreadCountProvider]              → mensagens diretas (DMs)
///
/// Sempre que qualquer um dos dois muda, o total é recalculado e empurrado para
/// o badge do SO via [AppBadgeService]. Como é `keepAlive`, basta instanciá-lo
/// uma vez no boot (ver `main.dart`) e ele permanece reativo durante todo o
/// ciclo de vida do app.
///
/// Segue o mesmo padrão de Notifier do [UnreadCount] (chat) para consistência.

abstract class _$AppBadgeController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

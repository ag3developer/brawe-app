// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_room_gifts_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 🎁 ViewModel das animações de presente em tempo real.
///
/// Faz *combo* no estilo TikTok: presentes do mesmo `senderId+giftId`
/// recebidos numa janela de 4s viram um único item com `quantity` somado
/// (ex.: 10 rosas em rajada → "Jose Carlos enviou 🌹 x10").
///
/// O state é uma lista das últimas 6 entradas; cada uma fica visível por
/// ~5s após a última atualização — combos prorrogam o timer.

@ProviderFor(LiveRoomGiftsViewModel)
final liveRoomGiftsViewModelProvider = LiveRoomGiftsViewModelFamily._();

/// 🎁 ViewModel das animações de presente em tempo real.
///
/// Faz *combo* no estilo TikTok: presentes do mesmo `senderId+giftId`
/// recebidos numa janela de 4s viram um único item com `quantity` somado
/// (ex.: 10 rosas em rajada → "Jose Carlos enviou 🌹 x10").
///
/// O state é uma lista das últimas 6 entradas; cada uma fica visível por
/// ~5s após a última atualização — combos prorrogam o timer.
final class LiveRoomGiftsViewModelProvider
    extends $NotifierProvider<LiveRoomGiftsViewModel, List<LiveGift>> {
  /// 🎁 ViewModel das animações de presente em tempo real.
  ///
  /// Faz *combo* no estilo TikTok: presentes do mesmo `senderId+giftId`
  /// recebidos numa janela de 4s viram um único item com `quantity` somado
  /// (ex.: 10 rosas em rajada → "Jose Carlos enviou 🌹 x10").
  ///
  /// O state é uma lista das últimas 6 entradas; cada uma fica visível por
  /// ~5s após a última atualização — combos prorrogam o timer.
  LiveRoomGiftsViewModelProvider._({
    required LiveRoomGiftsViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveRoomGiftsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveRoomGiftsViewModelHash();

  @override
  String toString() {
    return r'liveRoomGiftsViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LiveRoomGiftsViewModel create() => LiveRoomGiftsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LiveGift> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LiveGift>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveRoomGiftsViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveRoomGiftsViewModelHash() =>
    r'eff035141e98b5366c64fda284fe564a9f1a078d';

/// 🎁 ViewModel das animações de presente em tempo real.
///
/// Faz *combo* no estilo TikTok: presentes do mesmo `senderId+giftId`
/// recebidos numa janela de 4s viram um único item com `quantity` somado
/// (ex.: 10 rosas em rajada → "Jose Carlos enviou 🌹 x10").
///
/// O state é uma lista das últimas 6 entradas; cada uma fica visível por
/// ~5s após a última atualização — combos prorrogam o timer.

final class LiveRoomGiftsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          LiveRoomGiftsViewModel,
          List<LiveGift>,
          List<LiveGift>,
          List<LiveGift>,
          String
        > {
  LiveRoomGiftsViewModelFamily._()
    : super(
        retry: null,
        name: r'liveRoomGiftsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 🎁 ViewModel das animações de presente em tempo real.
  ///
  /// Faz *combo* no estilo TikTok: presentes do mesmo `senderId+giftId`
  /// recebidos numa janela de 4s viram um único item com `quantity` somado
  /// (ex.: 10 rosas em rajada → "Jose Carlos enviou 🌹 x10").
  ///
  /// O state é uma lista das últimas 6 entradas; cada uma fica visível por
  /// ~5s após a última atualização — combos prorrogam o timer.

  LiveRoomGiftsViewModelProvider call(String roomId) =>
      LiveRoomGiftsViewModelProvider._(argument: roomId, from: this);

  @override
  String toString() => r'liveRoomGiftsViewModelProvider';
}

/// 🎁 ViewModel das animações de presente em tempo real.
///
/// Faz *combo* no estilo TikTok: presentes do mesmo `senderId+giftId`
/// recebidos numa janela de 4s viram um único item com `quantity` somado
/// (ex.: 10 rosas em rajada → "Jose Carlos enviou 🌹 x10").
///
/// O state é uma lista das últimas 6 entradas; cada uma fica visível por
/// ~5s após a última atualização — combos prorrogam o timer.

abstract class _$LiveRoomGiftsViewModel extends $Notifier<List<LiveGift>> {
  late final _$args = ref.$arg as String;
  String get roomId => _$args;

  List<LiveGift> build(String roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<LiveGift>, List<LiveGift>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<LiveGift>, List<LiveGift>>,
              List<LiveGift>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

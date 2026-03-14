// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_room_gifts_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LiveRoomGiftsViewModel)
final liveRoomGiftsViewModelProvider = LiveRoomGiftsViewModelFamily._();

final class LiveRoomGiftsViewModelProvider
    extends $NotifierProvider<LiveRoomGiftsViewModel, List<LiveGift>> {
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
    r'9708fc9f49d50f466ea19c6222f80425dd4d7e63';

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

  LiveRoomGiftsViewModelProvider call(String roomId) =>
      LiveRoomGiftsViewModelProvider._(argument: roomId, from: this);

  @override
  String toString() => r'liveRoomGiftsViewModelProvider';
}

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

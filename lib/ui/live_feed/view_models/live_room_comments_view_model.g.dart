// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_room_comments_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LiveRoomCommentsViewModel)
final liveRoomCommentsViewModelProvider = LiveRoomCommentsViewModelFamily._();

final class LiveRoomCommentsViewModelProvider
    extends
        $NotifierProvider<LiveRoomCommentsViewModel, LiveRoomCommentsState> {
  LiveRoomCommentsViewModelProvider._({
    required LiveRoomCommentsViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveRoomCommentsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveRoomCommentsViewModelHash();

  @override
  String toString() {
    return r'liveRoomCommentsViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LiveRoomCommentsViewModel create() => LiveRoomCommentsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveRoomCommentsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveRoomCommentsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveRoomCommentsViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveRoomCommentsViewModelHash() =>
    r'5eb7fca1443869f43d7735541df3c9dde062c808';

final class LiveRoomCommentsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          LiveRoomCommentsViewModel,
          LiveRoomCommentsState,
          LiveRoomCommentsState,
          LiveRoomCommentsState,
          String
        > {
  LiveRoomCommentsViewModelFamily._()
    : super(
        retry: null,
        name: r'liveRoomCommentsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LiveRoomCommentsViewModelProvider call(String roomId) =>
      LiveRoomCommentsViewModelProvider._(argument: roomId, from: this);

  @override
  String toString() => r'liveRoomCommentsViewModelProvider';
}

abstract class _$LiveRoomCommentsViewModel
    extends $Notifier<LiveRoomCommentsState> {
  late final _$args = ref.$arg as String;
  String get roomId => _$args;

  LiveRoomCommentsState build(String roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LiveRoomCommentsState, LiveRoomCommentsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveRoomCommentsState, LiveRoomCommentsState>,
              LiveRoomCommentsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

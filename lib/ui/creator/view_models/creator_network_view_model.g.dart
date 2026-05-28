// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_network_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(networkOverview)
final networkOverviewProvider = NetworkOverviewProvider._();

final class NetworkOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetworkOverview>,
          NetworkOverview,
          FutureOr<NetworkOverview>
        >
    with $FutureModifier<NetworkOverview>, $FutureProvider<NetworkOverview> {
  NetworkOverviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkOverviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkOverviewHash();

  @$internal
  @override
  $FutureProviderElement<NetworkOverview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NetworkOverview> create(Ref ref) {
    return networkOverview(ref);
  }
}

String _$networkOverviewHash() => r'5bce0e6045f4b7560c40eb4d7e666143b3299616';

@ProviderFor(myCreatorApplication)
final myCreatorApplicationProvider = MyCreatorApplicationProvider._();

final class MyCreatorApplicationProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreatorApplication?>,
          CreatorApplication?,
          FutureOr<CreatorApplication?>
        >
    with
        $FutureModifier<CreatorApplication?>,
        $FutureProvider<CreatorApplication?> {
  MyCreatorApplicationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCreatorApplicationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCreatorApplicationHash();

  @$internal
  @override
  $FutureProviderElement<CreatorApplication?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreatorApplication?> create(Ref ref) {
    return myCreatorApplication(ref);
  }
}

String _$myCreatorApplicationHash() =>
    r'056b20fe23035ff6af69a7ac48d95131addd7697';

@ProviderFor(myCreatorProfile)
final myCreatorProfileProvider = MyCreatorProfileProvider._();

final class MyCreatorProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreatorProfile?>,
          CreatorProfile?,
          FutureOr<CreatorProfile?>
        >
    with $FutureModifier<CreatorProfile?>, $FutureProvider<CreatorProfile?> {
  MyCreatorProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCreatorProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCreatorProfileHash();

  @$internal
  @override
  $FutureProviderElement<CreatorProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreatorProfile?> create(Ref ref) {
    return myCreatorProfile(ref);
  }
}

String _$myCreatorProfileHash() => r'40bcf160071de4c95070857c7e2bcc5061c87f25';

@ProviderFor(creatorOnboarding)
final creatorOnboardingProvider = CreatorOnboardingProvider._();

final class CreatorOnboardingProvider
    extends
        $FunctionalProvider<
          AsyncValue<OnboardingChecklist>,
          OnboardingChecklist,
          FutureOr<OnboardingChecklist>
        >
    with
        $FutureModifier<OnboardingChecklist>,
        $FutureProvider<OnboardingChecklist> {
  CreatorOnboardingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorOnboardingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorOnboardingHash();

  @$internal
  @override
  $FutureProviderElement<OnboardingChecklist> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OnboardingChecklist> create(Ref ref) {
    return creatorOnboarding(ref);
  }
}

String _$creatorOnboardingHash() => r'84c1b32be1c42ee7eb2622df67bf8fdc8201e630';

/// Versão vigente dos Termos do Brawe Creator Network (ex.: "2026-05-01").
/// Cacheada por sessão; usada pelo form para enviar `terms_version` no submit.

@ProviderFor(creatorTermsVersion)
final creatorTermsVersionProvider = CreatorTermsVersionProvider._();

/// Versão vigente dos Termos do Brawe Creator Network (ex.: "2026-05-01").
/// Cacheada por sessão; usada pelo form para enviar `terms_version` no submit.

final class CreatorTermsVersionProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Versão vigente dos Termos do Brawe Creator Network (ex.: "2026-05-01").
  /// Cacheada por sessão; usada pelo form para enviar `terms_version` no submit.
  CreatorTermsVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorTermsVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorTermsVersionHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return creatorTermsVersion(ref);
  }
}

String _$creatorTermsVersionHash() =>
    r'a5b2e422d47761396e1fd91da8d5a263cf8c2c10';

@ProviderFor(CreatorApplicationFormController)
final creatorApplicationFormControllerProvider =
    CreatorApplicationFormControllerProvider._();

final class CreatorApplicationFormControllerProvider
    extends
        $NotifierProvider<
          CreatorApplicationFormController,
          AsyncValue<CreatorApplication?>
        > {
  CreatorApplicationFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorApplicationFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorApplicationFormControllerHash();

  @$internal
  @override
  CreatorApplicationFormController create() =>
      CreatorApplicationFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CreatorApplication?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CreatorApplication?>>(
        value,
      ),
    );
  }
}

String _$creatorApplicationFormControllerHash() =>
    r'b225d5901466c25d5ef014548b47575f78de284e';

abstract class _$CreatorApplicationFormController
    extends $Notifier<AsyncValue<CreatorApplication?>> {
  AsyncValue<CreatorApplication?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CreatorApplication?>,
              AsyncValue<CreatorApplication?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CreatorApplication?>,
                AsyncValue<CreatorApplication?>
              >,
              AsyncValue<CreatorApplication?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

final class OnboardingControllerProvider
    extends
        $NotifierProvider<
          OnboardingController,
          AsyncValue<OnboardingChecklist?>
        > {
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<OnboardingChecklist?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<OnboardingChecklist?>>(
        value,
      ),
    );
  }
}

String _$onboardingControllerHash() =>
    r'fcaf23a78984182830551db86eeab3bc72834a26';

abstract class _$OnboardingController
    extends $Notifier<AsyncValue<OnboardingChecklist?>> {
  AsyncValue<OnboardingChecklist?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<OnboardingChecklist?>,
              AsyncValue<OnboardingChecklist?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<OnboardingChecklist?>,
                AsyncValue<OnboardingChecklist?>
              >,
              AsyncValue<OnboardingChecklist?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Filtro atual usado na tela de admin (state local).

@ProviderFor(AdminApplicationsFilter)
final adminApplicationsFilterProvider = AdminApplicationsFilterProvider._();

/// Filtro atual usado na tela de admin (state local).
final class AdminApplicationsFilterProvider
    extends $NotifierProvider<AdminApplicationsFilter, AdminApplicationFilter> {
  /// Filtro atual usado na tela de admin (state local).
  AdminApplicationsFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminApplicationsFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminApplicationsFilterHash();

  @$internal
  @override
  AdminApplicationsFilter create() => AdminApplicationsFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminApplicationFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminApplicationFilter>(value),
    );
  }
}

String _$adminApplicationsFilterHash() =>
    r'38ddb89b1bba3ba76e9f98604b0bdbe8905ab5b8';

/// Filtro atual usado na tela de admin (state local).

abstract class _$AdminApplicationsFilter
    extends $Notifier<AdminApplicationFilter> {
  AdminApplicationFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AdminApplicationFilter, AdminApplicationFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdminApplicationFilter, AdminApplicationFilter>,
              AdminApplicationFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(adminCreatorApplications)
final adminCreatorApplicationsProvider = AdminCreatorApplicationsProvider._();

final class AdminCreatorApplicationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedApplications>,
          PaginatedApplications,
          FutureOr<PaginatedApplications>
        >
    with
        $FutureModifier<PaginatedApplications>,
        $FutureProvider<PaginatedApplications> {
  AdminCreatorApplicationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminCreatorApplicationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminCreatorApplicationsHash();

  @$internal
  @override
  $FutureProviderElement<PaginatedApplications> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedApplications> create(Ref ref) {
    return adminCreatorApplications(ref);
  }
}

String _$adminCreatorApplicationsHash() =>
    r'3d5d4b977bb54e5ce0e966e5d0583cef977dc63c';

@ProviderFor(adminCreatorApplication)
final adminCreatorApplicationProvider = AdminCreatorApplicationFamily._();

final class AdminCreatorApplicationProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreatorApplication>,
          CreatorApplication,
          FutureOr<CreatorApplication>
        >
    with
        $FutureModifier<CreatorApplication>,
        $FutureProvider<CreatorApplication> {
  AdminCreatorApplicationProvider._({
    required AdminCreatorApplicationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminCreatorApplicationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminCreatorApplicationHash();

  @override
  String toString() {
    return r'adminCreatorApplicationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CreatorApplication> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreatorApplication> create(Ref ref) {
    final argument = this.argument as String;
    return adminCreatorApplication(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminCreatorApplicationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminCreatorApplicationHash() =>
    r'b6c255ea926fce37efeba5964a18d110fab4d1a2';

final class AdminCreatorApplicationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CreatorApplication>, String> {
  AdminCreatorApplicationFamily._()
    : super(
        retry: null,
        name: r'adminCreatorApplicationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminCreatorApplicationProvider call({required String id}) =>
      AdminCreatorApplicationProvider._(argument: id, from: this);

  @override
  String toString() => r'adminCreatorApplicationProvider';
}

@ProviderFor(AdminApplicationReviewController)
final adminApplicationReviewControllerProvider =
    AdminApplicationReviewControllerProvider._();

final class AdminApplicationReviewControllerProvider
    extends
        $NotifierProvider<
          AdminApplicationReviewController,
          AsyncValue<CreatorApplication?>
        > {
  AdminApplicationReviewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminApplicationReviewControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminApplicationReviewControllerHash();

  @$internal
  @override
  AdminApplicationReviewController create() =>
      AdminApplicationReviewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CreatorApplication?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CreatorApplication?>>(
        value,
      ),
    );
  }
}

String _$adminApplicationReviewControllerHash() =>
    r'8ec9d6500762f01f0a14b84088caaee817d6e87e';

abstract class _$AdminApplicationReviewController
    extends $Notifier<AsyncValue<CreatorApplication?>> {
  AsyncValue<CreatorApplication?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CreatorApplication?>,
              AsyncValue<CreatorApplication?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CreatorApplication?>,
                AsyncValue<CreatorApplication?>
              >,
              AsyncValue<CreatorApplication?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

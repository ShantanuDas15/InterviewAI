// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseHash() => r'6abeb04f6d303eb0dd323e0401492c39546c0428';

/// See also [supabase].
@ProviderFor(supabase)
final supabaseProvider = AutoDisposeProvider<SupabaseClient>.internal(
  supabase,
  name: r'supabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupabaseRef = AutoDisposeProviderRef<SupabaseClient>;
String _$builtResumesListHash() => r'ddecf277575d6e94eda89ec95d4c5effa800c4f0';

/// See also [builtResumesList].
@ProviderFor(builtResumesList)
final builtResumesListProvider =
    AutoDisposeStreamProvider<List<Map<String, dynamic>>>.internal(
      builtResumesList,
      name: r'builtResumesListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$builtResumesListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BuiltResumesListRef =
    AutoDisposeStreamProviderRef<List<Map<String, dynamic>>>;
String _$builtResumeDetailsHash() =>
    r'c2ac4beff1b401d7efd4529cc79a50ed46c4d7ec';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [builtResumeDetails].
@ProviderFor(builtResumeDetails)
const builtResumeDetailsProvider = BuiltResumeDetailsFamily();

/// See also [builtResumeDetails].
class BuiltResumeDetailsFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [builtResumeDetails].
  const BuiltResumeDetailsFamily();

  /// See also [builtResumeDetails].
  BuiltResumeDetailsProvider call(String resumeId) {
    return BuiltResumeDetailsProvider(resumeId);
  }

  @override
  BuiltResumeDetailsProvider getProviderOverride(
    covariant BuiltResumeDetailsProvider provider,
  ) {
    return call(provider.resumeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'builtResumeDetailsProvider';
}

/// See also [builtResumeDetails].
class BuiltResumeDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [builtResumeDetails].
  BuiltResumeDetailsProvider(String resumeId)
    : this._internal(
        (ref) => builtResumeDetails(ref as BuiltResumeDetailsRef, resumeId),
        from: builtResumeDetailsProvider,
        name: r'builtResumeDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$builtResumeDetailsHash,
        dependencies: BuiltResumeDetailsFamily._dependencies,
        allTransitiveDependencies:
            BuiltResumeDetailsFamily._allTransitiveDependencies,
        resumeId: resumeId,
      );

  BuiltResumeDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.resumeId,
  }) : super.internal();

  final String resumeId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(BuiltResumeDetailsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BuiltResumeDetailsProvider._internal(
        (ref) => create(ref as BuiltResumeDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        resumeId: resumeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _BuiltResumeDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BuiltResumeDetailsProvider && other.resumeId == resumeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, resumeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BuiltResumeDetailsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `resumeId` of this provider.
  String get resumeId;
}

class _BuiltResumeDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with BuiltResumeDetailsRef {
  _BuiltResumeDetailsProviderElement(super.provider);

  @override
  String get resumeId => (origin as BuiltResumeDetailsProvider).resumeId;
}

String _$resumeBuilderHash() => r'3c58b77c8c195d2725f54496261b641f74bb77d8';

/// See also [ResumeBuilder].
@ProviderFor(ResumeBuilder)
final resumeBuilderProvider =
    AutoDisposeAsyncNotifierProvider<
      ResumeBuilder,
      Map<String, dynamic>?
    >.internal(
      ResumeBuilder.new,
      name: r'resumeBuilderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$resumeBuilderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ResumeBuilder = AutoDisposeAsyncNotifier<Map<String, dynamic>?>;
String _$resumeDeleterHash() => r'e77134ab8cbb5656e4b367f1c596ead1dfed6372';

/// See also [ResumeDeleter].
@ProviderFor(ResumeDeleter)
final resumeDeleterProvider =
    AutoDisposeAsyncNotifierProvider<ResumeDeleter, bool>.internal(
      ResumeDeleter.new,
      name: r'resumeDeleterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$resumeDeleterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ResumeDeleter = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedbackDetailsHash() => r'970337bdf890dc8dc3a0b55ac1a48d65d48c5ce8';

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

/// See also [feedbackDetails].
@ProviderFor(feedbackDetails)
const feedbackDetailsProvider = FeedbackDetailsFamily();

/// See also [feedbackDetails].
class FeedbackDetailsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [feedbackDetails].
  const FeedbackDetailsFamily();

  /// See also [feedbackDetails].
  FeedbackDetailsProvider call({required String feedbackId}) {
    return FeedbackDetailsProvider(feedbackId: feedbackId);
  }

  @override
  FeedbackDetailsProvider getProviderOverride(
    covariant FeedbackDetailsProvider provider,
  ) {
    return call(feedbackId: provider.feedbackId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feedbackDetailsProvider';
}

/// See also [feedbackDetails].
class FeedbackDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [feedbackDetails].
  FeedbackDetailsProvider({required String feedbackId})
    : this._internal(
        (ref) =>
            feedbackDetails(ref as FeedbackDetailsRef, feedbackId: feedbackId),
        from: feedbackDetailsProvider,
        name: r'feedbackDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedbackDetailsHash,
        dependencies: FeedbackDetailsFamily._dependencies,
        allTransitiveDependencies:
            FeedbackDetailsFamily._allTransitiveDependencies,
        feedbackId: feedbackId,
      );

  FeedbackDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedbackId,
  }) : super.internal();

  final String feedbackId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(FeedbackDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeedbackDetailsProvider._internal(
        (ref) => create(ref as FeedbackDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feedbackId: feedbackId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _FeedbackDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedbackDetailsProvider && other.feedbackId == feedbackId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feedbackId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedbackDetailsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `feedbackId` of this provider.
  String get feedbackId;
}

class _FeedbackDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with FeedbackDetailsRef {
  _FeedbackDetailsProviderElement(super.provider);

  @override
  String get feedbackId => (origin as FeedbackDetailsProvider).feedbackId;
}

String _$feedbackForInterviewHash() =>
    r'9238306b276f59a7eed7f36ff0f46c606600e30b';

/// See also [feedbackForInterview].
@ProviderFor(feedbackForInterview)
const feedbackForInterviewProvider = FeedbackForInterviewFamily();

/// See also [feedbackForInterview].
class FeedbackForInterviewFamily
    extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [feedbackForInterview].
  const FeedbackForInterviewFamily();

  /// See also [feedbackForInterview].
  FeedbackForInterviewProvider call(String interviewId) {
    return FeedbackForInterviewProvider(interviewId);
  }

  @override
  FeedbackForInterviewProvider getProviderOverride(
    covariant FeedbackForInterviewProvider provider,
  ) {
    return call(provider.interviewId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feedbackForInterviewProvider';
}

/// See also [feedbackForInterview].
class FeedbackForInterviewProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// See also [feedbackForInterview].
  FeedbackForInterviewProvider(String interviewId)
    : this._internal(
        (ref) =>
            feedbackForInterview(ref as FeedbackForInterviewRef, interviewId),
        from: feedbackForInterviewProvider,
        name: r'feedbackForInterviewProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedbackForInterviewHash,
        dependencies: FeedbackForInterviewFamily._dependencies,
        allTransitiveDependencies:
            FeedbackForInterviewFamily._allTransitiveDependencies,
        interviewId: interviewId,
      );

  FeedbackForInterviewProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.interviewId,
  }) : super.internal();

  final String interviewId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>?> Function(FeedbackForInterviewRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeedbackForInterviewProvider._internal(
        (ref) => create(ref as FeedbackForInterviewRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        interviewId: interviewId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _FeedbackForInterviewProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedbackForInterviewProvider &&
        other.interviewId == interviewId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, interviewId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedbackForInterviewRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `interviewId` of this provider.
  String get interviewId;
}

class _FeedbackForInterviewProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with FeedbackForInterviewRef {
  _FeedbackForInterviewProviderElement(super.provider);

  @override
  String get interviewId =>
      (origin as FeedbackForInterviewProvider).interviewId;
}

String _$allUserFeedbackHash() => r'd146537440e468a568392f608a94db174b3a1363';

/// See also [allUserFeedback].
@ProviderFor(allUserFeedback)
final allUserFeedbackProvider =
    AutoDisposeFutureProvider<Map<String, Map<String, dynamic>>>.internal(
      allUserFeedback,
      name: r'allUserFeedbackProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allUserFeedbackHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllUserFeedbackRef =
    AutoDisposeFutureProviderRef<Map<String, Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

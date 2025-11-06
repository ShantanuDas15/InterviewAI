// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interviews_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$apiServiceHash() => r'd76dea2a3d4afd840c19952cd59fe889ce36151d';

/// See also [apiService].
@ProviderFor(apiService)
final apiServiceProvider = AutoDisposeProvider<ApiService>.internal(
  apiService,
  name: r'apiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiServiceRef = AutoDisposeProviderRef<ApiService>;
String _$interviewsListHash() => r'1ae899c0e7c69ca988bc9278bf00b628f15384ed';

/// See also [interviewsList].
@ProviderFor(interviewsList)
final interviewsListProvider =
    AutoDisposeStreamProvider<List<Map<String, dynamic>>>.internal(
      interviewsList,
      name: r'interviewsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$interviewsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InterviewsListRef =
    AutoDisposeStreamProviderRef<List<Map<String, dynamic>>>;
String _$interviewNotifierHash() => r'fb72bc46022101140dd54ffcecb103292702ff2e';

/// See also [InterviewNotifier].
@ProviderFor(InterviewNotifier)
final interviewNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      InterviewNotifier,
      Map<String, dynamic>?
    >.internal(
      InterviewNotifier.new,
      name: r'interviewNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$interviewNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InterviewNotifier = AutoDisposeAsyncNotifier<Map<String, dynamic>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

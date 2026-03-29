// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_generator.service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiGeneratorService)
final aiGeneratorServiceProvider = AiGeneratorServiceProvider._();

final class AiGeneratorServiceProvider
    extends
        $FunctionalProvider<
          AiGeneratorService,
          AiGeneratorService,
          AiGeneratorService
        >
    with $Provider<AiGeneratorService> {
  AiGeneratorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiGeneratorServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiGeneratorServiceHash();

  @$internal
  @override
  $ProviderElement<AiGeneratorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiGeneratorService create(Ref ref) {
    return aiGeneratorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiGeneratorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiGeneratorService>(value),
    );
  }
}

String _$aiGeneratorServiceHash() =>
    r'ffdb8b3d5f59842f461f34333d6fcb4ac85cf3db';

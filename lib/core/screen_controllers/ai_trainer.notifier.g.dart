// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_trainer.notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AiTrainerNotifier)
final aiTrainerProvider = AiTrainerNotifierProvider._();

final class AiTrainerNotifierProvider
    extends $AsyncNotifierProvider<AiTrainerNotifier, TrainingPlan?> {
  AiTrainerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiTrainerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiTrainerNotifierHash();

  @$internal
  @override
  AiTrainerNotifier create() => AiTrainerNotifier();
}

String _$aiTrainerNotifierHash() => r'48776ca650524b723e78618d007b1018a56c753a';

abstract class _$AiTrainerNotifier extends $AsyncNotifier<TrainingPlan?> {
  FutureOr<TrainingPlan?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TrainingPlan?>, TrainingPlan?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrainingPlan?>, TrainingPlan?>,
              AsyncValue<TrainingPlan?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

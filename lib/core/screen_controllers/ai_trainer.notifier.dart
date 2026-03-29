import 'package:ai_trainer_app/core/models/training_plan.model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/ai_generator.service.dart';

part 'ai_trainer.notifier.g.dart';

@Riverpod(keepAlive: true)
class AiTrainerNotifier extends _$AiTrainerNotifier {
  AiGeneratorService get _aiGeneratorService =>
      ref.read(aiGeneratorServiceProvider);

  @override
  FutureOr<TrainingPlan?> build() async {
    return null;
  }

  Future<void> generate(String input) async {
    try {
      // FIX: Clear old plan immediately so the viewer never shows stale data
      state = const AsyncValue.loading();

      state = await AsyncValue.guard(() async {
        final plan = await _aiGeneratorService.generateWithGemini(input);
        return plan;
      });
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  String? inputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }
}

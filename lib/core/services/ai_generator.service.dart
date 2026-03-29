import 'package:ai_trainer_app/core/models/training_plan.model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_generator.service.g.dart';

@riverpod
AiGeneratorService aiGeneratorService(Ref ref){
  return AiGeneratorService();
}

class AiGeneratorService {
  Future<TrainingPlan> generateMockData() async {
    return TrainingPlan(
      title: 'Mock Training Plan',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      plans: [
        PlanItem(
          exercise: 'Push Ups',
          sets: 3,
          reps: [12, 10, 8],
          weight: [0, 0, 0],
        ),
        PlanItem(
          exercise: 'Deadlift',
          sets: 4,
          reps: [10, 8, 6, 4],
          weight: [40, 50, 60, 70],
        ),
      ],
    );
  }
}

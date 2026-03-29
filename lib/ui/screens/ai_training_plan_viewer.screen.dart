import 'package:ai_trainer_app/ui/widgets/ai_training_plan_viewer/training_plan_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/screen_controllers/ai_trainer.notifier.dart';

class AiTrainingPlanViewer extends ConsumerWidget {
  AiTrainingPlanViewer({super.key});

  final _controller = PageController(viewportFraction: 0.85);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(aiTrainerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Trainer',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator.adaptive())
          : state.hasError
          ? Center(child: Text(state.error.toString()))
          : state.value == null
          ? Center(
              child: Text(
                "No workout plans found",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  leading: Icon(Icons.fitness_center),
                  title: Text(
                    "${state.value!.title} (${state.value!.plans.length} exercises)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${state.value!.startDate.year}/${state.value!.startDate.month}/${state.value!.startDate.day}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: state.value?.plans.length,
                    itemBuilder: (context, index) {
                      return TrainingPlanBlock(
                        index: index,
                        plan: state.value!.plans[index],
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _controller.nextPage(
                      duration: Duration(seconds: 1),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Chip(
                    label: Text(
                      "NEXT",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
    );
  }
}

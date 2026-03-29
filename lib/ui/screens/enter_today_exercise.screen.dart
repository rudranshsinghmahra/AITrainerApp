import 'package:ai_trainer_app/core/screen_controllers/ai_trainer.notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_training_plan_viewer.screen.dart';

class EnterTodayExercise extends ConsumerWidget {
  final formKey = GlobalKey<FormState>();
  final inputController = TextEditingController();

  EnterTodayExercise({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stateNotifier = ref.read(aiTrainerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Today\'s Exercise')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_gymnastics,
                size: 63,
                color: theme.primaryColor,
              ),
              Text(
                "What exercise are we doing today?",
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              TextFormField(
                controller: inputController,
                // autofocus: true,
                validator: stateNotifier.inputValidator,
                decoration: const InputDecoration(
                  hintText: 'Abs workout, full body workout, etc.',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!formKey.currentState!.validate()) return;
          stateNotifier.generate(inputController.text);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AiTrainingPlanViewer()),
          );
        },
        child: Icon(Icons.send),
      ),
    );
  }
}

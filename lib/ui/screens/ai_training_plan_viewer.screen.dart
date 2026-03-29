import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/screen_controllers/ai_trainer.notifier.dart';

// FIX 1: Switch to ConsumerStatefulWidget so PageController has a stable lifecycle
class AiTrainingPlanViewer extends ConsumerStatefulWidget {
  const AiTrainingPlanViewer({super.key});

  @override
  ConsumerState<AiTrainingPlanViewer> createState() =>
      _AiTrainingPlanViewerState();
}

class _AiTrainingPlanViewerState extends ConsumerState<AiTrainingPlanViewer> {
  // FIX 2: PageController lives in state — created once, disposed properly
  late final PageController _pageController =
  PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiTrainerProvider);
    final theme = Theme.of(context);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: const Text("Your Routine"), centerTitle: true),
          body: state.when(
            // FIX 3: loading state shows the spinner
            loading: () => const Center(child: CircularProgressIndicator.adaptive()),
            error: (err, _) => Center(child: Text("Error: $err")),
            data: (plan) {
              // FIX 4: null means generation is still starting — show loader,
              // NOT "No plan found". The notifier emits data(null) as its
              // initial value before the async work begins.
              if (plan == null) {
                return const Center(child: CupertinoActivityIndicator());
              }

              // FIX 5: Genuinely empty plan (AI returned 0 exercises) gets its own message
              if (plan.plans.isEmpty) {
                return const Center(child: Text("No exercises were generated."));
              }

              return Column(
                children: [
                  // Header Summary Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(child: Icon(Icons.bolt)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                "${plan.plans.length} Total Exercises",
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Page indicator
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: plan.plans.length,
                      itemBuilder: (context, index) {
                        final item = plan.plans[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 16,
                          ),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "EXERCISE ${index + 1} of ${plan.plans.length}",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.exercise,
                                    style:
                                    theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(height: 40),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: item.sets.toInt(),
                                      separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                      itemBuilder: (context, setIndex) {
                                        // FIX 6: Guard against reps/weight lists being
                                        // shorter than sets count to prevent RangeError
                                        final reps = setIndex < item.reps.length
                                            ? item.reps[setIndex]
                                            : '-';
                                        final weight =
                                        setIndex < item.weight.length
                                            ? item.weight[setIndex]
                                            : '-';
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme.surfaceVariant
                                                .withOpacity(0.5),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "SET ${setIndex + 1}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Text("$reps Reps",
                                                  style:
                                                  theme.textTheme.bodyLarge),
                                              Text(
                                                "$weight kg",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                  color: theme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Navigation
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          child: const Text("Back"),
                        ),
                        ElevatedButton(
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text("Next Exercise"),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
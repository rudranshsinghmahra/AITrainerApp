import 'package:ai_trainer_app/core/models/training_plan.model.dart';
import 'package:flutter/material.dart';

class TrainingPlanBlock extends StatelessWidget {
  final int index;
  final PlanItem plan;

  const TrainingPlanBlock({super.key, required this.index, required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withAlpha(100),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${index + 1}", style: textTheme.displaySmall),
          Text(
            plan.exercise,
            style: textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text("${plan.sets}", style: textTheme.displaySmall),
              SizedBox(width: 10),
              Text("SETS"),
            ],
          ),
          Row(
            children: [
              Text("${plan.reps.join(" | ")} ", style: textTheme.displaySmall),
              SizedBox(width: 10),
              Text("REPS"),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "${plan.weight.join(" | ")} ",
                style: textTheme.displaySmall,
              ),
              SizedBox(width: 10),
              Text("WEIGHTS"),
            ],
          ),
        ],
      ),
    );
  }
}

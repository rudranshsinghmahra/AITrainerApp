import 'dart:convert';

import 'package:ai_trainer_app/core/models/training_plan.model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/env.dart';

part 'ai_generator.service.g.dart';

@riverpod
AiGeneratorService aiGeneratorService(Ref ref) {
  return AiGeneratorService();
}

class AiGeneratorService {
  final model = GenerativeModel(
    model: "gemini-2.5-flash",
    apiKey: Env.geminiApiKey,
    generationConfig: GenerationConfig(responseMimeType: "application/json"),
  );

  Future<TrainingPlan> generateMockData() async {
    return TrainingPlan(
      title: 'Mock Training Plan',
      date: DateTime.now(),
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

  Future<TrainingPlan> generateWithGemini(String userInput) async {
    // 1. Refined Prompt: Explicitly defines constraints and output format
    final prompt =
        """
    Role: Professional Personal Trainer
    Task: Convert the user's input into a structured JSON training plan.
    
    Constraints:
    - Return ONLY valid JSON. No conversational text.
    - Follow the schema provided below exactly.
    - Logic: For each exercise, the weight must increase with each set, and the reps should decrease with each set.
    - Dates should be formatted as YYYY-MM-DD.

    JSON Schema:
    {
      "title": "String (A descriptive title for the workout)",
      "date": "String (Current date in YYYY-MM-DD)",
      "plans": [
        {
          "exercise": "String",
          "sets": int,
          "reps": [int, int, ...],
          "weight": [number, number, ...]
        }
      ]
    }

    User Input: "$userInput"
  """;

    try {
      final result = await model.generateContent([Content.text(prompt)]);
      final content = result.text;

      if (content == null || content.isEmpty) {
        throw Exception("The AI returned an empty response.");
      }
      final Map<String, dynamic> decodedJson = jsonDecode(content);

      return TrainingPlan.fromJson(decodedJson);
    } catch (e) {
      print("Failed to generate or parse training plan: $e");
      throw Exception("Failed to generate or parse training plan: $e");
    }
  }
}

import 'dart:convert';

import 'package:ai_trainer_app/core/models/training_plan.model.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/env.dart';

part 'ai_generator.service.g.dart';

@riverpod
AiGeneratorService aiGeneratorService(Ref ref) {
  return AiGeneratorService();
}

class AiGeneratorService {
  // ── Shared prompt builder ────────────────────────────────────────────────────
  // Single source of truth — all three providers use the same prompt
  String _buildPrompt(String userInput) =>
      """
    Role: Professional Personal Trainer
    Task: Convert the user's input into a structured JSON training plan.

    Constraints:
    - Return ONLY valid JSON. No conversational text, no markdown fences.
    - Follow the schema provided below exactly.
    - Logic: For each exercise, weight must increase per set, reps must decrease per set.
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

  // ── Mock ─────────────────────────────────────────────────────────────────────
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

  // ── Gemini ───────────────────────────────────────────────────────────────────
  Future<TrainingPlan> generateWithGemini(String userInput) async {
    final geminiModel = GenerativeModel(
      model: "gemini-2.5-flash",
      apiKey: Env.geminiApiKey,
      generationConfig: GenerationConfig(responseMimeType: "application/json"),
    );
    try {
      final result = await geminiModel.generateContent([
        Content.text(_buildPrompt(userInput)),
      ]);
      final content = result.text;
      if (content == null || content.isEmpty) {
        throw Exception("Gemini returned an empty response.");
      }
      return TrainingPlan.fromJson(jsonDecode(content));
    } catch (e) {
      throw Exception("Gemini generation failed: $e");
    }
  }

  // ── OpenAI ───────────────────────────────────────────────────────────────────
  Future<TrainingPlan> generateWithOpenAI(String userInput) async {
    OpenAI.apiKey = Env.openAiApiKey;
    OpenAI.baseUrl = Env.openAiBaseUrl;

    try {
      return await _callOpenAICompatible(
        model: "gpt-4o",
        userInput: userInput,
        providerName: "OpenAI",
      );
    } finally {
      // FIX: Always restore DeepSeek config so other calls aren't broken
      OpenAI.apiKey = Env.deepseekApiKey;
      OpenAI.baseUrl = Env.deepseekBaseUrl;
    }
  }

  // ── DeepSeek ─────────────────────────────────────────────────────────────────
  Future<TrainingPlan> generateWithDeepSeek(String userInput) async {
    OpenAI.apiKey = Env.deepseekApiKey;
    OpenAI.baseUrl = Env.deepseekBaseUrl;

    return _callOpenAICompatible(
      model: "deepseek-chat",
      userInput: userInput,
      providerName: "DeepSeek",
    );
  }

  // ── Shared OpenAI-compatible helper ──────────────────────────────────────────
  // DeepSeek's API is OpenAI-compatible, so both providers use this same method.
  // The only difference between them is the apiKey, baseUrl, and model name,
  // which are set by the callers above before invoking this.
  // ── Shared OpenAI-compatible helper ──────────────────────────────────────────
  Future<TrainingPlan> _callOpenAICompatible({
    required String model,
    required String userInput,
    required String providerName,
  }) async {
    try {
      final completion = await OpenAI.instance.chat.create(
        model: model,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                "You are a professional personal trainer. "
                "Always respond with valid JSON only. No markdown, no explanation.",
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                _buildPrompt(userInput),
              ),
            ],
          ),
        ],
        // JSON output is enforced via the system prompt + _stripMarkdownFences().
      );

      final message = completion.choices.firstOrNull?.message;
      if (message == null) {
        throw Exception("$providerName returned no choices.");
      }

      // dart_openai can return content as either a content list or
      // a raw string depending on the version — handle both
      String? raw;
      final contentItems = message.content;
      if (contentItems != null && contentItems.isNotEmpty) {
        raw = contentItems
            .map((item) => item.text ?? '')
            .where((t) => t.isNotEmpty)
            .join();
      }

      debugPrint("[$providerName] Raw response: $raw");

      if (raw == null || raw.trim().isEmpty) {
        throw Exception("$providerName returned empty content.");
      }

      //Strip markdown fences in case the model ignores json_object mode
      final cleaned = _stripMarkdownFences(raw);

      debugPrint("[$providerName] Cleaned response: $cleaned");

      return TrainingPlan.fromJson(jsonDecode(cleaned));
    } on FormatException catch (e) {
      //Specific catch for JSON errors with clearer message
      print("$providerName returned invalid JSON: ${e.message}");
      throw Exception("$providerName returned invalid JSON: ${e.message}");
    } catch (e) {
      throw Exception("$providerName generation failed: $e");
    }
  }

  // ── Shared markdown fence stripper ──────────────────────────────────────────
  // Strips ```json ... ``` or ``` ... ``` fences if present
  String _stripMarkdownFences(String raw) {
    final fencePattern = RegExp(
      r'^```(?:json)?\s*\n?([\s\S]*?)\n?```$',
      multiLine: false,
      caseSensitive: false,
    );
    final match = fencePattern.firstMatch(raw.trim());
    return match != null ? match.group(1)!.trim() : raw.trim();
  }
}

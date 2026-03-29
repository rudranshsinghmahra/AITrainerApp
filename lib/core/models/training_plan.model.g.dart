// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainingPlan _$TrainingPlanFromJson(Map<String, dynamic> json) =>
    _TrainingPlan(
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      plans: (json['plans'] as List<dynamic>)
          .map((e) => PlanItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TrainingPlanToJson(_TrainingPlan instance) =>
    <String, dynamic>{
      'title': instance.title,
      'date': instance.date.toIso8601String(),
      'plans': instance.plans,
    };

_PlanItem _$PlanItemFromJson(Map<String, dynamic> json) => _PlanItem(
  exercise: json['exercise'] as String,
  sets: json['sets'] as num,
  reps: (json['reps'] as List<dynamic>).map((e) => e as num).toList(),
  weight: (json['weight'] as List<dynamic>).map((e) => e as num).toList(),
);

Map<String, dynamic> _$PlanItemToJson(_PlanItem instance) => <String, dynamic>{
  'exercise': instance.exercise,
  'sets': instance.sets,
  'reps': instance.reps,
  'weight': instance.weight,
};

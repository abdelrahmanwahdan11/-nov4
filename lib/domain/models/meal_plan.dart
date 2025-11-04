import 'dart:convert';

enum MealDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class MealPlanEntry {
  MealPlanEntry({required this.itemId, this.servings = 1});

  final String itemId;
  final int servings;

  MealPlanEntry copyWith({String? itemId, int? servings}) {
    return MealPlanEntry(
      itemId: itemId ?? this.itemId,
      servings: servings ?? this.servings,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'itemId': itemId,
      'servings': servings,
    };
  }

  factory MealPlanEntry.fromJson(Map<String, dynamic> json) {
    return MealPlanEntry(
      itemId: json['itemId'] as String,
      servings: json['servings'] is int
          ? json['servings'] as int
          : int.tryParse('${json['servings']}') ?? 1,
    );
  }
}

class MealPlan {
  MealPlan({Map<MealDay, List<MealPlanEntry>>? days})
      : days = <MealDay, List<MealPlanEntry>>{
          for (final day in MealDay.values)
            day: List<MealPlanEntry>.from(days?[day] ?? const <MealPlanEntry>[]),
        };

  final Map<MealDay, List<MealPlanEntry>> days;

  factory MealPlan.empty() => MealPlan();

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final map = <MealDay, List<MealPlanEntry>>{};
    for (final day in MealDay.values) {
      final raw = json[day.name];
      if (raw is List) {
        map[day] = raw
            .whereType<Map<String, dynamic>>()
            .map(MealPlanEntry.fromJson)
            .toList();
      } else {
        map[day] = <MealPlanEntry>[];
      }
    }
    return MealPlan(days: map);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      for (final entry in days.entries)
        entry.key.name: entry.value.map((item) => item.toJson()).toList(),
    };
  }

  List<MealPlanEntry> entriesFor(MealDay day) {
    return List<MealPlanEntry>.from(days[day] ?? const <MealPlanEntry>[]);
  }

  void setEntries(MealDay day, List<MealPlanEntry> entries) {
    days[day] = List<MealPlanEntry>.from(entries);
  }

  MealPlan clone() {
    return MealPlan(days: days);
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Activity {
  final String id;
  final String dayId;
  final String title;
  final String? description;
  final String? time;
  final int? duration;
  final double? cost;
  final String? category;
  final String? location;

  Activity({
    required this.id,
    required this.dayId,
    required this.title,
    this.description,
    this.time,
    this.duration,
    this.cost,
    this.category,
    this.location,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  // Helper method to get the correct icon
  String getCategoryIcon() {
    switch (category?.toLowerCase()) {
      case 'food':
        return 'restaurant';
      case 'sightseeing':
        return 'tour';
      case 'transport':
        return 'directions_bus';
      case 'accommodation':
        return 'hotel';
      default:
        return 'place';
    }
  }

  // Create a copy with updated fields
  Activity copyWith({
    String? id,
    String? dayId,
    String? title,
    String? description,
    String? time,
    int? duration,
    double? cost,
    String? category,
    String? location,
  }) {
    return Activity(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      cost: cost ?? this.cost,
      category: category ?? this.category,
      location: location ?? this.location,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: json['id'] as String,
  dayId: json['day_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  time: json['time'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
  cost: (json['cost'] as num?)?.toDouble(),
  category: json['category'] as String?,
  location: json['location'] as String?,
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'day_id': instance.dayId,
  'title': instance.title,
  'description': instance.description,
  'time': instance.time,
  'duration': instance.duration,
  'cost': instance.cost,
  'category': instance.category,
  'location': instance.location,
};

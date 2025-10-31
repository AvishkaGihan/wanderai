// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  destination: json['destination'] as String?,
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
  budget: (json['budget'] as num?)?.toDouble(),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  days: (json['days'] as List<dynamic>?)
      ?.map((e) => Day.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageUrl: json['image_url'] as String?,
  photographer: json['photographer'] as String?,
  photographerUrl: json['photographer_url'] as String?,
);

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'destination': instance.destination,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'budget': instance.budget,
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'days': instance.days,
  'image_url': instance.imageUrl,
  'photographer': instance.photographer,
  'photographer_url': instance.photographerUrl,
};

Day _$DayFromJson(Map<String, dynamic> json) => Day(
  id: json['id'] as String,
  tripId: json['tripId'] as String,
  date: DateTime.parse(json['date'] as String),
  title: json['title'] as String?,
  order: (json['order'] as num).toInt(),
  activities: (json['activities'] as List<dynamic>?)
      ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DayToJson(Day instance) => <String, dynamic>{
  'id': instance.id,
  'tripId': instance.tripId,
  'date': instance.date.toIso8601String(),
  'title': instance.title,
  'order': instance.order,
  'activities': instance.activities,
};

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: json['id'] as String,
  dayId: json['dayId'] as String,
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
  'dayId': instance.dayId,
  'title': instance.title,
  'description': instance.description,
  'time': instance.time,
  'duration': instance.duration,
  'cost': instance.cost,
  'category': instance.category,
  'location': instance.location,
};

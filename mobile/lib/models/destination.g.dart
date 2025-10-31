// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Destination _$DestinationFromJson(Map<String, dynamic> json) => Destination(
  id: json['id'] as String,
  name: json['name'] as String,
  country: json['country'] as String?,
  description: json['description'] as String?,
  budget: (json['budget'] as num?)?.toDouble(),
  attractions: (json['attractions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  imageUrl: json['image_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$DestinationToJson(Destination instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'description': instance.description,
      'budget': instance.budget,
      'attractions': instance.attractions,
      'image_url': instance.imageUrl,
      'created_at': instance.createdAt.toIso8601String(),
    };

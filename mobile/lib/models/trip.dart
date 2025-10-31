import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart'; // for IconData

part 'trip.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Trip {
  final String id;
  final String userId;
  final String title;
  final String? destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? budget;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Day>? days; // Nested Days and Activities data

  // Pexels image fields
  final String? imageUrl;
  final String? photographer;
  final String? photographerUrl;

  Trip({
    required this.id,
    required this.userId,
    required this.title,
    this.destination,
    this.startDate,
    this.endDate,
    this.budget,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.days,
    this.imageUrl,
    this.photographer,
    this.photographerUrl,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  Map<String, dynamic> toJson() => _$TripToJson(this);

  int get durationDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  bool get isActive => status == 'active';
  bool get isDraft => status == 'draft';
  bool get isCompleted => status == 'completed';
}

@JsonSerializable()
class Day {
  final String id;
  final String tripId;
  final DateTime date;
  final String? title;
  final int order;
  final List<Activity>? activities;

  Day({
    required this.id,
    required this.tripId,
    required this.date,
    this.title,
    required this.order,
    this.activities,
  });

  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);
  Map<String, dynamic> toJson() => _$DayToJson(this);
}

@JsonSerializable()
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

  // Helper getter for displaying an icon based on category
  IconData get categoryIcon {
    switch (category?.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'sightseeing':
        return Icons.tour;
      case 'transport':
        return Icons.directions_bus;
      case 'accommodation':
        return Icons.hotel;
      case 'activity':
        return Icons.local_activity;
      default:
        return Icons.place;
    }
  }
}

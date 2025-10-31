import '../models/activity.dart';
import 'api_service.dart';

class ActivityService {
  final ApiService _apiService = ApiService();

  // Get all activities for a trip
  Future<List<Activity>> getTripActivities(String tripId) async {
    try {
      final response = await _apiService.dio.get('/trips/$tripId/activities');
      return (response.data as List)
          .map((json) => Activity.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Create a new activity
  Future<Activity> createActivity({
    required String tripId,
    required String dayId,
    required String title,
    String? description,
    String? time,
    int? duration,
    double? cost,
    String? category,
    String? location,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/trips/$tripId/days/$dayId/activities',
        data: {
          'title': title,
          if (description != null) 'description': description,
          if (time != null) 'time': time,
          if (duration != null) 'duration': duration,
          if (cost != null) 'cost': cost,
          if (category != null) 'category': category,
          if (location != null) 'location': location,
        },
      );
      return Activity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Update an activity
  Future<Activity> updateActivity({
    required String tripId,
    required String activityId,
    String? title,
    String? description,
    String? time,
    int? duration,
    double? cost,
    String? category,
    String? location,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/trips/$tripId/activities/$activityId',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (time != null) 'time': time,
          if (duration != null) 'duration': duration,
          if (cost != null) 'cost': cost,
          if (category != null) 'category': category,
          if (location != null) 'location': location,
        },
      );
      return Activity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete an activity
  Future<void> deleteActivity(String tripId, String activityId) async {
    try {
      await _apiService.dio.delete('/trips/$tripId/activities/$activityId');
    } catch (e) {
      rethrow;
    }
  }
}

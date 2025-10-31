import '../models/trip.dart';
import 'api_service.dart';

class TripService {
  final ApiService _apiService = ApiService();

  // Get all trips
  Future<List<Trip>> getTrips() async {
    try {
      final response = await _apiService.dio.get('/trips/');
      return (response.data as List)
          .map((json) => Trip.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get single trip
  Future<Trip> getTrip(String tripId) async {
    try {
      final response = await _apiService.dio.get('/trips/$tripId');
      return Trip.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Create trip
  Future<Trip> createTrip({
    required String title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/trips/',
        data: {
          'title': title,
          if (destination != null) 'destination': destination,
          // Convert DateTime to ISO string for backend
          if (startDate != null)
            'start_date': startDate.toIso8601String().substring(0, 10),
          if (endDate != null)
            'end_date': endDate.toIso8601String().substring(0, 10),
          if (budget != null) 'budget': budget,
          'status': 'draft',
        },
      );
      return Trip.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Update trip
  Future<Trip> updateTrip(String tripId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.put('/trips/$tripId', data: data);
      return Trip.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete trip
  Future<void> deleteTrip(String tripId) async {
    try {
      await _apiService.dio.delete('/trips/$tripId');
    } catch (e) {
      rethrow;
    }
  }

  // Get itinerary (raw map, will be processed in a provider)
  Future<Map<String, dynamic>> getItinerary(String tripId) async {
    try {
      final response = await _apiService.dio.get('/trips/$tripId/itinerary');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Generate itinerary
  Future<void> generateItinerary(String tripId, String chatSessionId) async {
    try {
      await _apiService.dio.post(
        '/trips/$tripId/itinerary',
        data: {'chat_session_id': chatSessionId},
      );
    } catch (e) {
      rethrow;
    }
  }
}

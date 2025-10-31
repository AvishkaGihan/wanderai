import '../models/destination.dart';
import 'api_service.dart';

class DestinationService {
  final ApiService _apiService = ApiService();

  // Search destinations
  Future<List<Destination>> searchDestinations({
    String? query,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/destinations/',
        queryParameters: {if (query != null) 'query': query, 'limit': limit},
      );
      return (response.data as List)
          .map((json) => Destination.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get single destination by ID
  Future<Destination> getDestination(String id) async {
    try {
      final response = await _apiService.dio.get('/destinations/$id');
      return Destination.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

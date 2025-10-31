import 'package:hive_flutter/hive_flutter.dart';
import '../models/trip.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;

  late Box _box;

  CacheService._internal() {
    // This assumes the box has been opened in main.dart
    _box = Hive.box('wanderai_cache');
  }

  // Cache trip (stores JSON representation)
  Future<void> cacheTrip(Trip trip) async {
    await _box.put('trip_${trip.id}', trip.toJson());
  }

  // Get cached trip
  Trip? getCachedTrip(String tripId) {
    final json = _box.get('trip_$tripId');
    if (json == null) return null;
    return Trip.fromJson(Map<String, dynamic>.from(json));
  }

  // Get all cached trips
  List<Trip> getAllCachedTrips() {
    final trips = <Trip>[];
    for (var key in _box.keys) {
      if (key.toString().startsWith('trip_')) {
        final json = _box.get(key);
        if (json != null) {
          trips.add(Trip.fromJson(Map<String, dynamic>.from(json)));
        }
      }
    }
    return trips;
  }

  // Remove cached trip
  Future<void> removeCachedTrip(String tripId) async {
    await _box.delete('trip_$tripId');
  }

  // Clear all cache
  Future<void> clearCache() async {
    await _box.clear();
  }

  // Save preferences
  Future<void> savePreference(String key, dynamic value) async {
    await _box.put('pref_$key', value);
  }

  // Get preference
  T? getPreference<T>(String key) {
    return _box.get('pref_$key') as T?;
  }
}

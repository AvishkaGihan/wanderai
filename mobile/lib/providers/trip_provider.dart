import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';
import '../services/cache_service.dart';

// Trip service provider
final tripServiceProvider = Provider((ref) => TripService());

// All trips provider: fetches and caches all trips for the user
final tripsProvider = FutureProvider<List<Trip>>((ref) async {
  final tripService = ref.watch(tripServiceProvider);
  try {
    final trips = await tripService.getTrips();

    // Cache trips locally on successful fetch
    for (var trip in trips) {
      await CacheService().cacheTrip(trip);
    }

    return trips;
  } catch (e) {
    // If API fails, attempt to return cached trips instead
    return CacheService().getAllCachedTrips();
  }
});

// Single trip provider (Family allows passing an argument: tripId)
final tripProvider = FutureProvider.family<Trip, String>((ref, tripId) async {
  final tripService = ref.watch(tripServiceProvider);
  try {
    final trip = await tripService.getTrip(tripId);
    await CacheService().cacheTrip(trip);
    return trip;
  } catch (e) {
    // Try to return cached trip on error
    final cachedTrip = CacheService().getCachedTrip(tripId);
    if (cachedTrip != null) return cachedTrip;
    rethrow;
  }
});

// Trip itinerary provider (for fetching the detailed daily plan)
final tripItineraryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, tripId) async {
      final tripService = ref.watch(tripServiceProvider);
      return await tripService.getItinerary(tripId);
    });

// Trip actions notifier (for C.R.U.D. operations and invalidating caches)
class TripActionsNotifier extends Notifier<AsyncValue<void>> {
  late final TripService _tripService;

  @override
  AsyncValue<void> build() {
    _tripService = ref.watch(tripServiceProvider);
    return const AsyncValue.data(null);
  }

  // Create operation
  Future<Trip> createTrip({
    required String title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
  }) async {
    state = const AsyncValue.loading();
    try {
      final trip = await _tripService.createTrip(
        title: title,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
      );
      if (ref.mounted) {
        state = const AsyncValue.data(null);
        // Invalidate the list of trips to trigger a refresh across the app
        ref.invalidate(tripsProvider);
      }
      return trip;
    } catch (e, stack) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  // Update operation
  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _tripService.updateTrip(tripId, data);
      if (ref.mounted) {
        state = const AsyncValue.data(null);
        // Invalidate specific trip and the main list
        ref.invalidate(tripsProvider);
        ref.invalidate(tripProvider(tripId));
      }
    } catch (e, stack) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  // Delete operation
  Future<void> deleteTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      await _tripService.deleteTrip(tripId);
      await CacheService().removeCachedTrip(tripId); // Clear local cache too
      if (ref.mounted) {
        state = const AsyncValue.data(null);
        ref.invalidate(tripsProvider);
      }
    } catch (e, stack) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  // Itinerary Generation
  Future<void> generateItinerary(String tripId, String chatSessionId) async {
    state = const AsyncValue.loading();
    try {
      await _tripService.generateItinerary(tripId, chatSessionId);
      if (ref.mounted) {
        state = const AsyncValue.data(null);
        // Invalidate the itinerary and the trip detail to show the newly generated plan
        ref.invalidate(tripItineraryProvider(tripId));
        ref.invalidate(tripProvider(tripId));
      }
    } catch (e, stack) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }
}

final tripActionsProvider =
    NotifierProvider<TripActionsNotifier, AsyncValue<void>>(
      () => TripActionsNotifier(),
    );

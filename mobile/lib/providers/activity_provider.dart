import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import 'trip_provider.dart';

// Activity service provider
final activityServiceProvider = Provider((ref) => ActivityService());

// Activities for a specific trip provider
final tripActivitiesProvider = FutureProvider.family<List<Activity>, String>((
  ref,
  tripId,
) async {
  final activityService = ref.watch(activityServiceProvider);
  return await activityService.getTripActivities(tripId);
});

// Activity actions notifier (for C.R.U.D. operations)
class ActivityActionsNotifier extends Notifier<AsyncValue<void>> {
  late final ActivityService _activityService;

  @override
  AsyncValue<void> build() {
    _activityService = ref.watch(activityServiceProvider);
    return const AsyncValue.data(null);
  }

  // Create operation
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
    state = const AsyncValue.loading();
    try {
      final activity = await _activityService.createActivity(
        tripId: tripId,
        dayId: dayId,
        title: title,
        description: description,
        time: time,
        duration: duration,
        cost: cost,
        category: category,
        location: location,
      );
      if (ref.mounted) {
        state = const AsyncValue.data(null);
        // Invalidate the activities list to trigger a refresh
        ref.invalidate(tripActivitiesProvider(tripId));
      }
      return activity;
    } catch (e, stack) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  // Update operation
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
    state = const AsyncValue.loading();
    try {
      final activity = await _activityService.updateActivity(
        tripId: tripId,
        activityId: activityId,
        title: title,
        description: description,
        time: time,
        duration: duration,
        cost: cost,
        category: category,
        location: location,
      );
      if (ref.mounted) {
        state = const AsyncValue.data(null);
        // Invalidate the activities list and itinerary to trigger a refresh
        ref.invalidate(tripActivitiesProvider(tripId));
        // Also invalidate the itinerary since activities are shown there
        ref.invalidate(tripItineraryProvider(tripId));
      }
      return activity;
    } catch (e, stack) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  // Delete operation
  Future<void> deleteActivity(String tripId, String activityId) async {
    state = const AsyncValue.loading();
    try {
      await _activityService.deleteActivity(tripId, activityId);
      if (ref.mounted) {
        state = const AsyncValue.data(null);
        // Invalidate the activities list and itinerary to trigger a refresh
        ref.invalidate(tripActivitiesProvider(tripId));
        ref.invalidate(tripItineraryProvider(tripId));
      }
    } catch (e, stack) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }
}

final activityActionsProvider =
    NotifierProvider<ActivityActionsNotifier, AsyncValue<void>>(
      () => ActivityActionsNotifier(),
    );

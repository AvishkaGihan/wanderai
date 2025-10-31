import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/destination.dart';
import '../services/destination_service.dart';

// Destination service provider
final destinationServiceProvider = Provider((ref) => DestinationService());

// Search query state
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

final destinationSearchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(() => SearchQueryNotifier());

// Destinations list provider (automatically re-fetches when query changes)
final destinationsProvider = FutureProvider<List<Destination>>((ref) async {
  final service = ref.watch(destinationServiceProvider);
  // Watching the query state makes this provider reactive
  final query = ref.watch(destinationSearchQueryProvider);

  return await service.searchDestinations(query: query.isEmpty ? null : query);
});

// Single destination provider (Family for fetching by ID)
final destinationProvider = FutureProvider.family<Destination, String>((
  ref,
  destinationId,
) async {
  final service = ref.watch(destinationServiceProvider);
  return await service.getDestination(destinationId);
});

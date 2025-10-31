import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/destination_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../models/destination.dart';

class SavedDestinationsScreen extends ConsumerWidget {
  const SavedDestinationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final destinationsAsync = ref.watch(destinationsProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Saved Destinations'),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          // Get saved destination IDs from user preferences
          final savedIds =
              user.preferences?['saved_destinations'] as List<dynamic>? ?? [];
          final savedDestinationIds = savedIds
              .map((id) => id.toString())
              .toSet();

          return destinationsAsync.when(
            data: (destinations) {
              final savedDestinations = destinations
                  .where((dest) => savedDestinationIds.contains(dest.id))
                  .toList();

              if (savedDestinations.isEmpty) {
                return EmptyState(
                  icon: Icons.favorite_border,
                  title: 'No Saved Destinations',
                  message: 'Start exploring and save destinations you love!',
                  actionLabel: 'Explore Destinations',
                  onAction: () => Navigator.pop(context),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: savedDestinations.length,
                itemBuilder: (context, index) {
                  final destination = savedDestinations[index];
                  return _SavedDestinationCard(
                    destination: destination,
                    onRemove: () => _removeFromSaved(ref, destination.id),
                    onTap: () => context.go(
                      '/destinations/${destination.id}',
                      extra: destination,
                    ),
                  );
                },
              );
            },
            loading: () =>
                const LoadingIndicator(message: 'Loading destinations...'),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading profile...'),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _removeFromSaved(WidgetRef ref, String destinationId) async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    final savedIds =
        user.preferences?['saved_destinations'] as List<dynamic>? ?? [];
    final updatedIds = savedIds
        .where((id) => id.toString() != destinationId)
        .toList();

    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateProfile(
        preferences: {...?user.preferences, 'saved_destinations': updatedIds},
      );

      // Refresh user profile
      ref.invalidate(userProfileProvider);
    } catch (e) {
      // Handle error - could show snackbar
      debugPrint('Error removing saved destination: $e');
    }
  }
}

class _SavedDestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _SavedDestinationCard({
    required this.destination,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: destination.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: destination.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (destination.country != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        destination.country!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (destination.budget != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '\$${destination.budget}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

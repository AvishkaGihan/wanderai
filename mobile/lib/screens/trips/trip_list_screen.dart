import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../utils/date_formatter.dart';
import '../../utils/currency_formatter.dart';
import '../../models/trip.dart';

class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'My Trips'),
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return EmptyState(
              icon: Icons.luggage_outlined,
              title: 'No Trips Yet',
              message: 'Start planning your next adventure!',
              actionLabel: 'Create Trip',
              onAction: () => context.push('/trips/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tripsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return _TripCard(trip: trip);
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading trips...'),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading trips'),
              TextButton(
                onPressed: () => ref.invalidate(tripsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trips/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/trips/${trip.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header - Use Pexels image from backend
            if (trip.imageUrl != null || trip.destination != null)
              CachedNetworkImage(
                imageUrl:
                    trip.imageUrl ??
                    'https://images.pexels.com/photos/1268855/pexels-photo-1268855.jpeg?auto=compress&cs=tinysrgb&h=350',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trip.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      _StatusChip(status: trip.status),
                    ],
                  ),
                  if (trip.destination != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.destination!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                  if (trip.startDate != null && trip.endDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDateRange(
                            trip.startDate!,
                            trip.endDate!,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          '${trip.durationDays} days',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  if (trip.budget != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          CurrencyFormatter.format(trip.budget!),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  // Photographer attribution
                  if (trip.photographer != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Photo by ${trip.photographer} on Pexels',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Completed';
        break;
      default:
        color = Colors.orange;
        label = 'Draft';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

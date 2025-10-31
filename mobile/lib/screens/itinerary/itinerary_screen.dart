import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/trip_provider.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/chat_session_selection_dialog.dart';
import '../../widgets/activity_edit_dialog.dart';
import '../../utils/currency_formatter.dart';

class ItineraryScreen extends ConsumerWidget {
  final String tripId;

  const ItineraryScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the raw itinerary data from the backend
    final itineraryAsync = ref.watch(tripItineraryProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Generate with AI',
            onPressed: () => _showChatSessionDialog(context, ref),
          ),
        ],
      ),
      body: itineraryAsync.when(
        data: (itinerary) {
          // Extract the list of days from the raw map data
          final days = itinerary['days'] as List? ?? [];

          if (days.isEmpty) {
            return EmptyState(
              icon: Icons.map_outlined,
              title: 'No Itinerary Yet',
              message:
                  'Generate an itinerary using AI or add activities manually',
              actionLabel: 'Generate with AI',
              onAction: () => _showChatSessionDialog(context, ref),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              return _DayCard(day: day, dayNumber: index + 1, tripId: tripId);
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading itinerary...'),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error loading itinerary'),
              TextButton(
                onPressed: () => ref.invalidate(tripItineraryProvider(tripId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChatSessionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ChatSessionSelectionDialog(
        onSessionSelected: (sessionId) async {
          try {
            await ref
                .read(tripActionsProvider.notifier)
                .generateItinerary(tripId, sessionId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Itinerary generated successfully!'),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to generate itinerary: $e')),
              );
            }
          }
        },
      ),
    );
  }
}

class _DayCard extends StatefulWidget {
  final Map<String, dynamic> day;
  final int dayNumber;
  final String tripId;

  const _DayCard({
    required this.day,
    required this.dayNumber,
    required this.tripId,
  });

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final activities = widget.day['activities'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(child: Text('${widget.dayNumber}')),
            title: Text(
              widget.day['title'] ?? 'Day ${widget.dayNumber}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            subtitle: Text(
              // Assuming 'date' field exists in the data
              widget.day['date'] ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() => _isExpanded = !_isExpanded);
              },
            ),
          ),
          if (_isExpanded)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _ActivityTile(
                  activity: activity,
                  tripId: widget.tripId,
                  dayId: widget.day['id'],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ActivityTile extends ConsumerWidget {
  final Map<String, dynamic> activity;
  final String tripId;
  final String dayId;

  const _ActivityTile({
    required this.activity,
    required this.tripId,
    required this.dayId,
  });

  // Helper function to get the correct icon
  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'sightseeing':
        return Icons.tour;
      case 'transport':
        return Icons.directions_bus;
      case 'accommodation':
        return Icons.hotel;
      default:
        return Icons.place;
    }
  }

  void _showActivityOptionsMenu(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> activity,
    String tripId,
    String dayId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Activity'),
              onTap: () {
                Navigator.pop(context);
                _showActivityEditDialog(context, ref, activity, tripId, dayId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Activity',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(context, ref, activity, tripId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityEditDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> activity,
    String tripId,
    String dayId,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          ActivityEditDialog(tripId: tripId, activity: activity, dayId: dayId),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> activity,
    String tripId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text(
          'Are you sure you want to delete "${activity['title']}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteActivity(context, ref, activity, tripId),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteActivity(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> activity,
    String tripId,
  ) async {
    Navigator.pop(context); // Close confirmation dialog

    try {
      await ref
          .read(activityActionsProvider.notifier)
          .deleteActivity(tripId, activity['id']);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity deleted successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete activity: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(_getCategoryIcon(activity['category'])),
      title: Text(activity['title'] ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity['description'] != null) Text(activity['description']),
          const SizedBox(height: 4),
          Row(
            children: [
              if (activity['time'] != null) ...[
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  activity['time'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
              ],
              if (activity['cost'] != null) ...[
                Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  CurrencyFormatter.format(activity['cost']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () =>
            _showActivityOptionsMenu(context, ref, activity, tripId, dayId),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/date_formatter.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/error_handler.dart';
import '../../models/trip.dart'; // Import Trip model
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';

class TripDetailScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the specific trip data using the tripId argument
    final tripAsync = ref.watch(tripProvider(tripId));

    return tripAsync.when(
      data: (trip) => _TripDetailView(trip: trip),
      loading: () => const Scaffold(
        body: LoadingIndicator(message: 'Loading trip details...'),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading trip: ${ErrorHandler.getErrorMessage(error)}',
              ),
              TextButton(
                // Allows retrying the fetch operation
                onPressed: () => ref.invalidate(tripProvider(tripId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripDetailView extends ConsumerWidget {
  final Trip trip;

  const _TripDetailView({required this.trip});

  // --- Deletion Logic ---

  Future<void> _deleteTrip(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text(
          'Are you sure you want to delete this trip? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(tripActionsProvider.notifier).deleteTrip(trip.id);
        if (context.mounted) {
          ErrorHandler.showSuccessSnackBar(context, 'Trip deleted');
          // Navigate back to the home screen after deletion
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider(trip.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.push('/trips/${trip.id}/edit', extra: trip),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Delete Trip'),
                    onTap: () => _deleteTrip(context, ref),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(trip.title),
              centerTitle: false,
              background: trip.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: trip.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[300]),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Stats',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildStatsGrid(context, expensesAsync),
                  const SizedBox(height: 24),
                  _buildItinerarySection(context),
                  const SizedBox(height: 16),
                  _buildExpensesSection(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trip.destination != null)
              _buildInfoRow(
                Icons.location_on,
                'Destination',
                trip.destination!,
              ),
            if (trip.startDate != null && trip.endDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.calendar_today,
                'Duration',
                '${DateFormatter.formatDateRange(trip.startDate!, trip.endDate!)} (${trip.durationDays} days)',
              ),
            ],
            if (trip.budget != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.attach_money,
                'Budget',
                CurrencyFormatter.format(trip.budget!),
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.info_outline,
              'Status',
              trip.status.toUpperCase(),
            ),
            // Photographer attribution
            if (trip.photographer != null) ...[
              const SizedBox(height: 12),
              Text(
                'Photo by ${trip.photographer} on Pexels',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/trips/${trip.id}/itinerary'),
            icon: const Icon(Icons.map),
            label: const Text('Itinerary'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/trips/${trip.id}/budget'),
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Budget'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    AsyncValue<List<Expense>> expensesAsync,
  ) {
    // Calculate actual counts
    final activityCount =
        trip.days?.fold<int>(
          0,
          (sum, day) => sum + (day.activities?.length ?? 0),
        ) ??
        0;
    final expenseCount = expensesAsync.maybeWhen(
      data: (expenses) => expenses.length,
      orElse: () => 0,
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard(
          context,
          Icons.calendar_today,
          trip.durationDays.toString(),
          'Days',
          Colors.blue,
        ),
        _buildStatCard(
          context,
          Icons.attach_money,
          CurrencyFormatter.formatCompact(trip.budget ?? 0),
          'Budget',
          Colors.green,
        ),
        _buildStatCard(
          context,
          Icons.check_circle,
          activityCount.toString(),
          'Activities',
          Colors.orange,
        ),
        _buildStatCard(
          context,
          Icons.receipt,
          expenseCount.toString(),
          'Expenses',
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildItinerarySection(BuildContext context) {
    if (trip.days == null || trip.days!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Itinerary', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trip.days!.length,
          itemBuilder: (context, index) {
            final day = trip.days![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(
                  'Day ${day.order}: ${day.title ?? DateFormatter.formatDate(day.date)}',
                ),
                children:
                    day.activities
                        ?.map(
                          (activity) => ListTile(
                            leading: Icon(activity.categoryIcon),
                            title: Text(activity.title),
                            subtitle: activity.description != null
                                ? Text(activity.description!)
                                : null,
                            trailing: activity.cost != null
                                ? Text(CurrencyFormatter.format(activity.cost!))
                                : null,
                          ),
                        )
                        .toList() ??
                    [],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpensesSection(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider(trip.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expenses', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        expensesAsync.when(
          data: (expenses) {
            if (expenses.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No expenses added yet.'),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.receipt, color: Colors.purple),
                    title: Text(expense.category),
                    subtitle: Text(DateFormatter.formatDate(expense.date)),
                    trailing: Text(CurrencyFormatter.format(expense.amount)),
                  ),
                );
              },
            );
          },
          loading: () => const LoadingIndicator(message: 'Loading expenses...'),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading expenses: ${ErrorHandler.getErrorMessage(error)}',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
